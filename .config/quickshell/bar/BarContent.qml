import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"
import "./modules"

Item {
    id: root
    anchors.fill: parent

    property var parentWindow: null

    GlassCard {
        anchors.fill: parent
        customColor: Theme.background
        customBorderColor: Theme.glassBorder
        customRadius: Theme.radiusMedium

        // Section GAUCHE : Lanceur + Workspaces + CPU + RAM + Network + Lecteur MPRIS
        RowLayout {
            anchors {
                left: parent.left
                leftMargin: Theme.spacingSm
                verticalCenter: parent.verticalCenter
            }
            spacing: Theme.spacingSm

            LauncherButton {}
            Workspaces {}
            CpuModule { parentWindow: root.parentWindow }
            MemoryModule { parentWindow: root.parentWindow }
            NetworkModule { parentWindow: root.parentWindow }
            MprisModule { parentWindow: root.parentWindow }
        }

        // Section CENTRE : Titre de la fenêtre active
        Item {
            anchors.centerIn: parent
            implicitWidth: activeWin.implicitWidth
            implicitHeight: activeWin.implicitHeight

            ActiveWindow {
                id: activeWin
                anchors.centerIn: parent
            }
        }

        // Section DROITE : Taskbar + SystemTray + Backlight + Audio + Batterie + Notifications + Horloge + Power
        RowLayout {
            anchors {
                right: parent.right
                rightMargin: Theme.spacingSm
                verticalCenter: parent.verticalCenter
            }
            spacing: Theme.spacingSm

            TaskbarModule { parentWindow: root.parentWindow }
            SystemTrayModule {}
            BacklightModule { parentWindow: root.parentWindow }
            VolumeModule { parentWindow: root.parentWindow }
            BatteryModule { parentWindow: root.parentWindow }
            NotificationButton {}
            ClockModule { parentWindow: root.parentWindow }
            PowerButton { parentWindow: root.parentWindow }
        }
    }
}
