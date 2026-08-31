import QtQuick
// LazyPopup : Loader à instanciation paresseuse pour les popups flottantes de la barre.
//
// Rôle (optimisation mémoire) :
//   1. La popup (PopupWindow + surface Wayland + contexts GPU) n'existe PAS au démarrage ;
//      elle n'est instanciée qu'à la demande (survol 140 ms ou clic).
//   2. À la fermeture, dès que l'animation de sortie est terminée (ModulePopup.fullyClosed),
//      active=false détruit l'objet, sa surface Wayland et ses textures.
//   3. Les délais anti-spam de survol (140 ms ouverture / 320 ms fermeture) sont préservés
//      à l'identique — ils vivent ici, à l'extérieur de la popup, car le module de la barre
//      doit déclencher l'instanciation AVANT que la popup n'existe.
//
// Usage dans un module (remplace l'instanciation statique) :
//   LazyPopup {
//       targetWindow: root.parentWindow
//       anchor: root                // l'item de la barre (doit exposer isHovered)
//       popupComponent: CpuPopup {} // déclarée inline pour la liaison des propriétés
//   }
//   ... et dans les handlers du module :
//       onClicked: cpuLazy.toggle()
//       onRightClicked: cpuLazy.toggle()
Loader {
    id: loaderRoot

    /** Composant popup à instancier (CpuPopup, MemoryPopup, ...). */
    property Component popupComponent
    /** Fenêtre parente (PanelWindow de la barre) passée à la popup. */
    property var targetWindow: null
    /** Item d'ancrage du survol : le module de la barre (doit exposer isHovered). */
    property Item anchor: null
    /** Ouvrir au survol prolongé (défaut : oui, comme avant le lazy loading). */
    property bool openOnHover: true

    // État interne : demande d'instanciation en cours (survol validé ou clic).
    property bool hoverRequested: false
    property bool clickRequested: false

    active: hoverRequested || clickRequested
    sourceComponent: popupComponent

    /** État de survol de l'item d'ancrage (module de la barre). */
    readonly property bool anchorHovered: anchor ? anchor.isHovered : false

    // Transitions de survol du module : déclenchent l'instanciation (140 ms) ou la
    // temporisation de fermeture (320 ms), exactement comme les anciens timers de ModulePopup.
    onAnchorHoveredChanged: {
        if (anchorHovered) {
            closeDelay.stop();
            if (openOnHover) {
                hoverDelay.restart();
            }
        } else {
            hoverDelay.stop();
            scheduleCloseIfIdle();
        }
    }

    /** Bascule ouverte/fermée — point d'entrée des clics du module. */
    function toggle() {
        if (active && item && item.isOpen) {
            item.close();
        } else {
            clickRequested = true;
            if (item) {
                item.open();
            }
        }
    }

    function close() {
        hoverRequested = false;
        clickRequested = false;
        if (item) {
            item.close();
        }
    }

    /**
     * Réconcilie l'état du curseur avec la temporisation de fermeture : démarre le délai de
     * 320 ms si ni l'ancre ni la popup ne sont survolées, l'arrête sinon (réplique exacte de
     * la logique des anciens timers internes à ModulePopup).
     */
    function scheduleCloseIfIdle() {
        if (!active) return;
        if (!anchorHovered && !(item && item.isHovered)) {
            closeDelay.restart();
        } else {
            closeDelay.stop();
        }
    }

    // Câblage de la popup fraîchement instanciée puis ouverture immédiate.
    onLoaded: {
        if (item) {
            if (!item.parentWindow) item.parentWindow = loaderRoot.targetWindow;
            if (!item.anchorItem) item.anchorItem = loaderRoot.anchor;
            item.open();
        }
        scheduleCloseIfIdle();
    }

    // Suivi du survol de la popup elle-même : tant que le curseur est dedans, on reste ouvert.
    Connections {
        target: loaderRoot.item
        ignoreUnknownSignals: true

        function onIsHoveredChanged() {
            loaderRoot.scheduleCloseIfIdle();
        }

        // Fin de l'animation de sortie de la popup : destruction immédiate (lazy destroy).
        function onFullyClosed() {
            loaderRoot.clickRequested = false;
            loaderRoot.hoverRequested = false;
            // NB : Ne JAMAIS assigner active=false de façon impérative car cela brise le binding QML !
            // La mise à 0 de clickRequested et hoverRequested réévalue active automatiquement.
            if (loaderRoot.anchorHovered && loaderRoot.openOnHover) {
                hoverDelay.restart();
            }
        }
    }

    // Délai anti-ouverture accidentelle (identique à l'ancien ModulePopup : 140 ms).
    Timer {
        id: hoverDelay
        interval: 140
        repeat: false
        onTriggered: {
            if (loaderRoot.anchorHovered) {
                loaderRoot.hoverRequested = true;
                if (loaderRoot.item) {
                    loaderRoot.item.open();
                }
            }
        }
    }

    // Délai de grâce pour atteindre la popup (identique à l'ancien ModulePopup : 320 ms).
    Timer {
        id: closeDelay
        interval: 320
        repeat: false
        onTriggered: {
            // On ne referme que si le curseur n'est ni sur le module ni dans la popup.
            if (!(loaderRoot.item && loaderRoot.item.isHovered) && !loaderRoot.anchorHovered) {
                if (loaderRoot.item) {
                    loaderRoot.item.close();  // anime puis émet fullyClosed
                }
            }
        }
    }
}
