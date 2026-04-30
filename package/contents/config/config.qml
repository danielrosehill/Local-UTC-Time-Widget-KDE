import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "configure"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Date & Blocks")
        icon: "view-calendar"
        source: "configDate.qml"
    }
    ConfigCategory {
        name: i18n("Tray Blocks")
        icon: "preferences-system-windows-effect-systemtray"
        source: "configTray.qml"
    }
    ConfigCategory {
        name: i18n("Hebrew Calendar")
        icon: "view-calendar-day"
        source: "configHebrew.qml"
    }
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-color"
        source: "configAppearance.qml"
    }
}
