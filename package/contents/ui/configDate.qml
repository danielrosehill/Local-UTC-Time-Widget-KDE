import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: page
    spacing: Kirigami.Units.largeSpacing

    property alias cfg_dateBoxUseUtc: dateBoxUseUtc.checked
    property string cfg_dateBoxLayout
    property string cfg_gregorianDateStyle
    property alias cfg_hebrewEnabled: hebrewEnabled.checked
    property alias cfg_monthLong: monthLong.checked
    property string cfg_cardOrder

    readonly property var standardBlocks: [
        { kind: "local-time",            label: i18n("Local time (HH:MM)") },
        { kind: "utc-time",              label: i18n("UTC time (HH:MM)") },
        { kind: "date-combined",         label: i18n("Date card (weekday + Apr 30 + Hebrew)") },
        { kind: "weekday",               label: i18n("Weekday (Thurs)") },
        { kind: "gregorian-date",        label: i18n("Gregorian date (Apr 30)") },
        { kind: "month",                 label: i18n("Month (April)") },
        { kind: "day",                   label: i18n("Day of month (30)") }
    ]
    readonly property var hebrewBlocks: [
        { kind: "hebrew-day-month",      label: i18n("Hebrew: 13 Iyyar") },
        { kind: "hebrew-day-month-year", label: i18n("Hebrew: 13 Iyyar 5786") },
        { kind: "hebrew-month-day",      label: i18n("Hebrew: Iyyar 13") },
        { kind: "hebrew-month-day-year", label: i18n("Hebrew: Iyyar 13 5786") },
        { kind: "hebrew-day",            label: i18n("Hebrew day (13)") },
        { kind: "hebrew-month",          label: i18n("Hebrew month (Iyyar)") },
        { kind: "hebrew-year",           label: i18n("Hebrew year (5786)") }
    ]
    readonly property var allBlocks: standardBlocks.concat(hebrewBlocks)

    Kirigami.FormLayout {
        Layout.fillWidth: true

        CheckBox { id: dateBoxUseUtc; Kirigami.FormData.label: i18n("Date source:"); text: i18n("Use UTC (otherwise local time zone)") }

        ComboBox {
            id: gregorianStyleCombo
            Kirigami.FormData.label: i18n("Date card style:")
            model: [
                { text: i18n("Two lines (Thurs / Apr 30)"), value: "two-line" },
                { text: i18n("Single line (Thurs Apr 30)"), value: "single-line" }
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
        CheckBox { id: monthLong; text: i18n("Use long month names (April vs Apr)") }

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

    Kirigami.Separator { Layout.fillWidth: true }

    BlockList {
        Layout.fillWidth: true
        title: i18n("Desktop blocks")
        subtitle: i18n("Each enabled block is a separate card on the desktop. Drag the ≡ handle to reorder.")
        orderString: cfg_cardOrder
        allBlocks: page.allBlocks
        hebrewBlocks: page.hebrewBlocks
        hebrewEnabled: page.cfg_hebrewEnabled
        onOrderChanged: function (newOrder) { cfg_cardOrder = newOrder; }
    }
}
