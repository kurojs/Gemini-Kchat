import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: i18nc("@title", "General")
         icon: "configure"
         source: "ConfigGeneral.qml"
    }
    ConfigCategory {
         name: i18nc("@title", "API Configuration")
         icon: "network-connect"
         source: "ConfigAppearance.qml"
    }
    ConfigCategory {
         name: i18nc("@title", "Colors")
         icon: "color-management"
         source: "ConfigColors.qml"
    }
    ConfigCategory {
         name: i18nc("@title", "AI Personality")
         icon: "actor"
         source: "ConfigPrompt.qml"
    }
    ConfigCategory {
         name: i18nc("@title", "UI Elements")
         icon: "visibility"
         source: "ConfigUIElements.qml"
    }
    ConfigCategory {
         name: i18nc("@title", "Typography")
         icon: "font"
         source: "ConfigTypography.qml"
    }
    ConfigCategory {
         name: i18nc("@title", "Code Formatting")
         icon: "text-x-script"
         source: "ConfigCodeFormatting.qml"
    }
}