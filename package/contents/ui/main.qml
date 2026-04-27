import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property bool labelsBelow: Plasmoid.configuration.labelPosition === "below"
    property var nowLocal: new Date()
    property var nowUtc: new Date()

    function fmtTime(d, utc) {
        const pad = n => n.toString().padStart(2, "0");
        let h = utc ? d.getUTCHours() : d.getHours();
        const m = utc ? d.getUTCMinutes() : d.getMinutes();
        const s = utc ? d.getUTCSeconds() : d.getSeconds();
        let suffix = "";
        if (!Plasmoid.configuration.use24Hour) {
            suffix = h >= 12 ? " PM" : " AM";
            h = h % 12; if (h === 0) h = 12;
        }
        let str = pad(h) + ":" + pad(m);
        if (Plasmoid.configuration.showSeconds) str += ":" + pad(s);
        return str + suffix;
    }

    function localTzAbbrev() {
        try {
            const parts = new Intl.DateTimeFormat(undefined, { timeZoneName: "short" }).formatToParts(nowLocal);
            const tz = parts.find(p => p.type === "timeZoneName");
            if (tz && tz.value && !/^GMT/i.test(tz.value)) return tz.value;
        } catch (e) {}
        const s = nowLocal.toString();
        const m = s.match(/\(([^)]+)\)$/);
        if (m) {
            const parts = m[1].split(" ");
            if (parts.length > 1) return parts.map(p => p[0]).join("");
            return m[1];
        }
        return utcOffsetString();
    }

    function utcOffsetString() {
        const off = -nowLocal.getTimezoneOffset();
        const sign = off >= 0 ? "+" : "-";
        const a = Math.abs(off);
        const h = Math.floor(a / 60);
        const m = a % 60;
        return "UTC" + sign + h + (m ? ":" + m.toString().padStart(2, "0") : "");
    }

    function fmtDate(d) {
        const wdLong = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"][d.getDay()];
        const wdShort = ["Sun","Mon","Tues","Wed","Thurs","Fri","Sat"][d.getDay()];
        const mo = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][d.getMonth()];
        switch (Plasmoid.configuration.dateFormat) {
            case "weekday": return wdLong;
            case "weekday-short": return wdShort;
            case "full": return wdLong + ", " + mo + " " + d.getDate() + ", " + d.getFullYear();
            case "weekday-short-date":
            default: return wdShort + ", " + mo + " " + d.getDate();
        }
    }

    Timer {
        interval: Plasmoid.configuration.showSeconds ? 500 : 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const d = new Date();
            root.nowLocal = d;
            root.nowUtc = d;
        }
    }

    preferredRepresentation: fullRepresentation

    fullRepresentation: Item {
        id: rootItem
        Layout.minimumWidth: content.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.minimumHeight: content.implicitHeight + Kirigami.Units.smallSpacing
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight

        readonly property color tColor: Plasmoid.configuration.customColor
            ? Plasmoid.configuration.textColor
            : Kirigami.Theme.textColor
        readonly property color lColor: Plasmoid.configuration.customLabelColor
            ? Plasmoid.configuration.labelColor
            : Qt.darker(tColor, 1.3)
        readonly property string ff: Plasmoid.configuration.fontFamily || Kirigami.Theme.defaultFont.family
        readonly property int fsTime: Plasmoid.configuration.fontSize > 0
            ? Plasmoid.configuration.fontSize
            : Kirigami.Theme.defaultFont.pixelSize + 2
        readonly property int fsLabel: Math.max(8, fsTime - 4)

        ColumnLayout {
            id: content
            anchors.centerIn: parent
            spacing: 2

            RowLayout {
                id: clocksRow
                spacing: Plasmoid.configuration.spacing
                Layout.alignment: Qt.AlignHCenter
                layoutDirection: Plasmoid.configuration.localOnRight ? Qt.RightToLeft : Qt.LeftToRight

                // LOCAL block
                ColumnLayout {
                    spacing: 0
                    Layout.alignment: Qt.AlignVCenter

                    RowLayout {
                        spacing: 4
                        Layout.alignment: Qt.AlignHCenter
                        Text {
                            text: fmtTime(nowLocal, false)
                            color: rootItem.tColor
                            font.family: rootItem.ff
                            font.pixelSize: rootItem.fsTime
                            font.bold: Plasmoid.configuration.bold
                        }
                        Text {
                            visible: Plasmoid.configuration.showLabels && !labelsBelow
                            text: Plasmoid.configuration.autoLocalLabel ? localTzAbbrev() : Plasmoid.configuration.localLabel
                            color: rootItem.lColor
                            font.family: rootItem.ff
                            font.pixelSize: rootItem.fsLabel
                            font.bold: Plasmoid.configuration.bold
                        }
                    }
                    Text {
                        visible: Plasmoid.configuration.showLabels && labelsBelow
                        Layout.alignment: Qt.AlignHCenter
                        text: {
                            const lbl = Plasmoid.configuration.autoLocalLabel ? localTzAbbrev() : Plasmoid.configuration.localLabel;
                            return Plasmoid.configuration.showUtcOffset ? lbl + " (" + utcOffsetString() + ")" : lbl;
                        }
                        color: rootItem.lColor
                        font.family: rootItem.ff
                        font.pixelSize: rootItem.fsLabel
                        font.bold: Plasmoid.configuration.bold
                    }
                }

                // Divider
                Rectangle {
                    visible: Plasmoid.configuration.showDivider
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    color: rootItem.lColor
                    opacity: 0.35
                }

                // UTC block
                ColumnLayout {
                    spacing: 0
                    Layout.alignment: Qt.AlignVCenter

                    RowLayout {
                        spacing: 4
                        Layout.alignment: Qt.AlignHCenter
                        Text {
                            text: fmtTime(nowUtc, true)
                            color: rootItem.tColor
                            font.family: rootItem.ff
                            font.pixelSize: rootItem.fsTime
                            font.bold: Plasmoid.configuration.bold
                        }
                        Text {
                            visible: Plasmoid.configuration.showLabels && !labelsBelow
                            text: Plasmoid.configuration.utcLabel
                            color: rootItem.lColor
                            font.family: rootItem.ff
                            font.pixelSize: rootItem.fsLabel
                            font.bold: Plasmoid.configuration.bold
                        }
                    }
                    Text {
                        visible: Plasmoid.configuration.showLabels && labelsBelow
                        Layout.alignment: Qt.AlignHCenter
                        text: Plasmoid.configuration.utcLabel
                        color: rootItem.lColor
                        font.family: rootItem.ff
                        font.pixelSize: rootItem.fsLabel
                        font.bold: Plasmoid.configuration.bold
                    }
                }
            }

            Text {
                visible: Plasmoid.configuration.showDate
                Layout.alignment: Qt.AlignHCenter
                text: fmtDate(nowLocal)
                color: rootItem.lColor
                font.family: rootItem.ff
                font.pixelSize: rootItem.fsLabel
                font.bold: Plasmoid.configuration.bold
            }
        }
    }
}
