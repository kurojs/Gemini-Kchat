import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_apiKey: apiKeyField.text

    Kirigami.FormLayout {

        QQC2.TextField {
            id: apiKeyField
            Kirigami.FormData.label: i18nc("@label", "Google AI Studio API Key:")
            placeholderText: i18nc("@info:placeholder", "Enter your API key here...")
            echoMode: TextInput.Password
            Layout.fillWidth: true
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            type: Kirigami.MessageType.Information
            text: i18nc("@info", "Get your free API key from Google AI Studio")
            actions: [
                Kirigami.Action {
                    text: i18nc("@action:button", "Open Google AI Studio")
                    icon.name: "internet-services"
                    onTriggered: Qt.openUrlExternally("https://makersuite.google.com/app/apikey")
                }
            ]
        }
    }
}
