pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications as Notifs

Singleton {
    id: root

    property bool dnd: false
    property bool panelVisible: false
    property var activeToasts: []

    // Validation stricte du contenu textuel d'une notification :
    // Élimine les notifications vides, les balises HTML orphelines (<p></p>, <span>),
    // les entités HTML (&nbsp;) et les espaces/séparateurs invisibles Unicode.
    // Doc officielle Quickshell v0.3.1 (https://quickshell.org/docs/v0.3.1/types/Quickshell.Services.Notifications/Notification/) :
    // summary et body sont des chaînes exposées par le serveur D-Bus.
    function isValidNotification(notif): bool {
        if (!notif) return false;
        var stripText = function(str) {
            if (!str) return "";
            return str
                .replace(/<[^>]*>/g, "")
                .replace(/&[a-zA-Z0-9#]+;/g, " ")
                .replace(/[\s\u200B\u00A0\uFEFF]+/g, " ")
                .trim();
        };
        var sum = stripText(notif.summary);
        var body = stripText(notif.body);
        return sum.length > 0 || body.length > 0;
    }

    readonly property var server: notifServer
    readonly property var trackedNotifications: notifServer.trackedNotifications
    readonly property int unreadCount: {
        if (!notifServer.trackedNotifications) return 0;
        var list = notifServer.trackedNotifications.values || notifServer.trackedNotifications;
        if (!list) return 0;
        var count = 0;
        for (var i = 0; i < list.length; i++) {
            if (root.isValidNotification(list[i])) {
                count++;
            }
        }
        return count;
    }

    Notifs.NotificationServer {
        id: notifServer

        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        keepOnReload: false

        onNotification: function(notif) {
            if (!notif) return;

            // Rejet immédiat de toute notification dépourvue de contenu textuel signifiant
            if (!root.isValidNotification(notif)) {
                if (typeof notif.dismiss === "function") {
                    notif.dismiss();
                }
                notif.tracked = false;
                return;
            }

            notif.tracked = true;

            // Si en mode Ne Pas Déranger, ne pas afficher de toast flottant (sauvegardé directement dans l'historique)
            if (root.dnd) return;

            var timeoutMs = 6000;
            // Urgence
            if (notif.urgency === Notifs.NotificationUrgency.Low) {
                timeoutMs = 3500;
            } else if (notif.urgency === Notifs.NotificationUrgency.Critical) {
                timeoutMs = 0; // Infini pour les alertes critiques
            }

            var toastId = notif.id || (Date.now() + Math.random());
            var toastObj = {
                id: toastId,
                notification: notif,
                timeout: timeoutMs,
                createdAt: Date.now()
            };

            // Surveillance de la fermeture de la notification (ex: fermée à distance par le client D-Bus
            // ou expirée) : suppression immédiate du toast pour éviter toute carte orpheline vide.
            // Doc Quickshell v0.3.1 : signal closed(reason) sur Notification.
            if (typeof notif.closed !== "undefined" && typeof notif.closed.connect === "function") {
                notif.closed.connect(function() {
                    root.dismissToast(toastId);
                });
            }

            var list = root.activeToasts.slice();
            list.unshift(toastObj);
            // Limiter à 4 toasts simultanés à l'écran pour préserver l'ergonomie
            if (list.length > 4) {
                list.pop();
            }
            root.activeToasts = list;
        }
    }

    function togglePanel() {
        root.panelVisible = !root.panelVisible;
    }

    function toggleDnd() {
        root.dnd = !root.dnd;
    }

    function clearAll() {
        if (notifServer.trackedNotifications && notifServer.trackedNotifications.values) {
            var items = notifServer.trackedNotifications.values.slice();
            for (var i = 0; i < items.length; i++) {
                if (items[i] && typeof items[i].dismiss === "function") {
                    items[i].dismiss();
                }
            }
        }
        root.activeToasts = [];
    }

    function dismissNotification(notif) {
        if (notif && typeof notif.dismiss === "function") {
            notif.dismiss();
        }
        root.dismissToast(notif.id);
    }

    function dismissToast(toastId) {
        var list = root.activeToasts.filter(function(t) {
            return t.id !== toastId && (!t.notification || t.notification.id !== toastId);
        });
        root.activeToasts = list;
    }

    // Gestionnaire IPC pour contrôle externe (CLI ou scripts) : quickshell ipc call notifications toggle
    IpcHandler {
        target: "notifications"

        function toggle(): void {
            root.togglePanel();
        }

        function toggleDnd(): void {
            root.toggleDnd();
        }

        function clear(): void {
            root.clearAll();
        }
    }

    // ==========================================
    // PERSISTANCE DU BLOC-NOTES (Scratchpad)
    // ==========================================
    // Maintenu dans le singleton pour survivre à la destruction/recréation du Loader
    // dans shell.qml et garantir une écriture atomique sur disque même lors d'une fermeture rapide.
    property string scratchpadText: ""

    Process {
        id: ensureStateDir
        command: ["sh", "-c", "mkdir -p \"$(dirname \"$1\")\"", "--", Quickshell.statePath("scratchpad.txt")]
        Component.onCompleted: running = true
    }

    FileView {
        id: scratchpadFile
        path: Quickshell.statePath("scratchpad.txt")
        blockLoading: true
        printErrors: false

        onLoaded: root.loadNotesFromDisk()
        onFileChanged: root.loadNotesFromDisk()
    }

    Timer {
        id: saveNotesTimer
        interval: 300
        repeat: false
        onTriggered: {
            scratchpadFile.setText(root.scratchpadText);
        }
    }

    function loadNotesFromDisk() {
        var content = scratchpadFile.text();
        if (content !== undefined && content !== null) {
            root.scratchpadText = content;
        }
    }

    function updateNotes(text) {
        root.scratchpadText = text;
        saveNotesTimer.restart();
    }

    function flushNotes(text) {
        if (text !== undefined && text !== null) {
            root.scratchpadText = text;
        }
        saveNotesTimer.stop();
        scratchpadFile.setText(root.scratchpadText);
    }

    onPanelVisibleChanged: {
        if (!panelVisible) {
            root.flushNotes();
        }
    }
}
