import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_use24Hour: use24Hour.checked
    property alias cfg_showSeconds: showSeconds.checked
    property alias cfg_showLabels: showLabels.checked
    property alias cfg_autoLocalLabel: autoLocalLabel.checked
    property alias cfg_localLabel: localLabel.text
    property alias cfg_utcLabel: utcLabel.text
    property string cfg_labelPosition
    property alias cfg_showUtcOffset: showUtcOffset.checked
    property string cfg_localTimeColor
    property string cfg_utcTimeColor

    readonly property var timeColorOptions: [
        { text: i18n("Default (theme)"),         value: "default" },
        { text: i18n("Pure white"),               value: "white" },
        { text: i18n("Yellow"),                   value: "yellow" },
        { text: i18n("Muted (less prominent)"),   value: "muted" }
    ]

    // Time format
    CheckBox { id: use24Hour; Kirigami.FormData.label: i18n("Time format:"); text: i18n("24-hour") }
    CheckBox { id: showSeconds; text: i18n("Show seconds") }

    Item { Kirigami.FormData.isSection: true }

    // Labels
    CheckBox { id: showLabels; Kirigami.FormData.label: i18n("Labels:"); text: i18n("Show timezone labels") }
    CheckBox { id: autoLocalLabel; text: i18n("Auto-detect local label"); enabled: showLabels.checked }
    TextField { id: localLabel; Kirigami.FormData.label: i18n("Local label:"); enabled: showLabels.checked && !autoLocalLabel.checked }
    TextField { id: utcLabel; Kirigami.FormData.label: i18n("UTC label:"); enabled: showLabels.checked }

    ComboBox {
        id: labelPosCombo
        Kirigami.FormData.label: i18n("Label position (panel):")
        enabled: showLabels.checked
        model: [
            { text: i18n("Underneath time"), value: "below" },
            { text: i18n("After time (inline)"), value: "inline" }
        ]
        textRole: "text"
        valueRole: "value"
        currentIndex: cfg_labelPosition === "inline" ? 1 : 0
        onActivated: cfg_labelPosition = model[currentIndex].value
    }

    CheckBox { id: showUtcOffset; text: i18n("Show UTC offset next to local label"); enabled: showLabels.checked }

    Item { Kirigami.FormData.isSection: true }

    // Colours
    ComboBox {
        id: localColorCombo
        Kirigami.FormData.label: i18n("Local time colour:")
        model: page.timeColorOptions
        textRole: "text"
        valueRole: "value"
        currentIndex: {
            for (let i = 0; i < model.length; i++) if (model[i].value === cfg_localTimeColor) return i;
            return 0;
        }
        onActivated: cfg_localTimeColor = model[currentIndex].value
    }
    ComboBox {
        id: utcColorCombo
        Kirigami.FormData.label: i18n("UTC time colour:")
        model: page.timeColorOptions
        textRole: "text"
        valueRole: "value"
        currentIndex: {
            for (let i = 0; i < model.length; i++) if (model[i].value === cfg_utcTimeColor) return i;
            return 0;
        }
        onActivated: cfg_utcTimeColor = model[currentIndex].value
    }
}
