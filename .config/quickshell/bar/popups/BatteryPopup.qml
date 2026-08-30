import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    readonly property var bat: UPower.displayDevice
    readonly property int chargePercent: {
        if (!bat) return 100;
        var p = bat.percentage;
        return p <= 1.0 ? Math.round(p * 100) : Math.round(p);
    }
    readonly property bool isCharging: bat ? (bat.state === UPowerDeviceState.Charging) : false
    readonly property bool isFull: bat ? (bat.state === UPowerDeviceState.FullyCharged) : false
    // Doc Quickshell.Services.UPower/UPowerDevice v0.3.x : le débit énergétique s'appelle
    // « changeRate » (watts, positif en charge, négatif en décharge) ; « energyRate » n'existe pas.
    // Seuil de 0,05 W pour éviter l'affichage d'un chiffre tremblant au repos.
    readonly property real changeRateW: (bat && bat.changeRate) ? bat.changeRate : 0
    readonly property string changeRateFormatted: Math.abs(changeRateW) > 0.05
        ? ((changeRateW > 0 ? "+" : "") + changeRateW.toFixed(1) + " W")
        : ""

    readonly property string timeRemainingFormatted: {
        if (!bat) return "";
        var secs = isCharging ? bat.timeToFull : bat.timeToEmpty;
        if (!secs || secs <= 0) return isFull ? "Pleine" : (isCharging ? "En charge" : "");
        var hrs = Math.floor(secs / 3600);
        var mins = Math.floor((secs % 3600) / 60);
        if (hrs > 0) return hrs + "h" + (mins > 0 ? (mins + "m") : "");
        return mins + "m";
    }

    widthPercent: Theme.popupWidthPercentCompact
    cardHeight: batCol.implicitHeight + Theme.spacingMd * 2

    function setProfile(profile) {
        Quickshell.execDetached(["powerprofilesctl", "set", profile]);
    }

    ColumnLayout {
        id: batCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        spacing: Theme.spacingSm

        // En-tête
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeHeader
                color: root.isCharging ? Theme.success : (root.chargePercent <= 20 ? Theme.destructive : Theme.accent)
                text: root.isCharging ? "󰂄" : (root.chargePercent >= 90 ? "󰁹" : (root.chargePercent >= 50 ? "󰁿" : (root.chargePercent >= 20 ? "󰁼" : "󰁺")))
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.textPrimary
                text: "Batterie"
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeHeader
                font.bold: true
                color: root.isCharging ? Theme.success : (root.chargePercent <= 20 ? Theme.destructive : Theme.accent)
                text: root.chargePercent + "%"
            }
        }

        // Barre de charge (plus épaisse)
        Rectangle {
            Layout.fillWidth: true
            height: Theme.progressBarHeight
            radius: Theme.progressBarHeight / 2
            color: Qt.rgba(1, 1, 1, 0.1)

            Rectangle {
                width: parent.width * (Math.min(100, Math.max(0, root.chargePercent)) / 100.0)
                height: parent.height
                radius: Theme.progressBarHeight / 2
                color: root.isCharging ? Theme.success : (root.chargePercent <= 20 ? Theme.destructive : Theme.accent)

                Behavior on width {
                    NumberAnimation { duration: Theme.animDurationNormal; easing.type: Theme.easingType }
                }
            }
        }

        // Temps restant & Puissance
        RowLayout {
            visible: root.timeRemainingFormatted !== "" || root.changeRateFormatted !== ""
            Layout.fillWidth: true

            Text {
                visible: root.timeRemainingFormatted !== ""
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                text: " " + root.timeRemainingFormatted
            }

            Item { Layout.fillWidth: true }

            Text {
                visible: root.changeRateFormatted !== ""
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textDisabled
                text: root.changeRateFormatted
            }
        }

        // Profils d'énergie compacts
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            Repeater {
                model: [
                    { id: "power-saver", label: "Éco" },
                    { id: "balanced", label: "Équilibré" },
                    { id: "performance", label: "Max" }
                ]

                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: Theme.spacingLg * 1.4
                    radius: Theme.radiusSmall
                    color: profMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
                    border.color: Theme.glassBorder
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
                        font.bold: true
                        color: Theme.textPrimary
                        text: modelData.label
                    }

                    MouseArea {
                        id: profMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.setProfile(modelData.id)
                    }
                }
            }
        }
    }
}
