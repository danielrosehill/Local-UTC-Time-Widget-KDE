import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: page
    spacing: Kirigami.Units.largeSpacing

    property string cfg_panelCardOrder

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

    Label {
        text: i18n("These blocks render in the system tray / panel when the widget is docked there. The desktop layout is configured separately in \"Date & Blocks\".")
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        opacity: 0.8
    }

    BlockList {
        Layout.fillWidth: true
        title: i18n("Tray blocks")
        subtitle: i18n("Compact blocks shown in the panel. Drag the ≡ handle to reorder. Hebrew rows (italic, right-aligned) need the Hebrew Calendar page enabled to render.")
        orderString: cfg_panelCardOrder
        allBlocks: page.allBlocks
        hebrewBlocks: page.hebrewBlocks
        onOrderChanged: function (newOrder) { cfg_panelCardOrder = newOrder; }
    }
}
