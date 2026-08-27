import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"
import "../../components"

ModulePopup {
    id: root

    property string fullTime: "00:00:00"
    property string fullDate: ""
    property string uptimeStr: ""

    readonly property date now: new Date()
    readonly property int currentYear: now.getFullYear()
    readonly property int currentMonth: now.getMonth()
    readonly property int currentDay: now.getDate()

    cardWidth: 220
    cardHeight: clockCol.implicitHeight + Theme.spacingMd * 2

    readonly property var monthNames: [
        "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
        "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    ]
    readonly property var dayNames: [
        "Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"
    ]

    function updateDateTime() {
        var d = new Date();
        var h = String(d.getHours()).padStart(2, "0");
        var m = String(d.getMinutes()).padStart(2, "0");
        var s = String(d.getSeconds()).padStart(2, "0");
        root.fullTime = h + ":" + m + ":" + s;

        var dayName = root.dayNames[d.getDay()];
        var monthName = root.monthNames[d.getMonth()];
        root.fullDate = dayName + " " + d.getDate() + " " + monthName;
    }

    readonly property var calendarModel: {
        var firstDayOfWeek = new Date(currentYear, currentMonth, 1).getDay();
        var offset = (firstDayOfWeek + 6) % 7;
        var daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate();

        var cells = [];
        for (var i = 0; i < offset; i++) {
            cells.push({ day: 0, isToday: false });
        }
        for (var d = 1; d <= daysInMonth; d++) {
            cells.push({
                day: d,
                isToday: (d === root.currentDay)
            });
        }
        return cells;
    }

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        watchChanges: false
    }

    Timer {
        interval: 1000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.updateDateTime();
            uptimeFile.reload();
            var txt = typeof uptimeFile.text === "function" ? uptimeFile.text() : (uptimeFile.text || "");
            if (txt) {
                var secs = parseFloat(txt.split(" ")[0]) || 0;
                var hrs = Math.floor(secs / 3600);
                var mins = Math.floor((secs % 3600) / 60);
                root.uptimeStr = hrs + "h" + (mins > 0 ? (mins + "m") : "");
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            root.updateDateTime();
        }
    }

    ColumnLayout {
        id: clockCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        spacing: Theme.spacingXs

        // Heure & Date
        RowLayout {
            Layout.fillWidth: true

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                color: Theme.accent
                text: root.fullTime
            }

            Item { Layout.fillWidth: true }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.textSecondary
                text: root.fullDate
            }
        }

        // Séparateur fin
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.glassBorder
        }

        // Mois et Année
        Text {
            Layout.alignment: Qt.AlignHCenter
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.bold: true
            color: Theme.textPrimary
            text: root.monthNames[root.currentMonth] + " " + root.currentYear
        }

        // Jours de la semaine
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: ["Lu", "Ma", "Me", "Je", "Ve", "Sa", "Di"]
                delegate: Item {
                    Layout.fillWidth: true
                    height: 16
                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                        color: Theme.accentSecondary
                        text: modelData
                    }
                }
            }
        }

        // Grille des jours du mois
        GridLayout {
            Layout.fillWidth: true
            columns: 7
            rowSpacing: 2
            columnSpacing: 0

            Repeater {
                model: root.calendarModel

                delegate: Item {
                    Layout.fillWidth: true
                    height: 20

                    Rectangle {
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        radius: 9
                        color: modelData.isToday ? Theme.accent : "transparent"

                        Text {
                            anchors.centerIn: parent
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: modelData.isToday
                            color: modelData.isToday ? Theme.background : (modelData.day > 0 ? Theme.textPrimary : "transparent")
                            text: modelData.day > 0 ? modelData.day : ""
                        }
                    }
                }
            }
        }

        // Uptime en bas
        RowLayout {
            visible: root.uptimeStr !== ""
            Layout.fillWidth: true
            Layout.topMargin: 2

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: 10
                color: Theme.textDisabled
                text: "󱘖 Uptime " + root.uptimeStr
            }
        }
    }
}
