import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_dateBoxUseUtc: dateBoxUseUtc.checked
    property string cfg_dateBoxLayout
    property string cfg_gregorianDateStyle
    property string cfg_gregorianDateFormat
    property alias cfg_hebrewEnabled: hebrewEnabled.checked
    property alias cfg_monthLong: monthLong.checked

    CheckBox { id: dateBoxUseUtc; Kirigami.FormData.label: i18n("Date source:"); text: i18n("Use UTC (otherwise local time zone)") }

    Item { Kirigami.FormData.isSection: true }

    ComboBox {
        id: gregorianStyleCombo
        Kirigami.FormData.label: i18n("Date card style:")
        model: [
            { text: i18n("Two lines (Thurs / 30)"), value: "two-line" },
            { text: i18n("Single line (Thurs 30)"), value: "single-line" }
        ]
        textRole: "text"
        valueRole: "value"
        currentIndex: cfg_gregorianDateStyle === "single-line" ? 1 : 0
        onActivated: cfg_gregorianDateStyle = model[currentIndex].value
    }
    ComboBox {
        id: dateBoxLayoutCombo
        Kirigami.FormData.label: i18n("Two-line order:")
        enabled: cfg_gregorianDateStyle !== "single-line"
        model: [
            { text: i18n("Weekday above date"), value: "weekday-top" },
            { text: i18n("Date above weekday"), value: "date-top" }
        ]
        textRole: "text"
        valueRole: "value"
        currentIndex: cfg_dateBoxLayout === "date-top" ? 1 : 0
        onActivated: cfg_dateBoxLayout = model[currentIndex].value
    }
    ComboBox {
        id: dateFormatCombo
        Kirigami.FormData.label: i18n("Date line shows:")
        model: [
            { text: i18n("Day of month only (30)"),     value: "day" },
            { text: i18n("Day before month (30 Apr)"),   value: "day-month" },
            { text: i18n("Month before day (Apr 30)"),   value: "month-day" }
        ]
        textRole: "text"
        valueRole: "value"
        currentIndex: {
            for (let i = 0; i < model.length; i++) if (model[i].value === cfg_gregorianDateFormat) return i;
            return 0;
        }
        onActivated: cfg_gregorianDateFormat = model[currentIndex].value
    }
    CheckBox { id: monthLong; text: i18n("Use long month names (April vs Apr)"); enabled: cfg_gregorianDateFormat !== "day" }

    Item { Kirigami.FormData.isSection: true }

    CheckBox {
        id: hebrewEnabled
        Kirigami.FormData.label: i18n("Hebrew calendar:")
        text: i18n("Enable Hebrew date options")
    }
    Label {
        visible: hebrewEnabled.checked
        text: i18n("Configure formatting and location in the \"Hebrew Calendar\" page.")
        opacity: 0.7
        wrapMode: Text.WordWrap
    }
}
