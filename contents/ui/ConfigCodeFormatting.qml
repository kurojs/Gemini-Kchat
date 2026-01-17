import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQControls
import Qt.labs.platform as Platform

KCM.ScrollViewKCM {
    id: codeFormattingPage
    
    property alias cfg_codeBackgroundColor: codeBackgroundColor.color
    property alias cfg_codeBackgroundOpacity: codeBackgroundOpacity.value
    property string cfg_codeFontFamily
    
    property alias cfg_codeKeywordColor: codeKeywordColor.color
    property alias cfg_codeStringColor: codeStringColor.color
    property alias cfg_codeCommentColor: codeCommentColor.color
    property alias cfg_codeFunctionColor: codeFunctionColor.color
    property alias cfg_codeNumberColor: codeNumberColor.color
    property alias cfg_codeTypeColor: codeTypeColor.color

    view: ListView {
        model: ObjectModel {
            
            Item {
                width: ListView.view.width
                height: formLayout.implicitHeight + 40
                
                Kirigami.FormLayout {
                    id: formLayout
                    anchors.centerIn: parent
                    width: Math.min(parent.width - 40, 600)
                
                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18nc("@title:group", "Code Block Appearance")
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Background color:")
                    
                    KQControls.ColorButton {
                        id: codeBackgroundColor
                        showAlphaChannel: false
                        onAccepted: {
                            cfg_codeBackgroundColor = codeBackgroundColor.color
                        }
                    }
                    
                    QQC2.Label {
                        text: i18nc("@label", "Opacity:")
                    }
                    
                    QQC2.Slider {
                        id: codeBackgroundOpacity
                        from: 0
                        to: 1
                        stepSize: 0.01
                        Layout.preferredWidth: 150
                    }
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:button", "Font:")
                    
                    QQC2.TextField {
                        id: codeFontDisplay
                        text: cfg_codeFontFamily || "Monospace"
                        readOnly: true
                        Layout.fillWidth: true
                    }
                    
                    QQC2.Button {
                        text: i18nc("@action:button", "Choose...")
                        onClicked: codeFontDialog.open()
                    }
                }
                
                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18nc("@title:group", "Syntax Colors")
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Keywords:")
                    
                    KQControls.ColorButton {
                        id: codeKeywordColor
                        showAlphaChannel: false
                    }
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Strings:")
                    
                    KQControls.ColorButton {
                        id: codeStringColor
                        showAlphaChannel: false
                    }
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Comments:")
                    
                    KQControls.ColorButton {
                        id: codeCommentColor
                        showAlphaChannel: false
                    }
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Functions:")
                    
                    KQControls.ColorButton {
                        id: codeFunctionColor
                        showAlphaChannel: false
                    }
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Numbers:")
                    
                    KQControls.ColorButton {
                        id: codeNumberColor
                        showAlphaChannel: false
                    }
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Types/Objects:")
                    
                    KQControls.ColorButton {
                        id: codeTypeColor
                        showAlphaChannel: false
                    }
                }
            }
            }
        }
    }
    
    Platform.FontDialog {
        id: codeFontDialog
        currentFont.family: cfg_codeFontFamily || "Monospace"
        onAccepted: {
            cfg_codeFontFamily = codeFontDialog.currentFont.family
            codeFontDisplay.text = cfg_codeFontFamily
        }
    }
}