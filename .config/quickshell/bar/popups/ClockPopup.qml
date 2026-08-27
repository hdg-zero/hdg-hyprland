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
    readonly property int currentMonth: now.getMonth() // 0-indexed
    readonly property int currentDay: now.getDate()

    cardWidth: 300
    cardHeight: clockCol.implicitHeight + Theme.spacingMd * 2

    // Mois en français
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

    // Calcul de la grille du calendrier
    readonly property var calendarModel: {
        var firstDayOfWeek = new Date(currentYear, currentMonth, 1).getDay(); // 0 = Dimanche
        // Décalage pour commencer le Lundi (0 = Lundi, 6 = Dimanche)
        var offset = (firstDayOfWeek + 6) % 7;
        var daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate();

        var cells = [];
        // Cases vides avant le 1er du mois
        for (var i = 0; i < offset; i++) {
            cells.push({ day: 0, isCurrentMonth: false, isToday: false });
        }
        // Jours du mois
        for (var d = 1; d <= daysInMonth; d++) {
            cells.push({
                day: d,
                isCurrentMonth: true,
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
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.updateDateTime();
            if (root.visible) {
                uptimeFile.reload();
                var txt = uptimeFile.text();
                if (txt) {
                    var secs = parseFloat(txt.split(" ")[0]) || 0;
                    var hrs = Math.floor(secs / 3600);
                    var mins = Math.floor((secs % 3600) / 60);
                    root.uptimeStr = hrs + "h " + mins + "m";
                }
            }
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
                font.pixelSize: 26
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
                    height: 20
                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
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
            rowSpacing: 4
            columnSpacing: 0

            Repeater {
                model: root.calendarModel

                delegate: Item {
                    Layout.fillWidth: true
                    height: 24

                    Rectangle {
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        radius: 12
                        color: modelData.isToday ? Theme.accent : "transparent"

                        Text {
                            anchors.centerIn: parent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
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
                font.pixelSize: 11
                color: Theme.textSecondary
                text: "󱘖 Uptime :"
            }

            Item { Layout.fillWidth: true }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                color: Theme.textPrimary
                text: root.uptimeStr
            }
        }
    }
}
