import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: Kirigami.Units.smallSpacing

    property string title: ""
    property string subtitle: ""
    property string orderString: ""
    property var allBlocks: []
    property var hebrewBlocks: []
    property bool hebrewEnabled: false

    signal orderChanged(string newOrder)

    function _isHebrewKind(kind) {
        for (let i = 0; i < hebrewBlocks.length; i++)
            if (hebrewBlocks[i].kind === kind) return true;
        return false;
    }

    function labelFor(kind) {
        for (let i = 0; i < allBlocks.length; i++)
            if (allBlocks[i].kind === kind) return allBlocks[i].label;
        return kind;
    }

    function rebuildModel() {
        blocksModel.clear();
        const order = (orderString || "").split(",").map(s => s.trim()).filter(s => s.length);
        const seen = {};
        const pool = hebrewEnabled
            ? allBlocks
            : allBlocks.filter(b => !_isHebrewKind(b.kind));
        for (const k of order) {
            if (seen[k]) continue;
            if (!hebrewEnabled && _isHebrewKind(k)) continue;
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
        const joined = out.join(",");
        orderString = joined;
        root.orderChanged(joined);
    }

    onHebrewEnabledChanged: rebuildModel()
    Component.onCompleted: rebuildModel()

    ListModel { id: blocksModel }

    Label {
        text: root.title
        font.bold: true
        visible: text.length > 0
    }
    Label {
        text: root.subtitle
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
        opacity: 0.7
        visible: text.length > 0
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
                                root.persist();
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
                            root.persist();
                        }
                    }
                    Label {
                        text: root.labelFor(model.kind)
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        color: dragArea.drag.active ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        font.italic: root._isHebrewKind(model.kind)
                        horizontalAlignment: root._isHebrewKind(model.kind) ? Text.AlignRight : Text.AlignLeft
                        opacity: root._isHebrewKind(model.kind) && !dragArea.drag.active ? 0.85 : 1.0
                    }
                }
            }

            DropArea {
                anchors.fill: parent
                onEntered: function (drag) {
                    const src = drag.source;
                    if (!src || src === delegateItem) return;
                    let fromIdx = -1;
                    for (let i = 0; i < blocksModel.count; i++) {
                        if (src === blocksView.itemAtIndex(i)) { fromIdx = i; break; }
                    }
                    if (fromIdx === -1 || fromIdx === index) return;
                    blocksModel.move(fromIdx, index, 1);
                    root.persist();
                }
            }
        }
    }
}
