pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications as Notifs

Scope {
    id: root

    property bool dnd: false
    property bool panelVisible: false
    property var activeToasts: []

    readonly property var server: notifServer
    readonly property var trackedNotifications: notifServer.trackedNotifications
    readonly property int unreadCount: {
        if (!notifServer.trackedNotifications) return 0;
        var list = notifServer.trackedNotifications.values || notifServer.trackedNotifications;
        if (!list) return 0;
        var count = 0;
        for (var i = 0; i < list.length; i++) {
            var n = list[i];
            if (n && ((n.summary || "").trim() !== "" || (n.body || "").trim() !== "")) {
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

            var sum = (notif.summary || "").trim();
            var body = (notif.body || "").trim();

            // Ignorer et rejeter les notifications complètement vides (aucun résumé et aucun message)
            if (sum === "" && body === "") {
                if (typeof notif.dismiss === "function") {
                    notif.dismiss();
                }
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

            var toastObj = {
                id: notif.id || Date.now() + Math.random(),
                notification: notif,
                timeout: timeoutMs,
                createdAt: Date.now()
            };

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

    // Raccourci global natif Hyprland
    GlobalShortcut {
        name: "toggleNotificationCenter"
        description: "Bascule l'affichage du centre de contrôle et de notifications"
        onPressed: function() {
            root.togglePanel();
        }
    }
}
