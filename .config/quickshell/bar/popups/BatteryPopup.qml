import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Hyprland
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    readonly property var bat: UPower.displayDevice
    readonly property int chargePercent: bat ? Math.round(bat.percentage * 100) : 100
    readonly property bool isCharging: bat ? (bat.state === UPowerDeviceState.Charging) : false
    readonly property bool isFull: bat ? (bat.state === UPowerDeviceState.FullyCharged) : false
    readonly property string energyRateFormatted: bat && bat.energyRate > 0 ? (bat.energyRate.toFixed(1) + " W") : "N/A"

    readonly property string timeRemainingFormatted: {
        if (!bat) return "N/A";
        var secs = isCharging ? bat.timeToFull : bat.timeToEmpty;
        if (!secs || secs <= 0) return isFull ? "Pleine charge" : "Calcul en cours...";
        var hrs = Math.floor(secs / 3600);
        var mins = Math.floor((secs % 3600) / 60);
        if (hrs > 0) return hrs + " h " + mins + " min";
        return mins + " min";
    }

    cardWidth: 280
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
            spacing: Theme.spacingSm

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                color: root.isCharging ? Theme.success : (root.chargePercent <= 20 ? Theme.destructive : Theme.accent)
                text: root.isCharging ? "󰂄" : (root.chargePercent >= 90 ? "󰁹" : (root.chargePercent >= 50 ? "󰁿" : (root.chargePercent >= 20 ? "󰁼" : "󰁺")))
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                    color: Theme.textPrimary
                    text: "Batterie"
                }

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: root.isCharging ? Theme.success : Theme.textSecondary
                    text: root.isFull ? "Pleine charge" : (root.isCharging ? "En charge sur secteur" : "Sur batterie")
                }
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                color: root.isCharging ? Theme.success : (root.chargePercent <= 20 ? Theme.destructive : Theme.accent)
                text: root.chargePercent + "%"
            }
        }

        // Barre de charge
        Rectangle {
            Layout.fillWidth: true
            height: 6
            radius: 3
            color: Qt.rgba(1, 1, 1, 0.1)

            Rectangle {
                width: parent.width * (Math.min(100, Math.max(0, root.chargePercent)) / 100.0)
                height: parent.height
                radius: 3
                color: root.isCharging ? Theme.success : (root.chargePercent <= 20 ? Theme.destructive : Theme.accent)

                Behavior on width {
                    NumberAnimation { duration: Theme.animDurationNormal; easing.type: Theme.easingType }
                }
            }
        }

        // Métriques (Temps restant + Puissance)
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacingXs

            RowLayout {
                spacing: Theme.spacingXs
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textSecondary
                    text: " Restant :"
                }
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: Theme.textPrimary
                    text: root.timeRemainingFormatted
                }
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: Theme.spacingXs
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textSecondary
                    text: "󱐋 Débit :"
                }
                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: Theme.textPrimary
                    text: root.energyRateFormatted
                }
            }
        }

        // Séparateur
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.glassBorder
            Layout.topMargin: Theme.spacingXs
            Layout.bottomMargin: Theme.spacingXs
        }

        // Profils d'énergie UPower
        Text {
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.bold: true
            color: Theme.textSecondary
            text: "Profil d'Alimentation"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            Repeater {
                model: [
                    { id: "power-saver", label: "Éco", icon: "󰌪" },
                    { id: "balanced", label: "Équilibré", icon: "󰗑" },
                    { id: "performance", label: "Max", icon: "󰓅" }
                ]

                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 28
                    radius: Theme.radiusSmall
                    color: profMouse.containsMouse ? Theme.cardBackgroundHover : Qt.rgba(1, 1, 1, 0.05)
                    border.color: Theme.glassBorder
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacingXs
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.accent
                            text: modelData.icon
                        }
                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            color: Theme.textPrimary
                            text: modelData.label
                        }
                    }

                    MouseArea {
                        id: profMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.setProfile(modelData.id);
                        }
                    }
                }
            }
        }
    }
}
