import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../stores" 1.0

Item {
    id: dashboard
    property int gridId: 0
    property string role: "cpu"
    property var powerupEntries: []
    property bool readyNotified: false
    property bool topOrientation: gridId === 0

    signal readyStateMod(int gridId, bool ready, string role)

    implicitWidth: 220
    implicitHeight: 320

    function extractEntry(index) {
        if (powerupEntries && powerupEntries.length > index) {
            return powerupEntries[index]
        }
        return null
    }

    function refreshFromStore() {
        var data = MainStore.single_player_dashboard_data
        var key = gridId.toString()
        if (!data || !data.hasOwnProperty(key) || data[key] === null) {
            if (readyNotified) {
                readyNotified = false
                readyStateMod(gridId, false, role)
            }
            powerupEntries = []
            role = gridId === 0 ? "cpu" : "player"
            return
        }
        var entry = data[key]
        role = entry.role !== undefined ? entry.role : (gridId === 0 ? "cpu" : "player")
        powerupEntries = entry.powerups ? entry.powerups : []
        if (powerupEntries.length > 0) {
            if (!readyNotified) {
                readyNotified = true
                readyStateMod(gridId, true, role)
            }
        } else if (readyNotified) {
            readyNotified = false
            readyStateMod(gridId, false, role)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 18
            radius: 9
            color: topOrientation ? "#3f6dd8" : "#3f6dd8"
            rotation: topOrientation ? 0 : 180
            border.width: 1
            border.color: "#274a9e"
            ProgressBar {
                anchors.fill: parent
                from: 0
                to: 1
                value: 0.0
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            Repeater {
                model: 4
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(dashboard.height * 0.18, 60)
                    radius: 12
                    border.width: 1
                    border.color: entryData ? Qt.darker(entryColor, 1.3) : "#3a3a48"
                    color: entryData ? Qt.darker(entryColor, 1.8) : "#1f1f2b"

                    property var entryData: dashboard.extractEntry(index)
                    property color entryColor: entryData && entryData.color ? colorForName(entryData.color) : "#55556a"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4

                        Label {
                            text: entryData ? (entryData.displayName || "Powerup") : "Empty Slot"
                            font.pixelSize: Math.round(dashboard.height * 0.05)
                            font.bold: entryData !== null
                            color: "#f4f4f7"
                        }
                        Label {
                            text: entryData ? (entryData.target === "self" ? "Target: Self" : "Target: Enemy") : "Select a powerup"
                            font.pixelSize: Math.round(dashboard.height * 0.033)
                            color: "#d0d1df"
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Label {
                                text: entryData ? ("Amount: " + entryData.amount) : ""
                                font.pixelSize: Math.round(dashboard.height * 0.03)
                                color: "#d0d1df"
                                visible: entryData !== null
                            }
                            Label {
                                text: entryData && entryData.type === "blocks" ? ("Cells: " + countSelected(entryData)) : ""
                                font.pixelSize: Math.round(dashboard.height * 0.03)
                                color: "#d0d1df"
                                visible: entryData !== null && entryData.type === "blocks"
                            }
                        }
                    }
                }
            }
        }
    }

    function countSelected(entry) {
        if (!entry || !entry.grid_targets) {
            return 0
        }
        var sum = 0
        for (var i = 0; i < entry.grid_targets.length; ++i) {
            var cell = entry.grid_targets[i]
            if (cell && (cell.selected === true || cell === true)) {
                sum += 1
            }
        }
        return sum
    }

    function colorForName(name) {
        var key = (name || "").toString().toLowerCase()
        switch (key) {
        case "red":
            return "#d9534f"
        case "green":
            return "#5cb85c"
        case "blue":
            return "#5bc0de"
        case "yellow":
            return "#f0ad4e"
        default:
            return "#888896"
        }
    }

    Component.onCompleted: refreshFromStore()

    Connections {
        target: MainStore
        function onSingle_player_dashboard_dataChanged() {
            refreshFromStore()
        }
    }
}
