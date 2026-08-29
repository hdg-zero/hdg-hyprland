import QtQuick
import QtQuick.Layouts
import "../theme"
import "./sections"

Item {
    id: root
    anchors.fill: parent

    property var parentWindow: null

    // Fond de la barre collée aux bords de l'écran avec bordure inférieure
    Rectangle {
        anchors.fill: parent
        color: Theme.background

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 1
            color: Theme.glassBorder
        }
    }

    // Section GAUCHE : Lanceur + Workspaces + CPU + RAM + Network + MPRIS
    LeftSection {
        parentWindow: root.parentWindow
        anchors {
            left: parent.left
            leftMargin: Theme.spacingSm
            verticalCenter: parent.verticalCenter
        }
    }

    // Section CENTRE : Titre de la fenêtre active
    CenterSection {
        parentWindow: root.parentWindow
        anchors.centerIn: parent
    }

    // Section DROITE : Taskbar + SystemTray + Backlight + Audio + Batterie + Notifications + Horloge + Power
    RightSection {
        parentWindow: root.parentWindow
        anchors {
            right: parent.right
            rightMargin: Theme.spacingSm
            verticalCenter: parent.verticalCenter
        }
    }
}
