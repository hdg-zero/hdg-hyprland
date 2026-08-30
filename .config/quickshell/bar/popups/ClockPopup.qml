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
    property string uptimeStr: "N/A"

    readonly property date now: new Date()
    readonly property int currentYear: now.getFullYear()
    readonly property int currentMonth: now.getMonth()
    readonly property int currentDay: now.getDate()

    cardWidth: Theme.relWidth(0.15, parentWindow ? parentWindow.screen : null)
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
        root.fullDate = dayName + " " + d.getDate() + " " + monthName + " " + d.getFullYear();
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
            if (root.visible) {
                uptimeFile.reload();
                var txt = typeof uptimeFile.text === "function" ? uptimeFile.text() : (uptimeFile.text || "");
                if (txt) {
                    var secs = parseFloat(txt.split(" ")[0]) || 0;
                    var hrs = Math.floor(secs / 3600);
                    var mins = Math.floor((secs % 3600) / 60);
                    root.uptimeStr = hrs + "h " + (mins > 0 ? (mins + "m") : "");
                }
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
        spacing: Theme.spacingSm

        // En-tête : Heure grand format & Date
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 2

            Text {
                Layout.alignment: Qt.AlignHCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeTitle + 4
                font.bold: true
                color: Theme.accent
                text: root.fullTime
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                text: root.fullDate
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

        // En-tête mois calendrier
        Text {
            Layout.alignment: Qt.AlignHCenter
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMedium
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
                    height: Theme.spacingLg * 1.2
                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeTiny
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
            rowSpacing: Theme.spacingXs
            columnSpacing: 0

            Repeater {
                model: root.calendarModel

                delegate: Item {
                    Layout.fillWidth: true
                    height: Theme.spacingLg * 1.4

                    Rectangle {
                        anchors.centerIn: parent
                        width: Theme.spacingLg * 1.3
                        height: Theme.spacingLg * 1.3
                        radius: width / 2
                        color: modelData.isToday ? Theme.accent : "transparent"

                        Text {
                            anchors.centerIn: parent
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeTiny
                            font.bold: modelData.isToday
                            color: modelData.isToday ? Theme.background : (modelData.day > 0 ? Theme.textPrimary : "transparent")
                            text: modelData.day > 0 ? modelData.day : ""
                        }
                    }
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

        // Uptime système
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                text: "󱘖 Uptime :"
            }

            Item { Layout.fillWidth: true }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textPrimary
                text: root.uptimeStr
            }
        }
    }
}
