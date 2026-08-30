import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"

PopupWindow {
    id: root

    property var parentWindow: null
    property var anchorItem: null
    property bool autoHover: true
    property bool isOpen: false
    signal fullyClosed()
    
    property real widthPercent: 0
    property alias cardWidth: card.implicitWidth
    property alias cardHeight: card.implicitHeight
    default property alias content: innerContainer.data

    readonly property bool isHovered: (anchorItem && anchorItem.isHovered) || cardHoverHandler.hovered

    readonly property int effectiveWidth: {
        if (widthPercent > 0) {
            return Theme.relWidth(widthPercent, parentWindow ? parentWindow.screen : null);
        }
        return card.implicitWidth > 0 ? Math.round(card.implicitWidth) : Theme.relWidth(Theme.popupWidthPercentCompact, parentWindow ? parentWindow.screen : null);
    }

    anchor.window: parentWindow
    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: Theme.spacingSm

    color: "transparent"

    // La fenêtre reste affichée pendant le fondu de sortie (opacité de la carte), puis se
    // masque dès que l'opacité atteint 0. Si open()/close() sont appelés dans la même frame,
    // l'opacité ne quitte jamais 0 et la fenêtre se masque immédiatement (aucune popup fantôme).
    // NB : ne plus assigner `visible` de façon impérative, cela casserait ce binding.
    visible: root.isOpen || card.opacity > 0.0

    implicitWidth: effectiveWidth
    implicitHeight: Math.round(card.implicitHeight)

    function toggle() {
        if (isOpen) {
            close();
        } else {
            open();
        }
    }

    function open() {
        isOpen = true;
    }

    function close() {
        isOpen = false;
    }

    GlassCard {
        id: card
        anchors.fill: parent
        customColor: Qt.rgba(0.094, 0.094, 0.145, 0.95)
        customBorderColor: Theme.glassBorder
        customRadius: Theme.radiusLarge

        opacity: root.isOpen ? 1.0 : 0.0
        scale: root.isOpen ? 1.0 : 0.95
        transformOrigin: Item.Top

        Behavior on opacity {
            NumberAnimation {
                id: opacityAnim
                duration: Theme.animDurationFast
                easing.type: Theme.easingType
                onRunningChanged: {
                    if (!running && !root.isOpen && card.opacity <= 0.0) {
                        root.fullyClosed();
                    }
                }
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.animDurationFast
                easing.type: Theme.easingType
            }
        }

        HoverHandler {
            id: cardHoverHandler
        }

        Item {
            id: innerContainer
            anchors.fill: parent
            anchors.margins: Theme.spacingMd
        }
    }
}
