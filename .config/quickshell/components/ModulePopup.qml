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
    // Lazy loading : fullyClosed() n'est émis qu'une fois par cycle et seulement après une
    // vraie ouverture (à l'instanciation, opacity==0 && !isOpen — sans ce garde, le signal
    // partirait immédiatement et le Loader qui vient de créer la popup la détruirait).
    property bool hasBeenOpened: false
    signal fullyClosed()

    function markOpened() {
        root.hasBeenOpened = true;
    }
    
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
        root.markOpened();
        isOpen = true;
    }

    function close() {
        isOpen = false;
        // Cas « open()/close() dans la même frame » : l'opacité n'a jamais quitté 0.0, le
        // handler onOpacityChanged ne repartira pas — on émet directement pour permettre la
        // destruction par le Loader. Garde hasBeenOpened : une popup créée puis fermée sans
        // jamais être ouverte n'émet pas (c'est LazyPopup.onLoaded qui la démonte alors).
        if (root.hasBeenOpened && card.opacity <= 0.0) {
            root.fullyClosed();
        }
    }

    // NOTE (lazy loading) : les timers de survol (140 ms / 320 ms) et la Connections
    // onEntered/onExited ont été déplacés dans LazyPopup.qml — l'item source du survol (le
    // module de la barre) doit activer le Loader AVANT que la popup n'existe ; les timers ne
    // peuvent donc plus résider ici (ils tourneraient sur rien à l'état non instancié).

    GlassCard {
        id: card
        anchors.fill: parent
        customColor: Qt.rgba(0.094, 0.094, 0.145, 0.95)
        customBorderColor: Theme.glassBorder
        customRadius: Theme.radiusLarge

        opacity: root.isOpen ? 1.0 : 0.0
        scale: root.isOpen ? 1.0 : 0.95
        transformOrigin: Item.Top

        // Fin de l'animation de sortie : opacité revenue à 0 après une vraie ouverture
        // → la fenêtre, sa surface Wayland et ses contexts GPU peuvent être détruits.
        onOpacityChanged: {
            if (root.hasBeenOpened && !root.isOpen && opacity <= 0.0) {
                root.fullyClosed();
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animDurationFast
                easing.type: Theme.easingType
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
