import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM
import Qt.labs.platform as Platform

KCM.SimpleKCM {
    property alias cfg_useCustomFont: useCustomFont.checked
    property string cfg_customFontFamily
    property alias cfg_customFontSize: customFontSize.value
    
    Kirigami.FormLayout {
        
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18nc("@title:group", "Font Settings")
        }
        
        QQC2.CheckBox {
            id: useCustomFont
            Kirigami.FormData.label: i18nc("@option:check", "Custom font:")
            text: i18nc("@option:check", "Enable custom typography")
        }
        
        RowLayout {
            Kirigami.FormData.label: i18nc("@label:button", "Font family:")
            enabled: useCustomFont.checked
            
            QQC2.TextField {
                id: fontFamilyDisplay
                text: cfg_customFontFamily || "Monospace"
                readOnly: true
                Layout.fillWidth: true
            }
            
            QQC2.Button {
                text: i18nc("@action:button", "Choose...")
                onClicked: fontDialog.open()
            }
        }
        
        QQC2.SpinBox {
            id: customFontSize
            Kirigami.FormData.label: i18nc("@label:spinbox", "Font size:")
            enabled: useCustomFont.checked
            from: 6
            to: 32
            value: 10
        }
    }
    
    Platform.FontDialog {
        id: fontDialog
        currentFont.family: cfg_customFontFamily || "Monospace"
        onAccepted: {
            cfg_customFontFamily = fontDialog.currentFont.family
            fontFamilyDisplay.text = cfg_customFontFamily
        }
    }
}