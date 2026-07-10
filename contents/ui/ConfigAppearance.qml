import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_apiKey: apiKeyField.text
    property string cfg_selectedModel

    property bool cfg_useCustomUserTextColor
    property bool cfg_useCustomUserTextColorDefault
    property color cfg_userMessageColor
    property bool cfg_userMessageColorDefault
    property real cfg_userMessageOpacity
    property bool cfg_userMessageOpacityDefault
    property color cfg_userTextColor
    property bool cfg_userTextColorDefault
    
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
                "gemini-flash-latest",
                "gemini-flash-lite-latest",
                "gemini-pro-latest",
                "gemini-3.5-flash",
                "gemini-3.5-pro",
                "gemini-3.1-pro-preview",
                "gemini-3.1-flash-lite",
                "gemini-3.1-flash-lite-preview",
                "gemini-3.1-pro-preview-customtools",
                "gemini-3-pro-preview",
                "gemini-3-flash-preview",
                "gemini-2.5-flash",
                "gemini-2.5-pro",
                "gemini-2.5-flash-lite",
                "gemma-4-31b-it",
                "gemma-4-26b-a4b-it",
                "deep-research-pro-preview-12-2025",
                "deep-research-preview-04-2026",
                "deep-research-max-preview-04-2026"
            ]
            
            property var modelLabels: [
                i18nc("@item:inlistbox", "Flash (Latest)"),
                i18nc("@item:inlistbox", "Flash-Lite (Latest)"),
                i18nc("@item:inlistbox", "Pro (Latest)"),
                i18nc("@item:inlistbox", "Gemini 3.5 Flash"),
                i18nc("@item:inlistbox", "Gemini 3.5 Pro"),
                i18nc("@item:inlistbox", "Gemini 3.1 Pro Preview"),
                i18nc("@item:inlistbox", "Gemini 3.1 Flash-Lite"),
                i18nc("@item:inlistbox", "Gemini 3.1 Flash-Lite Preview"),
                i18nc("@item:inlistbox", "Gemini 3.1 Pro Custom Tools"),
                i18nc("@item:inlistbox", "Gemini 3 Pro Preview"),
                i18nc("@item:inlistbox", "Gemini 3 Flash Preview"),
                i18nc("@item:inlistbox", "Gemini 2.5 Flash"),
                i18nc("@item:inlistbox", "Gemini 2.5 Pro"),
                i18nc("@item:inlistbox", "Gemini 2.5 Flash-Lite"),
                i18nc("@item:inlistbox", "Gemma 4 31B"),
                i18nc("@item:inlistbox", "Gemma 4 26B A4B"),
                i18nc("@item:inlistbox", "Deep Research Pro Preview"),
                i18nc("@item:inlistbox", "Deep Research Preview (Apr 2026)"),
                i18nc("@item:inlistbox", "Deep Research Max Preview (Apr 2026)")
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
                    i18nc("@info", "Always points to the latest stable Flash model."),
                    i18nc("@info", "Always points to the latest stable Flash-Lite model."),
                    i18nc("@info", "Always points to the latest stable Pro model."),
                    i18nc("@info", "V3.5 generation. Fast, efficient, thinking-enabled."),
                    i18nc("@info", "V3.5 generation. Flagship reasoning and coding."),
                    i18nc("@info", "V3.1 Pro with advanced multimodal reasoning."),
                    i18nc("@info", "V3.1 Stable. Most cost-efficient model."),
                    i18nc("@info", "V3.1 Flash-Lite preview. Cost-efficient."),
                    i18nc("@info", "V3.1 Pro optimized for custom tool usage."),
                    i18nc("@info", "V3 Pro. State-of-the-art reasoning."),
                    i18nc("@info", "V3 Flash. Frontier performance at low cost."),
                    i18nc("@info", "V2.5 Flash. Balanced speed and quality."),
                    i18nc("@info", "V2.5 Pro. Mature reasoning and coding."),
                    i18nc("@info", "V2.5 Flash-Lite. Ultra low-cost."),
                    i18nc("@info", "Open-source model. 31B parameters."),
                    i18nc("@info", "Open-source model. 26B parameters, sparse."),
                    i18nc("@info", "Deep reasoning for complex research and analysis."),
                    i18nc("@info", "Deep reasoning for research tasks."),
                    i18nc("@info", "Maximum deep reasoning for complex analysis.")
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