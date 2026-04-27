import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_showLabels: showLabels.checked
    property alias cfg_localLabel: localLabel.text
    property alias cfg_utcLabel: utcLabel.text
    property alias cfg_autoLocalLabel: autoLocalLabel.checked
    property string cfg_labelPosition
    property alias cfg_showUtcOffset: showUtcOffset.checked
    property alias cfg_showSeconds: showSeconds.checked
    property alias cfg_use24Hour: use24Hour.checked
    property alias cfg_showDate: showDate.checked
    property string cfg_dateFormat
    property string cfg_fontFamily
    property alias cfg_fontSize: fontSize.value
    property alias cfg_bold: bold.checked
    property alias cfg_customColor: customColor.checked
    property string cfg_textColor
    property alias cfg_customLabelColor: customLabelColor.checked
    property string cfg_labelColor
    property alias cfg_spacing: spacing.value

    CheckBox { id: use24Hour; Kirigami.FormData.label: i18n("Time format:"); text: i18n("24-hour") }
    CheckBox { id: showSeconds; text: i18n("Show seconds") }

    Item { Kirigami.FormData.isSection: true }

    CheckBox { id: showLabels; Kirigami.FormData.label: i18n("Labels:"); text: i18n("Show timezone labels") }
    CheckBox { id: autoLocalLabel; text: i18n("Auto-detect local label"); enabled: showLabels.checked }
    TextField { id: localLabel; Kirigami.FormData.label: i18n("Local label:"); enabled: showLabels.checked && !autoLocalLabel.checked }
    TextField { id: utcLabel; Kirigami.FormData.label: i18n("UTC label:"); enabled: showLabels.checked }

    ComboBox {
        id: labelPosCombo
        Kirigami.FormData.label: i18n("Label position:")
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

    CheckBox { id: showDate; Kirigami.FormData.label: i18n("Date:"); text: i18n("Show date") }
    ComboBox {
        id: dateFmtCombo
        Kirigami.FormData.label: i18n("Date format:")
        enabled: showDate.checked
        model: [
            { text: i18n("Short weekday + date (Thurs, Feb 9)"), value: "weekday-short-date" },
            { text: i18n("Weekday only (Thursday)"), value: "weekday" },
            { text: i18n("Short weekday only (Thurs)"), value: "weekday-short" },
            { text: i18n("Full (Thursday, Feb 9, 2026)"), value: "full" }
        ]
        textRole: "text"
        valueRole: "value"
        currentIndex: {
            for (let i = 0; i < model.length; i++) if (model[i].value === cfg_dateFormat) return i;
            return 0;
        }
        onActivated: cfg_dateFormat = model[currentIndex].value
    }

    Item { Kirigami.FormData.isSection: true }

    RowLayout {
        Kirigami.FormData.label: i18n("Font:")
        TextField {
            id: fontFamilyField
            Layout.preferredWidth: 200
            text: cfg_fontFamily
            placeholderText: i18n("Theme default")
            onTextChanged: cfg_fontFamily = text
        }
        Button {
            text: i18n("Pick…")
            onClicked: fontDlg.open()
        }
    }
    FontDialog {
        id: fontDlg
        onAccepted: {
            cfg_fontFamily = selectedFont.family
            fontFamilyField.text = selectedFont.family
        }
    }
    SpinBox { id: fontSize; Kirigami.FormData.label: i18n("Font size (px):"); from: 0; to: 96; stepSize: 1 }
    CheckBox { id: bold; text: i18n("Bold") }

    Item { Kirigami.FormData.isSection: true }

    CheckBox { id: customColor; Kirigami.FormData.label: i18n("Time color:"); text: i18n("Use custom color") }
    RowLayout {
        enabled: customColor.checked
        Rectangle {
            width: 28; height: 28; radius: 4
            color: cfg_textColor
            border.color: Kirigami.Theme.disabledTextColor
            MouseArea { anchors.fill: parent; onClicked: timeColorDlg.open() }
        }
        TextField {
            id: timeColorField
            text: cfg_textColor
            Layout.preferredWidth: 110
            onEditingFinished: cfg_textColor = text
        }
    }
    ColorDialog { id: timeColorDlg; selectedColor: cfg_textColor; onAccepted: { cfg_textColor = selectedColor; timeColorField.text = selectedColor } }

    CheckBox { id: customLabelColor; Kirigami.FormData.label: i18n("Label color:"); text: i18n("Use custom color") }
    RowLayout {
        enabled: customLabelColor.checked
        Rectangle {
            width: 28; height: 28; radius: 4
            color: cfg_labelColor
            border.color: Kirigami.Theme.disabledTextColor
            MouseArea { anchors.fill: parent; onClicked: labelColorDlg.open() }
        }
        TextField {
            id: labelColorField
            text: cfg_labelColor
            Layout.preferredWidth: 110
            onEditingFinished: cfg_labelColor = text
        }
    }
    ColorDialog { id: labelColorDlg; selectedColor: cfg_labelColor; onAccepted: { cfg_labelColor = selectedColor; labelColorField.text = selectedColor } }

    Item { Kirigami.FormData.isSection: true }

    SpinBox { id: spacing; Kirigami.FormData.label: i18n("Gap between clocks (px):"); from: 0; to: 100 }
}
