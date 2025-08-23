/*
    SPDX-FileCopyrightText: 2023 Denys Madureira <denysmb@zoho.com>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

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
    
    hideOnWindowDeactivate: !Plasmoid.configuration.pin
    
    Connections {
        target: Plasmoid.configuration
        function onPinChanged() {
            root.hideOnWindowDeactivate = !Plasmoid.configuration.pin
        }
    }

    function request(messageField, listModel, prompt) {
        // Validar que hay API key configurada
        if (!Plasmoid.configuration.apiKey || Plasmoid.configuration.apiKey.trim() === '') {
            listModel.append({
                "name": "Assistant",
                "number": "<b>Error:</b> Please configure your Google AI Studio API Key in the widget settings."
            });
            return;
        }

        messageField.text = '';

        listModel.append({
            "name": "User",
            "number": prompt
        });

        promptArray.push({ "role": "user", "parts": [{ "text": prompt }] });

        isLoading = true;

        const oldLength = listModel.count;
        const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${Plasmoid.configuration.apiKey}`;
        const data = JSON.stringify({
            "contents": promptArray
        });
        
        let xhr = new XMLHttpRequest();

        xhr.open('POST', url, true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    const response = JSON.parse(xhr.responseText);
                    const text = response.candidates[0].content.parts[0].text.replace(/\n/g, "<br>").replace(/\*\*([^*]+)\*\*/g, "<b>$1</b>");

                    if (listModel.count === oldLength) {
                        listModel.append({
                            "name": "Assistant",
                            "number": text
                        });
                    } else {
                        const lastValue = listModel.get(oldLength);
                        lastValue.number = text;
                    }
                    promptArray.push({ "role": "model", "parts": [{ "text": text }] });
                } else {
                    console.error('Erro na requisição:', xhr.status, xhr.statusText, xhr.responseText);
                    listModel.append({
                        "name": "Assistant",
                        "number": "Error: " + xhr.statusText + "\n" + xhr.responseText
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

        

        PlasmaExtras.PlasmoidHeading {
            Layout.fillWidth: true

            contentItem: RowLayout {
                Layout.fillWidth: true

                PlasmaComponents.Button {
                    id: pinButton
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
            id: scrollView

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 150
            clip: true

            ListView {
                id: listView
                spacing: Kirigami.Units.smallSpacing

                Layout.fillWidth: true
                Layout.fillHeight: true

                Kirigami.PlaceholderMessage {
                    anchors.centerIn: parent
                    width: parent.width - (Kirigami.Units.largeSpacing * 4)
                    visible: listView.count === 0
                    text: (!Plasmoid.configuration.apiKey || Plasmoid.configuration.apiKey.trim() === '') ? 
                           i18n("Please configure your Google AI Studio API Key in the widget settings first.") :
                           i18n("I am waiting for your questions...")
                }

                model: ListModel {
                    id: listModel

                    Component.onCompleted: {
                        listModelController = listModel;
                    }
                }

                delegate: Kirigami.AbstractCard {
                    Layout.fillWidth: true
                    implicitHeight: 24 + textMessage.implicitHeight

                    contentItem: TextEdit {
                        id: textMessage

                        topPadding: 8
                        readOnly: true
                        wrapMode: Text.WordWrap
                        text: number
                        textFormat: TextEdit.RichText
                        color: name === "User" ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor

                        PlasmaComponents.Button {
                            anchors.right: parent.right

                            icon.name: "edit-copy-symbolic"
                            text: i18n("Copy")
                            display: PlasmaComponents.AbstractButton.IconOnly
                            visible: hoverHandler.hovered
                            
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
            }
        }

        RowLayout {
            Layout.fillWidth: true

            ScrollView {
                id: messageScrollView
                Layout.fillWidth: true
                Layout.minimumHeight: 40
                Layout.maximumHeight: 120
                clip: true
                
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                TextArea {
                    id: messageField

                    enabled: !isLoading
                    hoverEnabled: !isLoading
                    placeholderText: i18n("Type here what you want to ask...")
                    wrapMode: TextArea.Wrap
                    selectByMouse: true

                    Keys.onReturnPressed: {
                        if (event.modifiers & Qt.ControlModifier) {
                            messageField.text = messageField.text + "\n";
                        } else {
                            request(messageField, listModel, messageField.text);
                            event.accepted = true;
                        }
                    }

                    BusyIndicator {
                        id: indicator
                        anchors.centerIn: parent
                        running: isLoading
                    }
                }
            }

            PlasmaComponents.Button {
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