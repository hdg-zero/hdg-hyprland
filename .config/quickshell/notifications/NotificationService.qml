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
    property var receivedAt: ({})

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

            // L'horodatage reste disponible dans l'historique, y compris en DND.
            var receivedId = notif.id;
            var times = Object.assign({}, root.receivedAt);
            times[receivedId] = Date.now();
            root.receivedAt = times;

            notif.closed.connect(function() {
                var remainingTimes = Object.assign({}, root.receivedAt);
                delete remainingTimes[receivedId];
                root.receivedAt = remainingTimes;
                root.dismissToast(receivedId);
            });

            // Si en mode Ne Pas Déranger, ne pas afficher de toast flottant (sauvegardé directement dans l'historique)
            if (root.dnd) return;

            var timeoutMs = 6000;
            // Urgence
            if (notif.urgency === Notifs.NotificationUrgency.Low) {
                timeoutMs = 3500;
            } else if (notif.urgency === Notifs.NotificationUrgency.Critical) {
                timeoutMs = 0; // Infini pour les alertes critiques
            }

            root.addToast(notif, timeoutMs);
        }
    }

    Component { id: lifetimeFactory; ToastLifetime {} }

    function releaseToast(toast) {
        if (!toast.lifetime) return;
        toast.lifetime.stop();
        toast.lifetime.destroy();
    }

    function addToast(notif, timeoutMs) {
        root.dismissToast(notif.id);
        var lifetime = lifetimeFactory.createObject(root, {durationMs: timeoutMs});
        var toast = {id: notif.id, notification: notif, timeout: timeoutMs,
            createdAt: Date.now(), lifetime: lifetime};
        lifetime.expired.connect(function() {
            if (root.activeToasts.some(function(t) { return t.lifetime === lifetime; }))
                root.dismissToast(toast.id);
        });
        var list = root.activeToasts.slice();
        list.unshift(toast);
        while (list.length > 4) root.releaseToast(list.pop());
        root.activeToasts = list;
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
        root.activeToasts.forEach(root.releaseToast);
        root.activeToasts = [];
    }

    function dismissNotification(notif) {
        if (!notif) return;
        var id = notif.id;
        if (notif && typeof notif.dismiss === "function") {
            notif.dismiss();
        }
        root.dismissToast(id);
    }

    function dismissToast(toastId) {
        if (!root.activeToasts.some(function(t) { return t.id === toastId; })) return;
        var list = root.activeToasts.filter(function(t) {
            var keep = t.id !== toastId && (!t.notification || t.notification.id !== toastId);
            if (!keep) root.releaseToast(t);
            return keep;
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
