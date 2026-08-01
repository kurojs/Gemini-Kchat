import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_useCustomIcon: useCustomIcon.checked
    property alias cfg_customIconPath: customIconPath.text
    property bool cfg_enableFileOps: false
    property alias cfg_showFunctionMessages: showFunctionMessages.checked
    property alias cfg_msgListDirectory: msgListDirectory.text
    property alias cfg_msgReadTextFile: msgReadTextFile.text
    property alias cfg_msgWriteTextFile: msgWriteTextFile.text
    property alias cfg_msgRunCommand: msgRunCommand.text
    
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

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "File Operations"
        }

        QQC2.CheckBox {
            id: enableFileOps
            checked: cfg_enableFileOps
            onToggled: cfg_enableFileOps = checked
            Kirigami.FormData.label: i18nc("@option:check", "Enable file ops:")
            text: i18nc("@option:check", "Allows Gemini to list, read, write files and run commands")
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Function Messages"
        }

        QQC2.CheckBox {
            id: showFunctionMessages
            Kirigami.FormData.label: i18nc("@option:check", "Show progress:")
            text: i18nc("@option:check", "Show messages when Gemini runs functions")
        }

        QQC2.TextField {
            id: msgListDirectory
            Kirigami.FormData.label: i18nc("@label", "List directory:")
            enabled: showFunctionMessages.checked
            placeholderText: "list_directory..."
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: msgReadTextFile
            Kirigami.FormData.label: i18nc("@label", "Read file:")
            enabled: showFunctionMessages.checked
            placeholderText: "read_text_file..."
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: msgWriteTextFile
            Kirigami.FormData.label: i18nc("@label", "Write file:")
            enabled: showFunctionMessages.checked
            placeholderText: "write_text_file..."
            Layout.fillWidth: true
        }

        QQC2.TextField {
            id: msgRunCommand
            Kirigami.FormData.label: i18nc("@label", "Run command:")
            enabled: showFunctionMessages.checked
            placeholderText: "run_command..."
            Layout.fillWidth: true
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