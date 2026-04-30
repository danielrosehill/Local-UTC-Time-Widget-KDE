import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_desktopCards: desktopCards.checked
    property alias cfg_desktopShowContainer: desktopShowContainer.checked
    property string cfg_desktopOrientation
    property string cfg_desktopPalette
    property alias cfg_spacing: spacing.value

    CheckBox { id: desktopCards; Kirigami.FormData.label: i18n("Card style:"); text: i18n("Render desktop blocks as rounded cards") }
    CheckBox { id: desktopShowContainer; text: i18n("Show outer container background"); enabled: desktopCards.checked }

    ComboBox {
        id: orientationCombo
        Kirigami.FormData.label: i18n("Stack:")
        model: [
            { text: i18n("Horizontal (side-by-side)"), value: "horizontal" },
            { text: i18n("Vertical (stacked)"), value: "vertical" }
        ]
        textRole: "text"
        valueRole: "value"
        currentIndex: cfg_desktopOrientation === "vertical" ? 1 : 0
        onActivated: cfg_desktopOrientation = model[currentIndex].value
    }

    ComboBox {
        id: paletteCombo
        Kirigami.FormData.label: i18n("Palette:")
        enabled: desktopCards.checked
        model: [
            { text: i18n("Light — cream + white"), value: "light" },
            { text: i18n("Dark — charcoal"), value: "dark" },
            { text: i18n("Slate — cool blue-grey"), value: "slate" },
            { text: i18n("Warm — terracotta + ivory"), value: "warm" },
            { text: i18n("Midnight — navy + cyan"), value: "midnight" },
            { text: i18n("Auto (Plasma theme)"), value: "auto" }
        ]
        textRole: "text"
        valueRole: "value"
        currentIndex: {
            for (let i = 0; i < model.length; i++) if (model[i].value === cfg_desktopPalette) return i;
            return 0;
        }
        onActivated: cfg_desktopPalette = model[currentIndex].value
    }

    Item { Kirigami.FormData.isSection: true }

    SpinBox { id: spacing; Kirigami.FormData.label: i18n("Gap between blocks (px):"); from: 0; to: 100 }
}
