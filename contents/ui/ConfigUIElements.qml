import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_showPinButton: showPinButton.checked
    property alias cfg_showClearButton: showClearButton.checked
    property alias cfg_showCopyButton: showCopyButton.checked
    property alias cfg_showPasteButton: showPasteButton.checked
    property alias cfg_showSendButton: showSendButton.checked
    property alias cfg_showScrollToBottomButton: showScrollToBottomButton.checked
    property alias cfg_showInputPlaceholder: showInputPlaceholder.checked
    property alias cfg_showEmptyPlaceholder: showEmptyPlaceholder.checked
    property alias cfg_useCustomPlaceholders: useCustomPlaceholders.checked
    property alias cfg_inputPlaceholder: inputPlaceholder.text
    property alias cfg_emptyPlaceholder: emptyPlaceholder.text
    
    Kirigami.FormLayout {
        
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18nc("@title:group", "Buttons Visibility")
        }
        
        QQC2.CheckBox {
            id: showPinButton
            Kirigami.FormData.label: i18nc("@option:check", "Show pin button:")
            text: i18nc("@option:check", "Visible")
        }
        
        QQC2.CheckBox {
            id: showClearButton
            Kirigami.FormData.label: i18nc("@option:check", "Show clear button:")
            text: i18nc("@option:check", "Visible")
        }
        
        QQC2.CheckBox {
            id: showCopyButton
            Kirigami.FormData.label: i18nc("@option:check", "Show copy button:")
            text: i18nc("@option:check", "Visible")
        }
        
        QQC2.CheckBox {
            id: showPasteButton
            Kirigami.FormData.label: i18nc("@option:check", "Show paste button:")
            text: i18nc("@option:check", "Visible")
        }
        
        QQC2.CheckBox {
            id: showSendButton
            Kirigami.FormData.label: i18nc("@option:check", "Show send button:")
            text: i18nc("@option:check", "Visible")
        }
        
        QQC2.CheckBox {
            id: showScrollToBottomButton
            Kirigami.FormData.label: i18nc("@option:check", "Scroll to bottom button:")
            text: i18nc("@option:check", "Visible")
        }
        
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18nc("@title:group", "Placeholders")
        }
        
        QQC2.CheckBox {
            id: showInputPlaceholder
            Kirigami.FormData.label: i18nc("@option:check", "Show input placeholder:")
            text: i18nc("@option:check", "Visible")
        }
        
        QQC2.CheckBox {
            id: showEmptyPlaceholder
            Kirigami.FormData.label: i18nc("@option:check", "Show empty chat placeholder:")
            text: i18nc("@option:check", "Visible")
        }
        
        QQC2.CheckBox {
            id: useCustomPlaceholders
            Kirigami.FormData.label: i18nc("@option:check", "Custom text:")
            text: i18nc("@option:check", "Enable custom placeholders")
            enabled: showInputPlaceholder.checked || showEmptyPlaceholder.checked
        }
        
        QQC2.TextField {
            id: inputPlaceholder
            Kirigami.FormData.label: i18nc("@label:textbox", "Input placeholder:")
            enabled: showInputPlaceholder.checked && useCustomPlaceholders.checked
            Layout.fillWidth: true
            placeholderText: "Type here what you want to ask..."
        }
        
        QQC2.TextField {
            id: emptyPlaceholder
            Kirigami.FormData.label: i18nc("@label:textbox", "Empty chat placeholder:")
            enabled: showEmptyPlaceholder.checked && useCustomPlaceholders.checked
            Layout.fillWidth: true
            placeholderText: "I am waiting for your questions..."
        }
    }
}