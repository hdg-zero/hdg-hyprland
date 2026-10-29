import QtQuick

// Le compte à rebours appartient au service : recréer une carte ne le réinitialise pas.
QtObject {
    id: root
    property int durationMs: 0
    property real remainingMs: durationMs
    property bool paused: false
    property bool stopped: false
    property bool finishing: false
    property bool initialized: false
    property double deadlineMs: 0
    signal expired()

    // Dix mises à jour par seconde suffisent pour la jauge d'un pixel ;
    // aucune propriété JavaScript n'est animée à la fréquence de l'écran.
    property Timer countdown: Timer {
        interval: 100
        repeat: true
        running: root.initialized && root.durationMs > 0 && !root.paused && !root.stopped && !root.finishing
        onTriggered: root.updateRemaining()
    }
    // Laisser finir le fondu avant que le service ne retire la carte.
    property Timer exitDelay: Timer {
        interval: 150
        onTriggered: { if (!root.stopped) root.expired(); }
    }
    function updateRemaining() {
        remainingMs = Math.max(0, Math.min(durationMs, deadlineMs - Date.now()));
        if (remainingMs <= 0 && !finishing && !stopped) {
            finishing = true;
            exitDelay.start();
        }
    }
    function stop() { stopped = true; exitDelay.stop(); }
    onPausedChanged: {
        if (!initialized || stopped || finishing || durationMs <= 0) return;
        if (paused) updateRemaining();
        else deadlineMs = Date.now() + remainingMs;
    }
    Component.onCompleted: {
        deadlineMs = Date.now() + durationMs;
        initialized = true;
    }
}
