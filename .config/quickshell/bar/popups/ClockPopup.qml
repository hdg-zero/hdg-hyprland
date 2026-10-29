import QtQuick
import QtQuick.Controls
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

    property date now: new Date()
    readonly property int currentYear: now.getFullYear()
    readonly property int currentMonth: now.getMonth()
    readonly property int currentDay: now.getDate()

    cardWidth: 300
    cardHeight: contentColumn.implicitHeight + PopupStyle.padding * 2

    readonly property var monthNames: [
        "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
        "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    ]
    readonly property var dayNames: [
        "Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"
    ]

    function updateDateTime() {
        var d = new Date();
        root.now = d;
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
        preload: true
        onLoaded: { if (root.isOpen) root.consumeUptime(); }
    }

    function updateUptime() {
        uptimeFile.reload();
    }

    function consumeUptime() {
        var txt = uptimeFile.text();
        if (!txt) return;
        var minutes = Math.floor((parseFloat(txt.split(" ")[0]) || 0) / 60);
        uptimeStr = Math.floor(minutes / 60) + " h " + (minutes % 60);
    }
    Timer { interval: 1000; running: root.isOpen; repeat: true; triggeredOnStart: true; onTriggered: root.updateDateTime() }
    Timer { interval: 60000; running: root.isOpen; repeat: true; triggeredOnStart: true; onTriggered: root.updateUptime() }
    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Theme.spacingSm
        PopupText { text: root.fullTime; font.pixelSize: 26 }
        PopupText { Layout.fillWidth: true; text: root.fullDate; font.pixelSize: 11; color: Theme.textSecondary }
        GridLayout {
            id: calendarGrid
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            readonly property int cellWidth: Math.max(1, Math.floor((contentColumn.width - 6 * columnSpacing) / 7))
            columns: 7
            columnSpacing: 3
            rowSpacing: 3
            Repeater {
                model: ["L", "M", "M", "J", "V", "S", "D"]
                delegate: PopupText {
                    required property string modelData
                    Layout.minimumWidth: calendarGrid.cellWidth
                    Layout.preferredWidth: calendarGrid.cellWidth
                    Layout.maximumWidth: calendarGrid.cellWidth
                    Layout.preferredHeight: 20
                    text: modelData
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 9
                    color: Theme.textSecondary
                }
            }
            Repeater {
                model: root.calendarModel
                delegate: Rectangle {
                    required property var modelData
                    Layout.minimumWidth: calendarGrid.cellWidth
                    Layout.preferredWidth: calendarGrid.cellWidth
                    Layout.maximumWidth: calendarGrid.cellWidth
                    Layout.preferredHeight: 27
                    radius: 8
                    color: modelData.isToday ? PopupStyle.activeSurface : "transparent"
                    border.width: modelData.isToday ? 1 : 0
                    border.color: PopupStyle.accent
                    PopupText { anchors.centerIn: parent; text: parent.modelData.day > 0 ? parent.modelData.day : ""; font.pixelSize: 11 }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            PopupGlyph { text: "󰥔"; font.pixelSize: 13; color: Theme.textSecondary }
            PopupText { Layout.fillWidth: true; text: root.uptimeStr; font.pixelSize: 11; color: Theme.textSecondary }
        }
    }
}
