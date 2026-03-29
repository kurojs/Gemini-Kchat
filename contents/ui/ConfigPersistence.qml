import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_enablePersistence: enablePersistence.checked
    
    Kirigami.FormLayout {
        QQC2.CheckBox {
            id: enablePersistence
            Kirigami.FormData.label: i18nc("@option:check", "Enable conversation persistence:")
            text: i18nc("@option:check", "Save conversations")
        }
    }
}
