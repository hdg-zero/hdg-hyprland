import QtQuick
import Quickshell
import "../../theme"
import "../../components"
import "../../notifications"

PillButton {
    id: root

    icon: NotificationService.dnd ? "󰂛" : (NotificationService.unreadCount > 0 ? "󱅫" : "󰂚")
    iconColor: NotificationService.dnd ? Theme.warning : (NotificationService.unreadCount > 0 ? Theme.accent : Theme.textSecondary)
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
