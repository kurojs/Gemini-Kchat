import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.extras as PlasmaExtras

PlasmoidItem {
    id: root

    property var listModelController;
    property var promptArray: [];
    property bool isLoading: false
    property bool isAtBottom: true
    
    hideOnWindowDeactivate: !Plasmoid.configuration.pin
    
    SyntaxHighlighter {
        id: syntaxHighlighter
    }
    
    Connections {
        target: Plasmoid.configuration
        function onPinChanged() {
            root.hideOnWindowDeactivate = !Plasmoid.configuration.pin
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

    function request(messageField, listModel, prompt) {
        if (!Plasmoid.configuration.apiKey || Plasmoid.configuration.apiKey.trim() === '') {
            listModel.append({
                "name": "Assistant",
                "number": "<b>Error:</b> Please configure your Google AI Studio API Key in the widget settings."
            });
            return;
        }

        if (!prompt || prompt.trim() === '') {
            return;
        }

        listModel.append({
            "name": "User",
            "number": prompt
        });

        promptArray.push({ "role": "user", "parts": [{ "text": prompt }] });

        isLoading = true;

        const oldLength = listModel.count;
        const selectedModel = Plasmoid.configuration.selectedModel || "gemini-2.5-flash";
        const url = `https://generativelanguage.googleapis.com/v1beta/models/${selectedModel}:generateContent?key=${Plasmoid.configuration.apiKey}`;
        
        var contents = promptArray;
        
        if (Plasmoid.configuration.useCustomPrompt && Plasmoid.configuration.customSystemPrompt.trim() !== '') {
            contents = [
                { "role": "user", "parts": [{ "text": Plasmoid.configuration.customSystemPrompt }] },
                { "role": "model", "parts": [{ "text": "Understood. I will follow these instructions." }] },
                ...promptArray
            ];
        }
        
        const data = JSON.stringify({
            "contents": contents
        });
        
        let xhr = new XMLHttpRequest();

        xhr.open('POST', url, true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    const response = JSON.parse(xhr.responseText);
                    let text = response.candidates[0].content.parts[0].text;
                    
                    text = syntaxHighlighter.formatText(text, getConfigColors());

                    if (listModel.count === oldLength) {
                        listModel.append({
                            "name": "Assistant",
                            "number": text
                        });
                    } else {
                        listView.currentIndex = oldLength;
                        const lastValue = listModel.get(oldLength);
                        if (lastValue) {
                            lastValue.number = text;
                        }
                    }
                    promptArray.push({ "role": "model", "parts": [{ "text": response.candidates[0].content.parts[0].text }] });
                } else {
                    let errorMessage = `<b>Error ${xhr.status}:</b> `;
                    
                    if (xhr.status === 404) {
                        errorMessage += "The Gemini model is not available. This might be due to an outdated model name or API version issue.";
                    } else if (xhr.status === 401) {
                        errorMessage += "Invalid API key. Please check your Google AI Studio API key in the widget settings.";
                    } else if (xhr.status === 403) {
                        errorMessage += "Access forbidden. Check your API key permissions and billing settings in Google AI Studio.";
                    } else if (xhr.status === 429) {
                        errorMessage += "Rate limit exceeded. Please try again in a few moments.";
                    } else if (xhr.status >= 500) {
                        errorMessage += "Google AI service is temporarily unavailable. Please try again later.";
                    } else {
                        errorMessage += xhr.statusText;
                        try {
                            const errorData = JSON.parse(xhr.responseText);
                            if (errorData.error && errorData.error.message) {
                                errorMessage += "<br><br><i>Details: " + errorData.error.message + "</i>";
                            }
                        } catch (e) {
                            if (xhr.responseText && xhr.responseText.length < 200) {
                                errorMessage += "<br><br><i>Details: " + xhr.responseText + "</i>";
                            }
                        }
                    }
                    
                    listModel.append({
                        "name": "Assistant",
                        "number": errorMessage
                    });
                }
                isLoading = false;
            }
        };

        xhr.send(data);
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
            visible: Plasmoid.configuration.showPinButton || Plasmoid.configuration.showClearButton

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

                Item {
                    Layout.fillWidth: true
                }

                PlasmaComponents.Button {
                    visible: Plasmoid.configuration.showClearButton
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
                
                onContentHeightChanged: {
                    if (isAtBottom && !listView.moving) {
                        positionViewAtEnd();
                    }
                }
                
                onHeightChanged: {
                    updateIsAtBottom();
                }
                
                onContentYChanged: {
                    updateIsAtBottom();
                }
                
                function updateIsAtBottom() {
                    if (moving || dragging) return;
                    var atEnd = contentHeight <= height ? true : (contentY + height >= contentHeight - 1);
                    if (isAtBottom !== atEnd) {
                        isAtBottom = atEnd;
                    }
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
                            visible: Plasmoid.configuration.showCopyButton && hoverHandler.hovered

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
                        isAtBottom = true;
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