import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_useCustomPrompt: useCustomPrompt.checked
    property alias cfg_customSystemPrompt: customSystemPrompt.text
    
    Kirigami.FormLayout {
        
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            type: Kirigami.MessageType.Information
            text: i18nc("@info", "Define a custom personality or system instructions for the AI. This will be prepended to every conversation.")
            visible: true
        }
        
        QQC2.CheckBox {
            id: useCustomPrompt
            Kirigami.FormData.label: i18nc("@option:check", "Custom AI personality:")
            text: i18nc("@option:check", "Enable custom system prompt")
        }
        
        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            enabled: useCustomPrompt.checked
            
            QQC2.TextArea {
                id: customSystemPrompt
                placeholderText: i18nc("@info:placeholder", "Example: You are a helpful, friendly assistant who explains things clearly and concisely. Always use a professional tone...")
                wrapMode: TextArea.Wrap
            }
        }
    }
}