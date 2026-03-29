import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    property alias cfg_enableTTS: enableTTS.checked
    property alias cfg_ttsProvider: providerCombo.currentValue
    property alias cfg_elevenlabsApiKey: elevenlabsApiKey.text
    property alias cfg_elevenlabsVoiceId: elevenlabsVoiceId.text
    property alias cfg_openaiApiKey: openaiApiKey.text
    property alias cfg_openaiVoice: openaiVoiceCombo.currentValue
    property alias cfg_openaiModel: openaiModelCombo.currentValue
    property alias cfg_espeakVoice: espeakVoice.text
    property alias cfg_espeakSpeed: espeakSpeed.value
    property alias cfg_espeakPitch: espeakPitch.value
    property alias cfg_piperModelPath: piperModelPath.text

    Kirigami.FormLayout {
        CheckBox {
            id: enableTTS
            Kirigami.FormData.label: i18n("Enable TTS:")
        }

        ComboBox {
            id: providerCombo
            Kirigami.FormData.label: i18n("Provider:")
            enabled: enableTTS.checked
            model: [
                { text: "ElevenLabs", value: "elevenlabs" },
                { text: "OpenAI", value: "openai" },
                { text: "espeak-ng", value: "espeak" },
                { text: "Piper", value: "piper" }
            ]
            textRole: "text"
            valueRole: "value"
            Component.onCompleted: {
                for (var i = 0; i < model.length; i++) {
                    if (model[i].value === cfg_ttsProvider) {
                        currentIndex = i
                        break
                    }
                }
            }
        }

        Item { Kirigami.FormData.isSection: true; visible: providerCombo.currentValue === "elevenlabs" }

        TextField {
            id: elevenlabsApiKey
            Kirigami.FormData.label: i18n("ElevenLabs API Key:")
            visible: providerCombo.currentValue === "elevenlabs"
            enabled: enableTTS.checked
            echoMode: TextInput.Password
            placeholderText: i18n("Enter API Key")
        }

        TextField {
            id: elevenlabsVoiceId
            Kirigami.FormData.label: i18n("Voice ID:")
            visible: providerCombo.currentValue === "elevenlabs"
            enabled: enableTTS.checked
            placeholderText: "pNInz6obpgDQGcFmaJgB"
        }

        Item { Kirigami.FormData.isSection: true; visible: providerCombo.currentValue === "openai" }

        TextField {
            id: openaiApiKey
            Kirigami.FormData.label: i18n("OpenAI API Key:")
            visible: providerCombo.currentValue === "openai"
            enabled: enableTTS.checked
            echoMode: TextInput.Password
            placeholderText: i18n("Enter API Key")
        }

        ComboBox {
            id: openaiVoiceCombo
            Kirigami.FormData.label: i18n("Voice:")
            visible: providerCombo.currentValue === "openai"
            enabled: enableTTS.checked
            model: [
                { text: "Alloy", value: "alloy" },
                { text: "Ash", value: "ash" },
                { text: "Ballad", value: "ballad" },
                { text: "Coral", value: "coral" },
                { text: "Echo", value: "echo" },
                { text: "Fable", value: "fable" },
                { text: "Onyx", value: "onyx" },
                { text: "Nova", value: "nova" },
                { text: "Sage", value: "sage" },
                { text: "Shimmer", value: "shimmer" }
            ]
            textRole: "text"
            valueRole: "value"
            Component.onCompleted: {
                for (var i = 0; i < model.length; i++) {
                    if (model[i].value === cfg_openaiVoice) {
                        currentIndex = i
                        break
                    }
                }
            }
        }

        ComboBox {
            id: openaiModelCombo
            Kirigami.FormData.label: i18n("Model:")
            visible: providerCombo.currentValue === "openai"
            enabled: enableTTS.checked
            model: [
                { text: "TTS-1 (Fast)", value: "tts-1" },
                { text: "TTS-1-HD (Quality)", value: "tts-1-hd" }
            ]
            textRole: "text"
            valueRole: "value"
            Component.onCompleted: {
                for (var i = 0; i < model.length; i++) {
                    if (model[i].value === cfg_openaiModel) {
                        currentIndex = i
                        break
                    }
                }
            }
        }

        Item { Kirigami.FormData.isSection: true; visible: providerCombo.currentValue === "espeak" }

        TextField {
            id: espeakVoice
            Kirigami.FormData.label: i18n("Voice/Language:")
            visible: providerCombo.currentValue === "espeak"
            enabled: enableTTS.checked
            placeholderText: "en, es, ja, de..."
        }

        SpinBox {
            id: espeakSpeed
            Kirigami.FormData.label: i18n("Speed (WPM):")
            visible: providerCombo.currentValue === "espeak"
            enabled: enableTTS.checked
            from: 80
            to: 450
            value: 175
        }

        SpinBox {
            id: espeakPitch
            Kirigami.FormData.label: i18n("Pitch:")
            visible: providerCombo.currentValue === "espeak"
            enabled: enableTTS.checked
            from: 0
            to: 99
            value: 50
        }

        Item { Kirigami.FormData.isSection: true; visible: providerCombo.currentValue === "piper" }

        TextField {
            id: piperModelPath
            Kirigami.FormData.label: i18n("Model Path:")
            visible: providerCombo.currentValue === "piper"
            enabled: enableTTS.checked
            placeholderText: "/path/to/model.onnx"
        }
    }
}
