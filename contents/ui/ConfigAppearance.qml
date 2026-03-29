import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_apiKey: apiKeyField.text
    property string cfg_selectedModel
    
    Kirigami.FormLayout {

        QQC2.TextField {
            id: apiKeyField
            Kirigami.FormData.label: i18nc("@label", "Google AI Studio API Key:")
            placeholderText: i18nc("@info:placeholder", "Enter your API key here...")
            echoMode: TextInput.Password
            Layout.fillWidth: true
        }

        QQC2.ComboBox {
            id: modelComboBox
            Kirigami.FormData.label: i18nc("@label", "Gemini Model:")
            Layout.fillWidth: true
            
            property var modelOptions: [
                "gemini-2.5-flash",
                "gemini-2.5-pro",
                "gemini-2.5-flash-lite",
                "gemini-2.5-flash-lite-preview-09-2025",
                "gemini-3.1-pro-preview",
                "gemini-3.1-flash-lite-preview",
                "gemini-3.1-pro-preview-customtools",
                "gemini-3-pro-preview",
                "gemini-3-flash-preview",
                "gemma-3-27b-it",
                "gemma-3-12b-it",
                "gemma-3-4b-it",
                "gemma-3-1b-it",
                "gemma-3n-e4b-it",
                "gemma-3n-e2b-it",
                "deep-research-pro-preview-12-2025"
            ]
            
            property var modelLabels: [
                i18nc("@item:inlistbox", "Gemini 2.5 Flash"),
                i18nc("@item:inlistbox", "Gemini 2.5 Pro"),
                i18nc("@item:inlistbox", "Gemini 2.5 Flash-Lite"),
                i18nc("@item:inlistbox", "Gemini 2.5 Flash-Lite Preview (Sep 2025)"),
                i18nc("@item:inlistbox", "Gemini 3.1 Pro Preview"),
                i18nc("@item:inlistbox", "Gemini 3.1 Flash-Lite Preview"),
                i18nc("@item:inlistbox", "Gemini 3.1 Pro Custom Tools"),
                i18nc("@item:inlistbox", "Gemini 3 Pro Preview"),
                i18nc("@item:inlistbox", "Gemini 3 Flash Preview"),
                i18nc("@item:inlistbox", "Gemma 3 27B"),
                i18nc("@item:inlistbox", "Gemma 3 12B"),
                i18nc("@item:inlistbox", "Gemma 3 4B"),
                i18nc("@item:inlistbox", "Gemma 3 1B"),
                i18nc("@item:inlistbox", "Gemma 3n E4B"),
                i18nc("@item:inlistbox", "Gemma 3n E2B"),
                i18nc("@item:inlistbox", "Deep Research Pro Preview")
            ]
            
            model: modelLabels
            
            currentIndex: {
                var index = modelOptions.indexOf(cfg_selectedModel);
                return index >= 0 ? index : 0;
            }
            
            onActivated: {
                if (currentIndex >= 0 && currentIndex < modelOptions.length) {
                    cfg_selectedModel = modelOptions[currentIndex];
                }
            }
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            type: Kirigami.MessageType.Information
            text: {
                var descriptions = [
                    i18nc("@info", "Newest generation (V3). Highest reasoning capability."),
                    i18nc("@info", "Newest generation (V3). High speed and efficiency."),
                    i18nc("@info", "Deep reasoning for complex research and analysis."),
                    i18nc("@info", "Open-source model. 27B parameters instruction-tuned."),
                    i18nc("@info", "Best balance of speed and performance"),
                    i18nc("@info", "Advanced model with enhanced reasoning"),
                    i18nc("@info", "Ultra-fast model optimized for cost-efficiency"),
                    i18nc("@info", "Previous generation workhorse model"),
                    i18nc("@info", "Previous generation lightweight model")
                ];
                return modelComboBox.currentIndex >= 0 && modelComboBox.currentIndex < descriptions.length 
                    ? descriptions[modelComboBox.currentIndex] 
                    : "";
            }
            visible: text.length > 0
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