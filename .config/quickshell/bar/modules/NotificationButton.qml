import QtQuick
import Quickshell
import "../../theme"
import ".."
import "../components"
import "../../components"
import "../../notifications"

BarPillButton {
    id: root
    description: "Notifications · clic droit : Ne pas déranger"

    active: NotificationService.dnd
    icon: NotificationService.dnd ? "󰂛" : (NotificationService.unreadCount > 0 ? "󱅫" : "󰂚")
    iconColor: NotificationService.dnd ? BarStyle.warning : (NotificationService.unreadCount > 0 ? BarStyle.accentText : Theme.textSecondary)
    text: NotificationService.unreadCount > 0 ? NotificationService.unreadCount.toString() : ""
    textColor: Theme.textPrimary
    customPaddingH: Theme.spacingSm
    customPaddingV: 1

    onClicked: {
        NotificationService.togglePanel();
    }

    onRightClicked: {
        NotificationService.toggleDnd();
    }
}
