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
    property alias cfg_localOnRight: localOnRight.checked
    property alias cfg_showDivider: showDivider.checked
    property string cfg_labelPosition
    property alias cfg_showUtcOffset: showUtcOffset.checked
    property alias cfg_showSeconds: showSeconds.checked
    property alias cfg_use24Hour: use24Hour.checked
    property alias cfg_showDateBox: showDateBox.checked
    property alias cfg_dateBoxUseUtc: dateBoxUseUtc.checked
    property string cfg_dateBoxLayout
    property string cfg_fontFamily
    property string cfg_labelFontFamily
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

    CheckBox { id: localOnRight; Kirigami.FormData.label: i18n("Layout:"); text: i18n("Local clock on the right (UTC on left)") }
    CheckBox { id: showDivider; text: i18n("Show vertical divider between clocks") }

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

    CheckBox { id: showDateBox; Kirigami.FormData.label: i18n("Date:"); text: i18n("Show date") }
    CheckBox { id: dateBoxUseUtc; text: i18n("Use UTC (otherwise local time zone)"); enabled: showDateBox.checked }
    ComboBox {
        id: dateBoxLayoutCombo
        Kirigami.FormData.label: i18n("Date layout:")
        enabled: showDateBox.checked
        model: [
            { text: i18n("Weekday above date"), value: "weekday-top" },
            { text: i18n("Date above weekday"), value: "date-top" }
        ]
        textRole: "text"
        valueRole: "value"
        currentIndex: cfg_dateBoxLayout === "date-top" ? 1 : 0
        onActivated: cfg_dateBoxLayout = model[currentIndex].value
    }

    Item { Kirigami.FormData.isSection: true }

    RowLayout {
        Kirigami.FormData.label: i18n("Bold font:")
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
    RowLayout {
        Kirigami.FormData.label: i18n("Label font:")
        TextField {
            id: labelFontFamilyField
            Layout.preferredWidth: 200
            text: cfg_labelFontFamily
            placeholderText: i18n("Same as bold font")
            onTextChanged: cfg_labelFontFamily = text
        }
        Button {
            text: i18n("Pick…")
            onClicked: labelFontDlg.open()
        }
    }
    FontDialog {
        id: labelFontDlg
        onAccepted: {
            cfg_labelFontFamily = selectedFont.family
            labelFontFamilyField.text = selectedFont.family
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
