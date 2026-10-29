import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Alerte de batterie faible (20 %) puis critique (10 %), une seule fois par seuil et par
// décharge. Instanciée une seule fois dans shell.qml (et non par écran comme la barre).
QtObject {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool present: device !== null && device !== undefined && device.isPresent
    readonly property int percentage: {
        if (!device) return 100;
        var p = device.percentage;
        return p <= 1.0 ? Math.round(p * 100) : Math.round(p);
    }
    readonly property bool discharging: present && device.state === UPowerDeviceState.Discharging

    // Dernier seuil notifié (100 = aucun) ; remis à zéro dès que la batterie ne se décharge plus.
    property int notifiedLevel: 100

    function check() {
        if (!discharging) {
            notifiedLevel = 100;
            return;
        }
        if (percentage <= 10 && notifiedLevel > 10) {
            notifiedLevel = 10;
            notify("critical", "Batterie critique", "Batterie à " + percentage + " %. Branche le chargeur.");
        } else if (percentage <= 20 && notifiedLevel > 20) {
            notifiedLevel = 20;
            notify("normal", "Batterie faible", "Batterie à " + percentage + " %. Charge recommandée.");
        }
    }

    function notify(urgency, title, body) {
        Quickshell.execDetached(["notify-send", "-u", urgency, "-a", "Batterie", title, body]);
    }

    onPercentageChanged: check()
    onDischargingChanged: check()
    Component.onCompleted: check()
}
