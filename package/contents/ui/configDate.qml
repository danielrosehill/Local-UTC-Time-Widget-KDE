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

    function isHebrewKind(kind) {
        return kind.indexOf("hebrew") === 0;
    }

    function labelFor(kind) {
        for (let i = 0; i < allBlocks.length; i++)
            if (allBlocks[i].kind === kind) return allBlocks[i].label;
        return kind;
    }

    function rebuildModel() {
        blocksModel.clear();
        const showHebrew = cfg_hebrewEnabled;
        const pool = showHebrew ? allBlocks : standardBlocks;
        const order = (cfg_cardOrder || "").split(",").map(s => s.trim()).filter(s => s.length);
        const seen = {};
        for (const k of order) {
            if (seen[k]) continue;
            if (!showHebrew && isHebrewKind(k)) continue;
            seen[k] = true;
            if (pool.some(b => b.kind === k))
                blocksModel.append({ kind: k, enabled: true });
        }
        for (const b of pool) {
            if (!seen[b.kind]) blocksModel.append({ kind: b.kind, enabled: false });
        }
    }

    function persist() {
        const out = [];
        for (let i = 0; i < blocksModel.count; i++) {
            const item = blocksModel.get(i);
            if (item.enabled) out.push(item.kind);
        }
        cfg_cardOrder = out.join(",");
    }

    Component.onCompleted: rebuildModel()

    ListModel { id: blocksModel }

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
            onCheckedChanged: page.rebuildModel()
        }
        Label {
            visible: hebrewEnabled.checked
            text: i18n("Configure formatting and location in the \"Hebrew Calendar\" page.")
            opacity: 0.7
            wrapMode: Text.WordWrap
        }
    }

    Kirigami.Separator { Layout.fillWidth: true }

    Label {
        text: i18n("Desktop blocks")
        font.bold: true
    }
    Label {
        text: i18n("Each enabled block is a separate card on the desktop. Drag the ≡ handle to reorder.")
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        opacity: 0.7
    }

    ListView {
        id: blocksView
        model: blocksModel
        Layout.fillWidth: true
        Layout.preferredHeight: contentHeight
        spacing: 2
        interactive: false
        clip: false

        moveDisplaced: Transition {
            NumberAnimation { properties: "y"; duration: 140; easing.type: Easing.OutQuad }
        }

        delegate: Item {
            id: delegateItem
            width: blocksView.width
            height: 36

            Rectangle {
                id: contentRect
                width: delegateItem.width
                height: delegateItem.height
                radius: 4
                color: dragArea.drag.active
                       ? Kirigami.Theme.highlightColor
                       : (index % 2 ? Kirigami.Theme.alternateBackgroundColor : "transparent")
                border.color: dragArea.drag.active ? Kirigami.Theme.highlightColor : "transparent"
                border.width: 1
                opacity: dragArea.drag.active ? 0.85 : 1.0

                Drag.active: dragArea.drag.active
                Drag.source: delegateItem
                Drag.hotSpot.x: width / 2
                Drag.hotSpot.y: height / 2

                states: State {
                    when: dragArea.drag.active
                    ParentChange { target: contentRect; parent: blocksView }
                    AnchorChanges { target: contentRect; anchors.horizontalCenter: undefined; anchors.verticalCenter: undefined }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 4
                    anchors.rightMargin: 8
                    spacing: 8

                    // Hamburger drag handle
                    Item {
                        Layout.preferredWidth: 26
                        Layout.fillHeight: true

                        MouseArea {
                            id: dragArea
                            anchors.fill: parent
                            cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                            drag.target: contentRect
                            drag.axis: Drag.YAxis
                            drag.minimumY: -delegateItem.height
                            drag.maximumY: blocksView.height
                            onReleased: {
                                contentRect.Drag.drop();
                                page.persist();
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 3
                            Rectangle { width: 14; height: 2; radius: 1; color: dragArea.drag.active ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.disabledTextColor }
                            Rectangle { width: 14; height: 2; radius: 1; color: dragArea.drag.active ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.disabledTextColor }
                            Rectangle { width: 14; height: 2; radius: 1; color: dragArea.drag.active ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.disabledTextColor }
                        }
                    }

                    CheckBox {
                        checked: model.enabled
                        onToggled: {
                            blocksModel.setProperty(index, "enabled", checked);
                            page.persist();
                        }
                    }
                    Label {
                        text: page.labelFor(model.kind)
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        color: dragArea.drag.active ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        font.italic: page.isHebrewKind(model.kind)
                        horizontalAlignment: page.isHebrewKind(model.kind) ? Text.AlignRight : Text.AlignLeft
                        opacity: page.isHebrewKind(model.kind) && !dragArea.drag.active ? 0.85 : 1.0
                    }
                }
            }

            DropArea {
                anchors.fill: parent
                onEntered: function (drag) {
                    const src = drag.source;
                    if (!src || src === delegateItem) return;
                    const from = src.DelegateModel ? src.DelegateModel.itemsIndex : -1;
                    // Fall back: scan blocksModel for matching delegate
                    let fromIdx = -1;
                    for (let i = 0; i < blocksModel.count; i++) {
                        if (src === blocksView.itemAtIndex(i)) { fromIdx = i; break; }
                    }
                    if (fromIdx === -1 || fromIdx === index) return;
                    blocksModel.move(fromIdx, index, 1);
                    page.persist();
                }
            }
        }
    }
}
