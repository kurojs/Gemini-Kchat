import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_useCustomIcon: useCustomIcon.checked
    property alias cfg_customIconPath: customIconPath.text
    
    Kirigami.FormLayout {
        
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18nc("@title:group", "Plasmoid Icon")
        }
        
        QQC2.CheckBox {
            id: useCustomIcon
            Kirigami.FormData.label: i18nc("@option:check", "Custom icon:")
            text: i18nc("@option:check", "Use custom icon")
        }
        
        RowLayout {
            Kirigami.FormData.label: i18nc("@label", "Icon path:")
            enabled: useCustomIcon.checked
            spacing: 5
            
            QQC2.TextField {
                id: customIconPath
                Layout.fillWidth: true
                placeholderText: i18nc("@info:placeholder", "Select an icon file...")
                readOnly: true
            }
            
            QQC2.Button {
                text: i18nc("@action:button", "Browse...")
                icon.name: "document-open"
                onClicked: iconFileDialog.open()
            }
        }
    }
    
    FileDialog {
        id: iconFileDialog
        title: i18nc("@title:window", "Select Icon File")
        nameFilters: [i18nc("@item:inlistbox", "Image files (*.png *.svg *.jpg *.jpeg)"), i18nc("@item:inlistbox", "All files (*)")]
        onAccepted: {
            var path = iconFileDialog.selectedFile.toString();
            path = path.replace(/^file:\/\//, '');
            customIconPath.text = path;
        }
    }
}