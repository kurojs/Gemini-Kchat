import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQControls

KCM.ScrollViewKCM {
    id: colorsPage
    
    property alias cfg_useCustomBackgroundColor: useCustomBackgroundColor.checked
    property alias cfg_backgroundColor: backgroundColor.color
    property alias cfg_backgroundOpacity: backgroundOpacity.value
    
    property alias cfg_useCustomUserMessageColor: useCustomUserMessageColor.checked
    property alias cfg_userMessageColor: userMessageColor.color
    property alias cfg_userMessageOpacity: userMessageOpacity.value
    
    property alias cfg_useCustomUserTextColor: useCustomUserTextColor.checked
    property alias cfg_userTextColor: userTextColor.color
    
    property alias cfg_useCustomAssistantMessageColor: useCustomAssistantMessageColor.checked
    property alias cfg_assistantMessageColor: assistantMessageColor.color
    property alias cfg_assistantMessageOpacity: assistantMessageOpacity.value
    
    property alias cfg_useCustomAssistantTextColor: useCustomAssistantTextColor.checked
    property alias cfg_assistantTextColor: assistantTextColor.color
    
    property alias cfg_useCustomInputColor: useCustomInputColor.checked
    property alias cfg_inputBackgroundColor: inputBackgroundColor.color
    property alias cfg_inputOpacity: inputOpacity.value
    
    property alias cfg_useCustomInputTextColor: useCustomInputTextColor.checked
    property alias cfg_inputTextColor: inputTextColor.color
    
    property alias cfg_useCustomSelectionColor: useCustomSelectionColor.checked
    property alias cfg_selectionColor: selectionColor.color
    property alias cfg_selectionOpacity: selectionOpacity.value
    
    property alias cfg_useCustomLinkColor: useCustomLinkColor.checked
    property alias cfg_linkColor: linkColor.color

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
                    Kirigami.FormData.label: i18nc("@title:group", "Background")
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Background color:")
                    
                    QQC2.CheckBox {
                        id: useCustomBackgroundColor
                        text: i18nc("@option:check", "Custom")
                    }
                    
                    KQControls.ColorButton {
                        id: backgroundColor
                        enabled: useCustomBackgroundColor.checked
                        showAlphaChannel: false
                    }
                    
                    QQC2.Label {
                        text: i18nc("@label", "Opacity:")
                        enabled: useCustomBackgroundColor.checked
                    }
                    
                    QQC2.Slider {
                        id: backgroundOpacity
                        enabled: useCustomBackgroundColor.checked
                        from: 0
                        to: 1
                        stepSize: 0.01
                        Layout.preferredWidth: 150
                    }
                }
                
                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18nc("@title:group", "User Messages")
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Background:")
                    
                    QQC2.CheckBox {
                        id: useCustomUserMessageColor
                        text: i18nc("@option:check", "Custom")
                    }
                    
                    KQControls.ColorButton {
                        id: userMessageColor
                        enabled: useCustomUserMessageColor.checked
                        showAlphaChannel: false
                    }
                    
                    QQC2.Label {
                        text: i18nc("@label", "Opacity:")
                        enabled: useCustomUserMessageColor.checked
                    }
                    
                    QQC2.Slider {
                        id: userMessageOpacity
                        enabled: useCustomUserMessageColor.checked
                        from: 0
                        to: 1
                        stepSize: 0.01
                        Layout.preferredWidth: 150
                    }
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Text color:")
                    
                    QQC2.CheckBox {
                        id: useCustomUserTextColor
                        text: i18nc("@option:check", "Custom")
                    }
                    
                    KQControls.ColorButton {
                        id: userTextColor
                        enabled: useCustomUserTextColor.checked
                        showAlphaChannel: false
                    }
                }
                
                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18nc("@title:group", "Assistant Messages")
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Background:")
                    
                    QQC2.CheckBox {
                        id: useCustomAssistantMessageColor
                        text: i18nc("@option:check", "Custom")
                    }
                    
                    KQControls.ColorButton {
                        id: assistantMessageColor
                        enabled: useCustomAssistantMessageColor.checked
                        showAlphaChannel: false
                    }
                    
                    QQC2.Label {
                        text: i18nc("@label", "Opacity:")
                        enabled: useCustomAssistantMessageColor.checked
                    }
                    
                    QQC2.Slider {
                        id: assistantMessageOpacity
                        enabled: useCustomAssistantMessageColor.checked
                        from: 0
                        to: 1
                        stepSize: 0.01
                        Layout.preferredWidth: 150
                    }
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Text color:")
                    
                    QQC2.CheckBox {
                        id: useCustomAssistantTextColor
                        text: i18nc("@option:check", "Custom")
                    }
                    
                    KQControls.ColorButton {
                        id: assistantTextColor
                        enabled: useCustomAssistantTextColor.checked
                        showAlphaChannel: false
                    }
                }
                
                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18nc("@title:group", "Input Field")
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Background:")
                    
                    QQC2.CheckBox {
                        id: useCustomInputColor
                        text: i18nc("@option:check", "Custom")
                    }
                    
                    KQControls.ColorButton {
                        id: inputBackgroundColor
                        enabled: useCustomInputColor.checked
                        showAlphaChannel: false
                    }
                    
                    QQC2.Label {
                        text: i18nc("@label", "Opacity:")
                        enabled: useCustomInputColor.checked
                    }
                    
                    QQC2.Slider {
                        id: inputOpacity
                        enabled: useCustomInputColor.checked
                        from: 0
                        to: 1
                        stepSize: 0.01
                        Layout.preferredWidth: 150
                    }
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Text color:")
                    
                    QQC2.CheckBox {
                        id: useCustomInputTextColor
                        text: i18nc("@option:check", "Custom")
                    }
                    
                    KQControls.ColorButton {
                        id: inputTextColor
                        enabled: useCustomInputTextColor.checked
                        showAlphaChannel: false
                    }
                }
                
                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18nc("@title:group", "Text Selection")
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Selection color:")
                    
                    QQC2.CheckBox {
                        id: useCustomSelectionColor
                        text: i18nc("@option:check", "Custom")
                    }
                    
                    KQControls.ColorButton {
                        id: selectionColor
                        enabled: useCustomSelectionColor.checked
                        showAlphaChannel: false
                    }
                    
                    QQC2.Label {
                        text: i18nc("@label", "Opacity:")
                        enabled: useCustomSelectionColor.checked
                    }
                    
                    QQC2.Slider {
                        id: selectionOpacity
                        enabled: useCustomSelectionColor.checked
                        from: 0
                        to: 1
                        stepSize: 0.01
                        Layout.preferredWidth: 150
                    }
                }
                
                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18nc("@title:group", "Links")
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18nc("@label:chooser", "Link color:")
                    
                    QQC2.CheckBox {
                        id: useCustomLinkColor
                        text: i18nc("@option:check", "Custom")
                    }
                    
                    KQControls.ColorButton {
                        id: linkColor
                        enabled: useCustomLinkColor.checked
                        showAlphaChannel: false
                    }
                }
            }
            }
        }
    }
}