import QtQuick
import Quickshell.Services.UPower
import "../../theme"
import ".."
import "../components"

Item {
    id: root

    property var parentWindow: null

    readonly property var device: UPower.displayDevice
    readonly property bool hasBattery: device !== null && device !== undefined && device.isPresent
    
    visible: hasBattery
    implicitWidth: visible ? pill.implicitWidth : 0
    implicitHeight: visible ? pill.implicitHeight : 0

    readonly property int rawPercentage: {
        if (!device) return 100;
        var p = device.percentage;
        return p <= 1.0 ? Math.round(p * 100) : Math.round(p);
    }
    readonly property bool isCharging: device ? (device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.PendingCharge) : false
    readonly property bool isCritical: rawPercentage <= 15
    readonly property bool isWarning: rawPercentage <= 30



    BarPillButton {
        id: pill
        parentWindow: root.parentWindow
        description: "Batterie · " + text
        anchors.fill: parent

        icon: {
            if (root.isCharging) return "";
            if (root.rawPercentage >= 95) return "󰁹";
            if (root.rawPercentage >= 80) return "󰂂";
            if (root.rawPercentage >= 70) return "󰂁";
            if (root.rawPercentage >= 60) return "󰂀";
            if (root.rawPercentage >= 50) return "󰁿";
            if (root.rawPercentage >= 40) return "󰁾";
            if (root.rawPercentage >= 30) return "󰁽";
            if (root.rawPercentage >= 20) return "󰁼";
            if (root.rawPercentage >= 10) return "󰁻";
            return "󰂎";
        }

        iconColor: root.isCharging ? BarStyle.success : (root.isCritical ? BarStyle.destructive : (root.isWarning ? BarStyle.warning : BarStyle.accentText))
        text: root.rawPercentage + "%"
        textColor: root.isCritical ? BarStyle.destructive : Theme.textPrimary
        customPaddingH: Theme.spacingSm
        customPaddingV: 1

    }
}
