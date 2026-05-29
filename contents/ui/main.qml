import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.extras as PlasmaExtras
import QtMultimedia
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    property var listModelController;
    property var promptArray: [];
    property bool isLoading: false
    property bool isAtBottom: true
    property var audioCache: ({})
    property string currentPlayingHash: ""
    
    hideOnWindowDeactivate: !Plasmoid.configuration.pin
    
    MediaPlayer {
        id: ttsPlayer
        audioOutput: AudioOutput {}
        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.StoppedState) {
                currentPlayingHash = "";
            }
        }
        onErrorOccurred: function(error, errorString) {
            currentPlayingHash = "";
        }
    }
    
    property var pendingTTSJobs: ({})
    property var pendingFuncCmd: null
    property var currentFuncSource: null

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            var exitCode = data["exit code"];
            for (var hash in pendingTTSJobs) {
                if (pendingTTSJobs[hash].command === sourceName) {
                    var jobInfo = pendingTTSJobs[hash];
                    if (exitCode === 0 && jobInfo.outputPath) {
                        Qt.callLater(function() {
                            audioCache[hash] = `file://${jobInfo.outputPath}`;
                            ttsPlayer.source = audioCache[hash];
                            ttsPlayer.play();
                        });
                    } else {
                        currentPlayingHash = "";
                    }
                    delete pendingTTSJobs[hash];
                    break;
                }
            }
            disconnectSource(sourceName);
        }
    }

    Plasma5Support.DataSource {
        id: funcExec
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            if (pendingFuncCmd && pendingFuncCmd.command === sourceName) {
                pendingFuncCmd.callback(data["stdout"] || "", data["exit code"]);
                pendingFuncCmd = null;
            }
            disconnectSource(sourceName);
        }
    }
    
    SyntaxHighlighter {
        id: syntaxHighlighter
    }
    
    SessionManager {
        id: sessionManager
        Component.onCompleted: {
            if (Plasmoid.configuration.enablePersistence) {
                init()
            }
        }
    }
    
    Connections {
        target: Plasmoid.configuration
        function onPinChanged() {
            root.hideOnWindowDeactivate = !Plasmoid.configuration.pin
        }
        function onEnablePersistenceChanged() {
            if (Plasmoid.configuration.enablePersistence) {
                sessionManager.init()
            }
        }
    }
    
    function getConfigColors() {
        return {
            codeBackgroundColor: Plasmoid.configuration.codeBackgroundColor,
            codeBackgroundOpacity: Plasmoid.configuration.codeBackgroundOpacity,
            codeFontFamily: Plasmoid.configuration.codeFontFamily,
            codeKeywordColor: Plasmoid.configuration.codeKeywordColor,
            codeStringColor: Plasmoid.configuration.codeStringColor,
            codeCommentColor: Plasmoid.configuration.codeCommentColor,
            codeFunctionColor: Plasmoid.configuration.codeFunctionColor,
            codeNumberColor: Plasmoid.configuration.codeNumberColor,
            codeTypeColor: Plasmoid.configuration.codeTypeColor,
            linkColor: Plasmoid.configuration.useCustomLinkColor ? 
                      Plasmoid.configuration.linkColor : "#4a9eff"
        };
    }

    function stripHtml(html) {
        var text = html.replace(/<[^>]*>/g, '');
        text = text.replace(/&nbsp;/g, ' ');
        text = text.replace(/&lt;/g, '<');
        text = text.replace(/&gt;/g, '>');
        text = text.replace(/&amp;/g, '&');
        text = text.replace(/'/g, "\\'");
        return text;
    }

    function hashString(str) {
        var hash = 0;
        for (var i = 0; i < str.length; i++) {
            var charCode = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + charCode;
            hash = hash & hash;
        }
        return Math.abs(hash).toString();
    }

    function escapeJsonString(str) {
        return str
            .replace(/\\/g, '\\\\')
            .replace(/"/g, '\\"')
            .replace(/\n/g, '\\n')
            .replace(/\r/g, '\\r')
            .replace(/\t/g, '\\t');
    }

    function utf8ToB64(str) {
        var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        var bytes = [];
        for (var i = 0; i < str.length; i++) {
            var c = str.charCodeAt(i);
            if (c < 128) bytes.push(c);
            else if (c < 2048) bytes.push(192 | (c >> 6), 128 | (c & 63));
            else bytes.push(224 | (c >> 12), 128 | ((c >> 6) & 63), 128 | (c & 63));
        }
        var result = "";
        for (var i = 0; i < bytes.length; i += 3) {
            var a = bytes[i], b = bytes[i+1] || 0, c2 = bytes[i+2] || 0;
            result += chars.charAt(a >> 2);
            result += chars.charAt(((a & 3) << 4) | (b >> 4));
            result += chars.charAt(((b & 15) << 2) | (c2 >> 6));
            result += chars.charAt(c2 & 63);
        }
        var pad = bytes.length % 3;
        if (pad === 1) result = result.slice(0, -2) + "==";
        else if (pad === 2) result = result.slice(0, -1) + "=";
        return result;
    }

    function getToolsDef() {
        return [{
            functionDeclarations: [{
                name: "list_directory",
                description: "Lists files and directories at the given absolute path. Returns one entry per line.",
                parameters: {
                    type: "object",
                    properties: { path: { type: "string", description: "Absolute path to directory" } },
                    required: ["path"]
                }
            }, {
                name: "read_text_file",
                description: "Reads the content of a text or code file. Returns up to 50000 characters.",
                parameters: {
                    type: "object",
                    properties: { path: { type: "string", description: "Absolute path to file" } },
                    required: ["path"]
                }
            }, {
                name: "write_text_file",
                description: "Writes or overwrites a text file, creating parent directories if needed.",
                parameters: {
                    type: "object",
                    properties: {
                        path: { type: "string", description: "Absolute path where to write" },
                        content: { type: "string", description: "Text content to write" }
                    },
                    required: ["path", "content"]
                }
            }, {
                name: "run_command",
                description: "Runs any shell command and returns its output.",
                parameters: {
                    type: "object",
                    properties: { command: { type: "string", description: "Shell command to execute" } },
                    required: ["command"]
                }
            }]
        }];
    }

    function handleFunctionCall(fc, listModel) {
        if (Plasmoid.configuration.showFunctionMessages) {
            var msg = fc.name;
            switch (fc.name) {
                case "list_directory": msg = Plasmoid.configuration.msgListDirectory; break;
                case "read_text_file": msg = Plasmoid.configuration.msgReadTextFile; break;
                case "write_text_file": msg = Plasmoid.configuration.msgWriteTextFile; break;
                case "run_command": msg = Plasmoid.configuration.msgRunCommand; break;
            }
            listModel.append({ name: "Function", number: msg });
        }
        executeNow(fc, listModel);
    }

    function executeNow(fc, listModel) {
        var cmd;
        if (fc.name === "list_directory") {
            cmd = 'ls -1a "' + fc.args.path + '" 2>&1 | head -100';
        } else if (fc.name === "read_text_file") {
            cmd = 'cat "' + fc.args.path + '" 2>&1 | head -c 50000';
        } else if (fc.name === "write_text_file") {
            var b64 = utf8ToB64(fc.args.content || "");
            var p = fc.args.path;
            cmd = 'echo ' + b64 + ' | base64 -d > /tmp/gemini_write.tmp 2>&1 && mkdir -p "$(dirname "' + p + '")" 2>&1 && cp /tmp/gemini_write.tmp "' + p + '" 2>&1';
        } else if (fc.name === "run_command") {
            cmd = fc.args.command + ' 2>&1';
        }
        if (cmd) {
            currentFuncSource = cmd;
            isLoading = true;
            pendingFuncCmd = { command: cmd, callback: function(out, code) {
                currentFuncSource = null;
                try {
                    var result = code === 0 ? { output: out } : { error: out, exit_code: code };
                    promptArray.push({ role: "function", parts: [{ functionResponse: { name: fc.name, response: result } }] });
                    sendApiRequest(listModel);
                } catch(e) {
                    promptArray.push({ role: "function", parts: [{ functionResponse: { name: fc.name, response: { error: "Callback error: " + e } } }] });
                    sendApiRequest(listModel);
                }
            }};
            funcExec.connectSource(cmd);
        }
    }

    function cancelCurrentCommand() {
        pendingFuncCmd = null;
        try {
            if (currentFuncSource) {
                funcExec.disconnectSource(currentFuncSource);
                currentFuncSource = null;
            }
        } catch(e) {}
        try {
            if (promptArray.length > 0) {
                var last = promptArray[promptArray.length - 1];
                if (last.role === "model" && last.parts && last.parts[0] && last.parts[0].functionCall) {
                    promptArray.pop();
                }
            }
        } catch(e) {}
        try {
            if (listModel.count > 0) {
                var lastItem = listModel.get(listModel.count - 1);
                if (lastItem.name === "Function") {
                    listModel.remove(listModel.count - 1);
                }
            }
        } catch(e) {}
        isLoading = false;
    }

    function getSafeContents() {
        var c = promptArray;
        if (Plasmoid.configuration.useCustomPrompt && Plasmoid.configuration.customSystemPrompt.trim() !== "") {
            c = [{ role: "user", parts: [{ text: Plasmoid.configuration.customSystemPrompt }] },
                 { role: "model", parts: [{ text: "Understood. I will follow these instructions." }] },
                 ...promptArray];
        }
        return c;
    }

    function sendApiRequest(listModel) {
        isLoading = true;
        var selectedModel = Plasmoid.configuration.selectedModel || "gemini-2.5-flash";
        var url = "https://generativelanguage.googleapis.com/v1beta/models/" + selectedModel + ":generateContent?key=" + Plasmoid.configuration.apiKey;
        var body = { contents: getSafeContents() };
        if (Plasmoid.configuration.enableFileOps) body.tools = getToolsDef();
        var xhr = new XMLHttpRequest();
        xhr.open("POST", url, true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    var part = response.candidates[0].content.parts[0];
                    if (part.functionCall) {
                        promptArray.push({ role: "model", parts: [part] });
                        handleFunctionCall(part.functionCall, listModel);
                    } else if (part.text) {
                        var formatted = syntaxHighlighter.formatText(part.text, getConfigColors());
                        listModel.append({ name: "Assistant", number: formatted });
                        promptArray.push({ role: "model", parts: [{ text: part.text }] });
                        isLoading = false;
                        if (Plasmoid.configuration.enablePersistence)
                            sessionManager.saveSession(selectedModel, promptArray);
                    }
                } else {
                    var msg = "<b>Error " + xhr.status + ":</b> ";
                    if (xhr.status === 404) msg += "The Gemini model is not available.";
                    else if (xhr.status === 401) msg += "Invalid API key. Check settings.";
                    else if (xhr.status === 403) msg += "Access forbidden. Check API key permissions.";
                    else if (xhr.status === 429) msg += "Rate limit exceeded. Try again later.";
                    else if (xhr.status >= 500) msg += "Google AI service unavailable.";
                    else {
                        msg += xhr.statusText;
                        try {
                            var err = JSON.parse(xhr.responseText);
                            if (err.error && err.error.message) msg += "<br><i>" + err.error.message + "</i>";
                        } catch(e) {
                            if (xhr.responseText && xhr.responseText.length < 200) msg += "<br><i>" + xhr.responseText + "</i>";
                        }
                    }
            listModel.append({ name: "Assistant", number: msg });
                    isLoading = false;
                }
            }
        };
        xhr.send(JSON.stringify(body));
    }

    function getTTSCommand(cleanText, messageHash) {
        var provider = Plasmoid.configuration.ttsProvider || "elevenlabs";
        var escapedText = escapeJsonString(cleanText);
        var outputPath;
        var cmd;

        if (provider === "elevenlabs") {
            var apiKey = Plasmoid.configuration.elevenlabsApiKey;
            var voiceId = Plasmoid.configuration.elevenlabsVoiceId || "pNInz6obpgDQGcFmaJgB";
            if (!apiKey) return null;
            outputPath = `/tmp/tts_${messageHash}.mp3`;
            cmd = `rm -f ${outputPath}; curl -s -X POST 'https://api.elevenlabs.io/v1/text-to-speech/${voiceId}/stream?optimize_streaming_latency=3' -H 'xi-api-key: ${apiKey}' -H 'Content-Type: application/json' -d '{"text":"${escapedText}","model_id":"eleven_multilingual_v2"}' -o ${outputPath}`;
        } else if (provider === "openai") {
            var apiKey = Plasmoid.configuration.openaiApiKey;
            var voice = Plasmoid.configuration.openaiVoice || "alloy";
            var model = Plasmoid.configuration.openaiModel || "tts-1";
            if (!apiKey) return null;
            outputPath = `/tmp/tts_${messageHash}.mp3`;
            cmd = `rm -f ${outputPath}; curl -s -X POST 'https://api.openai.com/v1/audio/speech' -H 'Authorization: Bearer ${apiKey}' -H 'Content-Type: application/json' -d '{"model":"${model}","input":"${escapedText}","voice":"${voice}"}' -o ${outputPath}`;
        } else if (provider === "espeak") {
            var voice = Plasmoid.configuration.espeakVoice || "en";
            var speed = Plasmoid.configuration.espeakSpeed || 175;
            var pitch = Plasmoid.configuration.espeakPitch || 50;
            outputPath = `/tmp/tts_${messageHash}.wav`;
            var shellText = cleanText.replace(/'/g, "'\\''");
            cmd = `rm -f ${outputPath}; espeak-ng -v ${voice} -s ${speed} -p ${pitch} -w ${outputPath} '${shellText}'`;
        } else if (provider === "piper") {
            var modelPath = Plasmoid.configuration.piperModelPath;
            if (!modelPath) return null;
            outputPath = `/tmp/tts_${messageHash}.wav`;
            var shellText = cleanText.replace(/'/g, "'\\''");
            cmd = `rm -f ${outputPath}; echo '${shellText}' | piper --model '${modelPath}' --output_file ${outputPath}`;
        } else {
            return null;
        }

        return { command: cmd, outputPath: outputPath };
    }

    function playTTS(text, messageHash) {
        if (!Plasmoid.configuration.enableTTS) return;

        var provider = Plasmoid.configuration.ttsProvider || "elevenlabs";

        if (provider === "dsnote") {
            var dsnoteCmd = Plasmoid.configuration.dsnoteCommand;
            if (!dsnoteCmd || dsnoteCmd.trim() === "") return;
            if (currentPlayingHash === messageHash) {
                executable.connectSource(dsnoteCmd + ' --action cancel');
                currentPlayingHash = "";
                return;
            }
            currentPlayingHash = messageHash;
            var cleanText = stripHtml(text);
            var shellText = cleanText.replace(/'/g, "'\\''");
            var cmd = dsnoteCmd + " --action start-reading-text --text '" + shellText + "'";
            pendingTTSJobs[messageHash] = { command: cmd };
            executable.connectSource(cmd);
            return;
        }

        if (currentPlayingHash === messageHash) {
            ttsPlayer.stop();
            currentPlayingHash = "";
            return;
        }
        ttsPlayer.stop();
        currentPlayingHash = messageHash;
        var cleanText = stripHtml(text);
        if (audioCache[messageHash]) {
            ttsPlayer.source = audioCache[messageHash];
            ttsPlayer.play();
            return;
        }
        var ttsCmd = getTTSCommand(cleanText, messageHash);
        if (!ttsCmd) {
            currentPlayingHash = "";
            return;
        }
        pendingTTSJobs[messageHash] = ttsCmd;
        executable.connectSource(ttsCmd.command);
    }

    function request(messageField, listModel, prompt) {
        if (!Plasmoid.configuration.apiKey || Plasmoid.configuration.apiKey.trim() === '') {
            listModel.append({
                "name": "Assistant",
                "number": "<b>Error:</b> Please configure your Google AI Studio API Key in the widget settings."
            });
            return;
        }

        if (!prompt || prompt.trim() === '') return;

        listModel.append({ "name": "User", "number": prompt });
        promptArray.push({ "role": "user", "parts": [{ "text": prompt }] });

        sendApiRequest(listModel);
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Keep Open")
            icon.name: "window-pin"
            checkable: true
            checked: Plasmoid.configuration.pin
            onTriggered: {
                Plasmoid.configuration.pin = checked
                root.hideOnWindowDeactivate = !checked
            }
        },
        PlasmaCore.Action {
            text: i18n("Clear chat")
            icon.name: "edit-clear"
            onTriggered: {
                listModelController.clear();
                promptArray = [];
            }
        }
    ]

    compactRepresentation: CompactRepresentation {}

    fullRepresentation: ColumnLayout {
        Layout.preferredHeight: 400
        Layout.preferredWidth: 350
        Layout.fillWidth: true
        Layout.fillHeight: true

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Plasmoid.configuration.useCustomBackgroundColor ? 
                   Qt.rgba(Plasmoid.configuration.backgroundColor.r,
                           Plasmoid.configuration.backgroundColor.g,
                           Plasmoid.configuration.backgroundColor.b,
                           Plasmoid.configuration.backgroundOpacity) : "transparent"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0

        PlasmaExtras.PlasmoidHeading {
            Layout.fillWidth: true
            visible: Plasmoid.configuration.showPinButton || Plasmoid.configuration.showClearButton || Plasmoid.configuration.enablePersistence

            contentItem: RowLayout {
                Layout.fillWidth: true

                PlasmaComponents.Button {
                    id: pinButton
                    visible: Plasmoid.configuration.showPinButton
                    checkable: true
                    checked: Plasmoid.configuration.pin
                    onToggled: {
                        Plasmoid.configuration.pin = checked
                        root.hideOnWindowDeactivate = !checked
                    }
                    icon.name: checked ? "window-pin" : "window-unpin"

                    display: PlasmaComponents.AbstractButton.IconOnly
                    text: checked ? i18n("Unpin") : i18n("Keep Open")

                    PlasmaComponents.ToolTip.text: text
                    PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PlasmaComponents.ToolTip.visible: hovered
                }
                
                PlasmaComponents.ComboBox {
                    id: sessionSelector
                    visible: Plasmoid.configuration.enablePersistence
                    Layout.fillWidth: true
                    textRole: "title"
                    valueRole: "id"
                    
                    model: {
                        var filtered = []
                        for (var i = 0; i < sessionManager.sessions.length; i++) {
                            var sess = sessionManager.sessions[i]
                            if (sess.id !== sessionManager.currentSessionId || (promptArray && promptArray.length > 0)) {
                                filtered.push(sess)
                            }
                        }
                        return filtered
                    }
                    
                    displayText: {
                        if (!sessionManager.currentSessionId || promptArray.length === 0) {
                            return ""
                        }
                        for (var i = 0; i < sessionManager.sessions.length; i++) {
                            if (sessionManager.sessions[i].id === sessionManager.currentSessionId) {
                                return sessionManager.sessions[i].title
                            }
                        }
                        return ""
                    }
                    
                    onActivated: function(index) {
                        var filtered = []
                        for (var i = 0; i < sessionManager.sessions.length; i++) {
                            var sess = sessionManager.sessions[i]
                            if (sess.id !== sessionManager.currentSessionId || (promptArray && promptArray.length > 0)) {
                                filtered.push(sess)
                            }
                        }
                        
                        if (index >= 0 && index < filtered.length) {
                            var session = sessionManager.loadSession(filtered[index].id)
                            if (session) {
                                listModelController.clear()
                                promptArray = session.messages
                                
                            for (var i = 0; i < session.messages.length; i++) {
                                var msg = session.messages[i]
                                if (!msg.parts[0].text) continue
                                var displayText = msg.parts[0].text
                                
                                if (msg.role === "model") {
                                    displayText = syntaxHighlighter.formatText(displayText, getConfigColors())
                                }
                                
                                listModelController.append({
                                    "name": msg.role === "user" ? "User" : "Assistant",
                                    "number": displayText
                                })
                            }
                            }
                        }
                    }
                    
                    Connections {
                        target: sessionManager
                        function onSessionsUpdated() {
                            sessionSelector.model = Qt.binding(function() {
                                var filtered = []
                                for (var i = 0; i < sessionManager.sessions.length; i++) {
                                    var sess = sessionManager.sessions[i]
                                    if (sess.id !== sessionManager.currentSessionId || (promptArray && promptArray.length > 0)) {
                                        filtered.push(sess)
                                    }
                                }
                                return filtered
                            })
                        }
                    }
                }
                
                PlasmaComponents.Button {
                    visible: Plasmoid.configuration.enablePersistence
                    icon.name: "document-edit"
                    display: PlasmaComponents.AbstractButton.IconOnly
                    text: i18n("Edit session title")
                    enabled: sessionManager.currentSessionId !== ""
                    
                    onClicked: {
                        editDialog.open()
                    }
                    
                    PlasmaComponents.ToolTip.text: text
                    PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PlasmaComponents.ToolTip.visible: hovered
                }
                
                PlasmaComponents.Button {
                    visible: Plasmoid.configuration.enablePersistence
                    icon.name: "delete"
                    display: PlasmaComponents.AbstractButton.IconOnly
                    text: i18n("Delete session")
                    enabled: sessionManager.currentSessionId !== ""
                    
                    onClicked: {
                        deleteDialog.open()
                    }
                    
                    PlasmaComponents.ToolTip.text: text
                    PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PlasmaComponents.ToolTip.visible: hovered
                }
                
                PlasmaComponents.Button {
                    visible: Plasmoid.configuration.enablePersistence
                    icon.name: "list-add"
                    display: PlasmaComponents.AbstractButton.IconOnly
                    text: i18n("New session")
                    
                    onClicked: {
                        listModelController.clear()
                        promptArray = []
                        sessionManager.createSession()
                    }
                    
                    PlasmaComponents.ToolTip.text: text
                    PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PlasmaComponents.ToolTip.visible: hovered
                }

                Item {
                    Layout.fillWidth: !sessionSelector.visible
                    visible: !sessionSelector.visible
                }

                PlasmaComponents.Button {
                    visible: Plasmoid.configuration.showClearButton && !Plasmoid.configuration.enablePersistence
                    icon.name: "edit-clear-symbolic"
                    text: i18n("Clear chat")
                    display: PlasmaComponents.AbstractButton.IconOnly
                    enabled: !isLoading
                    hoverEnabled: !isLoading

                    onClicked: {
                        listModelController.clear();
                        promptArray = [];
                    }

                    PlasmaComponents.ToolTip.text: text
                    PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PlasmaComponents.ToolTip.visible: hovered
                }
            }
        }
        
        PlasmaComponents.Dialog {
            id: editDialog
            title: i18n("Edit Title")
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: 300
            
            standardButtons: PlasmaComponents.Dialog.Ok | PlasmaComponents.Dialog.Cancel
            
            onAccepted: {
                var newTitle = titleField.text.trim()
                sessionManager.updateSessionTitle(sessionManager.currentSessionId, newTitle)
                titleField.text = ""
            }
            
            onRejected: {
                titleField.text = ""
            }
            
            ColumnLayout {
                width: parent.width
                spacing: Kirigami.Units.largeSpacing
                
                PlasmaComponents.TextField {
                    id: titleField
                    Layout.fillWidth: true
                    placeholderText: i18n("Enter title")
                    
                    Component.onCompleted: {
                        if (editDialog.visible) {
                            titleField.text = sessionManager.getCurrentSessionTitle()
                            titleField.selectAll()
                        }
                    }
                    
                    Connections {
                        target: editDialog
                        function onVisibleChanged() {
                            if (editDialog.visible) {
                                titleField.text = sessionManager.getCurrentSessionTitle()
                                titleField.forceActiveFocus()
                                titleField.selectAll()
                            }
                        }
                    }
                }
            }
        }
        
        PlasmaComponents.Dialog {
            id: deleteDialog
            title: i18n("Delete Session")
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: 300
            
            standardButtons: PlasmaComponents.Dialog.Yes | PlasmaComponents.Dialog.No
            
            onAccepted: {
                sessionManager.deleteSession(sessionManager.currentSessionId)
                listModelController.clear()
                promptArray = []
            }
            
            ColumnLayout {
                width: parent.width
                spacing: Kirigami.Units.largeSpacing
                
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: i18n("Delete this session?")
                    wrapMode: Text.WordWrap
                }
            }
        }

        ScrollView {
            id: chatScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 150
            
            clip: true
            
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: Plasmoid.configuration.hideScrollBar ? ScrollBar.AlwaysOff : ScrollBar.AsNeeded
            
            ListView {
                id: listView
                implicitWidth: chatScrollView.availableWidth
                
                spacing: Kirigami.Units.smallSpacing
                
                boundsBehavior: Flickable.StopAtBounds
                interactive: true
                flickableDirection: Flickable.VerticalFlick
                
                onMovingChanged: {
                    if (!moving) {
                        updateIsAtBottom();
                    }
                }
                
                onContentYChanged: {
                    if (!moving && !dragging) {
                        updateIsAtBottom();
                    }
                }
                
                function updateIsAtBottom() {
                    var atEnd = contentHeight <= height ? true : (contentY + height >= contentHeight - 10);
                    isAtBottom = atEnd;
                }

                Kirigami.PlaceholderMessage {
                    anchors.centerIn: parent
                    width: parent.width - (Kirigami.Units.largeSpacing * 4)
                    visible: listView.count === 0 && Plasmoid.configuration.showEmptyPlaceholder
                    text: {
                        if (!Plasmoid.configuration.apiKey || Plasmoid.configuration.apiKey.trim() === '') {
                            return i18n("Please configure your Google AI Studio API Key in the widget settings first.");
                        }
                        if (Plasmoid.configuration.useCustomPlaceholders && Plasmoid.configuration.emptyPlaceholder.trim() !== '') {
                            return Plasmoid.configuration.emptyPlaceholder;
                        }
                        return i18n("I am waiting for your questions...");
                    }
                }

                model: ListModel {
                    id: listModel

                    Component.onCompleted: {
                        listModelController = listModel;
                    }
                }

                delegate: Kirigami.AbstractCard {
                    width: listView.width
                    height: textMessage.implicitHeight + 16
                    
                    background: Rectangle {
                        color: {
                            if (name === "User" && Plasmoid.configuration.useCustomUserMessageColor) {
                                return Qt.rgba(Plasmoid.configuration.userMessageColor.r,
                                             Plasmoid.configuration.userMessageColor.g,
                                             Plasmoid.configuration.userMessageColor.b,
                                             Plasmoid.configuration.userMessageOpacity);
                            } else if (name === "Assistant" && Plasmoid.configuration.useCustomAssistantMessageColor) {
                                return Qt.rgba(Plasmoid.configuration.assistantMessageColor.r,
                                             Plasmoid.configuration.assistantMessageColor.g,
                                             Plasmoid.configuration.assistantMessageColor.b,
                                             Plasmoid.configuration.assistantMessageOpacity);
                            } else if (name === "Function" && Plasmoid.configuration.useCustomFunctionMessageColor) {
                                return Qt.rgba(Plasmoid.configuration.functionMessageColor.r,
                                             Plasmoid.configuration.functionMessageColor.g,
                                             Plasmoid.configuration.functionMessageColor.b,
                                             Plasmoid.configuration.functionMessageOpacity);
                            }
                            return Kirigami.Theme.backgroundColor;
                        }
                        radius: 5
                    }

                    contentItem: TextEdit {
                        id: textMessage

                        topPadding: 8
                        bottomPadding: 8
                        leftPadding: 8
                        rightPadding: 8
                        readOnly: true
                        wrapMode: Text.WordWrap
                        text: number
                        textFormat: TextEdit.RichText
                        width: parent.width
                        Layout.maximumWidth: parent.width
                        color: {
                            if (name === "User" && Plasmoid.configuration.useCustomUserTextColor) {
                                return Plasmoid.configuration.userTextColor;
                            } else if (name === "Assistant" && Plasmoid.configuration.useCustomAssistantTextColor) {
                                return Plasmoid.configuration.assistantTextColor;
                            } else if (name === "Function" && Plasmoid.configuration.useCustomFunctionTextColor) {
                                return Plasmoid.configuration.functionTextColor;
                            }
                            return name === "User" ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor;
                        }
                        selectByMouse: true
                        selectionColor: Plasmoid.configuration.useCustomSelectionColor ?
                                       Qt.rgba(Plasmoid.configuration.selectionColor.r,
                                             Plasmoid.configuration.selectionColor.g,
                                             Plasmoid.configuration.selectionColor.b,
                                             Plasmoid.configuration.selectionOpacity) :
                                       Kirigami.Theme.highlightColor
                        
                        font.family: Plasmoid.configuration.useCustomFont ? 
                                    Plasmoid.configuration.customFontFamily : Kirigami.Theme.defaultFont.family
                        font.pointSize: Plasmoid.configuration.useCustomFont ? 
                                       Plasmoid.configuration.customFontSize : Kirigami.Theme.defaultFont.pointSize
                        
                        onLinkActivated: function(link) {
                            Qt.openUrlExternally(link);
                        }
                        
                        onLinkHovered: function(link) {
                            if (link) {
                                textMessage.cursorShape = Qt.PointingHandCursor;
                            } else {
                                textMessage.cursorShape = Qt.IBeamCursor;
                            }
                        }

                        PlasmaComponents.Button {
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.rightMargin: name === "Assistant" && Plasmoid.configuration.enableTTS && Plasmoid.configuration.showCopyButton ? 40 : 0
                            visible: name !== "Function" && Plasmoid.configuration.showCopyButton && hoverHandler.hovered

                            icon.name: "edit-copy-symbolic"
                            text: i18n("Copy")
                            display: PlasmaComponents.AbstractButton.IconOnly
                            
                            onClicked: {
                                textMessage.selectAll();
                                textMessage.copy();
                                textMessage.deselect();
                            }

                            PlasmaComponents.ToolTip.text: text
                            PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                            PlasmaComponents.ToolTip.visible: hovered
                        }

                        PlasmaComponents.Button {
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            visible: name === "Assistant" && Plasmoid.configuration.enableTTS && hoverHandler.hovered

                            icon.name: currentPlayingHash === hashString(number) ? "media-playback-stop" : "audio-volume-high"
                            text: currentPlayingHash === hashString(number) ? i18n("Stop") : i18n("Play")
                            display: PlasmaComponents.AbstractButton.IconOnly
                            
                            onClicked: {
                                playTTS(number, hashString(number));
                            }

                            PlasmaComponents.ToolTip.text: text
                            PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                            PlasmaComponents.ToolTip.visible: hovered
                        }

                        PlasmaComponents.Button {
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            visible: name === "Function" && root.isLoading && hoverHandler.hovered

                            icon.name: "process-stop"
                            text: i18n("Cancel")
                            display: PlasmaComponents.AbstractButton.IconOnly

                            onClicked: {
                                root.cancelCurrentCommand();
                            }

                            PlasmaComponents.ToolTip.text: text
                            PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                            PlasmaComponents.ToolTip.visible: hovered
                        }

                        HoverHandler {
                            id: hoverHandler
                        }
                    }
                }
                
                PlasmaComponents.Button {
                    id: scrollToBottomButton
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 10
                    anchors.bottomMargin: 10
                    visible: Plasmoid.configuration.showScrollToBottomButton && !isAtBottom && listView.count > 0
                    icon.name: "go-down"
                    display: PlasmaComponents.AbstractButton.IconOnly
                    text: i18n("Scroll to bottom")
                    z: 999
                    
                    onClicked: {
                        listView.positionViewAtEnd();
                    }
                    
                    PlasmaComponents.ToolTip.text: text
                    PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PlasmaComponents.ToolTip.visible: hovered
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
                Layout.minimumHeight: 40
                Layout.maximumHeight: 120
                
                Rectangle {
                    anchors.fill: parent
                    color: Plasmoid.configuration.useCustomInputColor ?
                           Qt.rgba(Plasmoid.configuration.inputBackgroundColor.r,
                                  Plasmoid.configuration.inputBackgroundColor.g,
                                  Plasmoid.configuration.inputBackgroundColor.b,
                                  Plasmoid.configuration.inputOpacity) : 
                           Kirigami.Theme.backgroundColor
                    radius: 5
                }
                
                ScrollView {
                    id: messageScrollView
                    anchors.fill: parent
                    clip: true
                    
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                    
                    background: Item {}

                    TextArea {
                        id: messageField
                        width: messageScrollView.availableWidth

                        enabled: !isLoading
                        hoverEnabled: !isLoading
                        visible: !isLoading
                        placeholderText: {
                            if (!Plasmoid.configuration.showInputPlaceholder) {
                                return "";
                            }
                            if (Plasmoid.configuration.useCustomPlaceholders && Plasmoid.configuration.inputPlaceholder.trim() !== '') {
                                return Plasmoid.configuration.inputPlaceholder;
                            }
                            return i18n("Type here what you want to ask...");
                        }
                        wrapMode: TextArea.Wrap
                        selectByMouse: true
                        color: Plasmoid.configuration.useCustomInputTextColor ?
                               Plasmoid.configuration.inputTextColor : Kirigami.Theme.textColor
                        placeholderTextColor: Plasmoid.configuration.useCustomInputTextColor ?
                               Qt.rgba(Plasmoid.configuration.inputTextColor.r,
                                      Plasmoid.configuration.inputTextColor.g,
                                      Plasmoid.configuration.inputTextColor.b,
                                      0.5) : Qt.rgba(Kirigami.Theme.textColor.r,
                                                    Kirigami.Theme.textColor.g,
                                                    Kirigami.Theme.textColor.b,
                                                    0.5)
                        selectionColor: Plasmoid.configuration.useCustomSelectionColor ?
                                       Qt.rgba(Plasmoid.configuration.selectionColor.r,
                                             Plasmoid.configuration.selectionColor.g,
                                             Plasmoid.configuration.selectionColor.b,
                                             Plasmoid.configuration.selectionOpacity) :
                                       Kirigami.Theme.highlightColor
                        
                        font.family: Plasmoid.configuration.useCustomFont ? 
                                    Plasmoid.configuration.customFontFamily : Kirigami.Theme.defaultFont.family
                        font.pointSize: Plasmoid.configuration.useCustomFont ? 
                                       Plasmoid.configuration.customFontSize : Kirigami.Theme.defaultFont.pointSize
                        
                        background: Item {}

                        Keys.onReturnPressed: {
                            if (event.modifiers & Qt.ControlModifier) {
                                messageField.text = messageField.text + "\n";
                            } else {
                                request(messageField, listModel, messageField.text);
                                event.accepted = true;
                            }
                        }
                        
                        onVisibleChanged: {
                            if (visible) {
                                messageField.text = '';
                                messageField.cursorPosition = 0;
                            }
                        }
                    }
                }
                
                BusyIndicator {
                    id: indicator
                    anchors.centerIn: parent
                    running: isLoading
                    visible: isLoading
                }
            }

            PlasmaComponents.Button {
                visible: Plasmoid.configuration.showPasteButton
                Layout.alignment: Qt.AlignVCenter
                icon.name: "edit-paste-symbolic"
                display: PlasmaComponents.AbstractButton.IconOnly
                text: i18n("Paste")
                hoverEnabled: !isLoading
                enabled: !isLoading

                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: "Paste from clipboard"
                
                onClicked: {
                    messageField.paste();
                }
            }

            PlasmaComponents.Button {
                visible: Plasmoid.configuration.showSendButton
                Layout.alignment: Qt.AlignVCenter
                icon.name: "document-send"
                display: PlasmaComponents.AbstractButton.IconOnly
                text: i18n("Send")
                hoverEnabled: !isLoading
                enabled: !isLoading

                ToolTip.delay: 1000
                ToolTip.visible: hovered
                ToolTip.text: "Enter to send, CTRL+Enter for new line"
                
                onClicked: {
                    request(messageField, listModel, messageField.text);
                }
            }
        }
            }
        }
    }
}