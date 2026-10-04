.pragma library

// Le desktop entry identifie l'application même si son nom affiché change.
function applicationKey(notification) {
    if (notification.desktopEntry) return "desktop:" + notification.desktopEntry;
    return "name:" + (notification.appName || "Application");
}

function groupNotifications(notifications, receivedAt) {
    var groups = [];
    var byApplication = Object.create(null);
    var sorted = notifications.slice().sort(function(a, b) {
        return (receivedAt[b.id] || 0) - (receivedAt[a.id] || 0) || b.id - a.id;
    });
    sorted.forEach(function(notification) {
        var key = applicationKey(notification);
        var group = byApplication[key];
        if (!group) {
            group = {
                key: key,
                appName: notification.appName || "Application",
                appIcon: notification.appIcon || "",
                notifications: []
            };
            byApplication[key] = group;
            groups.push(group);
        }
        if (!group.appIcon && notification.appIcon) group.appIcon = notification.appIcon;
        group.notifications.push(notification);
    });
    return groups;
}

function relativeTime(received, now) {
    if (!received) return "";
    var minutes = Math.max(0, Math.floor((now - received) / 60000));
    if (minutes === 0) return "À l'instant";
    if (minutes < 60) return minutes + " min";
    if (minutes < 1440) return Math.floor(minutes / 60) + " h";
    return Math.floor(minutes / 1440) + " j";
}
