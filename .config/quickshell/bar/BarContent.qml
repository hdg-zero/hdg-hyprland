import QtQuick
import QtQuick.Layouts
import "../theme"
import "./sections"

Item {
    id: root
    anchors.fill: parent

    property var parentWindow: null
    implicitHeight: parentWindow ? parentWindow.implicitHeight : 26

    // Fond de la barre collée aux bords de l'écran avec bordure inférieure
    Rectangle {
        anchors.fill: parent
        color: BarStyle.background

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 1
            color: BarStyle.border
        }
    }

    // Section GAUCHE : Lanceur + Workspaces + CPU + RAM + Network + MPRIS
    LeftSection {
        id: leftSection
        parentWindow: root.parentWindow
        anchors {
            left: parent.left
            leftMargin: Theme.spacingSm
            verticalCenter: parent.verticalCenter
        }
    }

    // Section CENTRE : Titre de la fenêtre active
    CenterSection {
        id: centerSection
        parentWindow: root.parentWindow
        maximumWidth: Math.max(0, Math.min(350,
            rightSection.x - leftSection.x - leftSection.width - Theme.spacingSm * 2))
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(leftSection.x + leftSection.width + Theme.spacingSm,
            Math.min((root.width - width) / 2, rightSection.x - Theme.spacingSm - width))
    }

    // Section DROITE : Taskbar + SystemTray + Backlight + Audio + Batterie + Notifications + Horloge + Power
    RightSection {
        id: rightSection
        parentWindow: root.parentWindow
        // Pas de plafond fixe : la taskbar prend tout l'espace libre (80 px gardés pour le titre),
        // puis défile au-delà.
        taskbarMaximumWidth: Math.max(26,
            root.width - leftSection.width - fixedWidth - 80 - Theme.spacingSm * 4)
        anchors {
            right: parent.right
            rightMargin: Theme.spacingSm
            verticalCenter: parent.verticalCenter
        }
    }
}
