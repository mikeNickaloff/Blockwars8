import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../stores" 1.0
import "../actions" 1.0

Item {
    id: dashboard
    property int gridId: 0
    property string role: "cpu"
    property var powerupEntries: []
    property bool readyNotified: false
    property bool powerDataNotified: false
    property bool seedAcknowledged: false
    property int poolSeed: -1
    property bool switchingEnabled: false
    property bool fillingEnabled: false
    property bool launchOnMatchEnabled: false
    property var lastBeginTurnPayload: ({})
    property var lastTurnEndedPayload: ({})
    property var lastBeginFillPayload: ({})
    property var lastActivatedPowerup: null
    property bool topOrientation: gridId === 0
    property var runtimeSlots: ({})
    property var dragPermissions: ({})

    signal readyStateMod(int gridId, bool ready, string role)
    signal dashboardCommand(int gridId, string command, var payload)

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
            if (powerDataNotified) {
                powerDataNotified = false
            }
            if (seedAcknowledged) {
                seedAcknowledged = false
            }
            poolSeed = -1
            powerupEntries = []
            role = gridId === 0 ? "cpu" : "player"
            return
        }
        var entry = data[key]
        role = entry.role !== undefined ? entry.role : (gridId === 0 ? "cpu" : "player")
        powerupEntries = entry.powerups ? entry.powerups : []
        if (!powerDataNotified && powerupEntries.length > 0) {
            powerDataNotified = true
            Qt.callLater(function() {
                dashboardCommand(gridId, "PowerDataLoaded", JSON.parse(JSON.stringify(powerupEntries)))
            })
        }
        if (entry.seed !== undefined && entry.seed !== null) {
            setSeed(entry.seed)
        }
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

    function setSeed(seedValue) {
        var numericSeed = parseInt(seedValue, 10)
        if (isNaN(numericSeed)) {
            return
        }
        var seedChanged = poolSeed !== numericSeed
        poolSeed = numericSeed
        if (seedChanged || !seedAcknowledged) {
            seedAcknowledged = true
            Qt.callLater(function() {
                dashboardCommand(gridId, "indexSet", { "seed": poolSeed })
            })
        }
    }

    function setSwitchingEnabled(value) {
        switchingEnabled = value === true
    }

    function setFillingEnabled(value) {
        fillingEnabled = value === true
    }

    function beginFilling(payload) {
        lastBeginFillPayload = payload || ({})
    }

    function turnEnded(payload) {
        lastTurnEndedPayload = payload || ({})
        switchingEnabled = false
    }

    function beginTurn(payload) {
        lastBeginTurnPayload = payload || ({})
    }

    function setLaunchOnMatchEnabled(value) {
        launchOnMatchEnabled = value === true
    }

    function activatePowerup(payload) {
        lastActivatedPowerup = payload || null
    }

    function runtimeSlot(slotIndex) {
        var key = String(slotIndex)
        if (runtimeSlots && runtimeSlots.hasOwnProperty(key)) {
            return runtimeSlots[key]
        }
        return null
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
                delegate: Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(dashboard.height * 0.18, 60)

                    property var entryData: dashboard.extractEntry(index)
                    property var runtimeState: dashboard.runtimeSlot(index)
                    property int slotId: runtimeState && runtimeState.slot !== undefined ? runtimeState.slot : index
                    property color entryColor: runtimeState && runtimeState.color ? colorForName(runtimeState.color) : (entryData && entryData.color ? colorForName(entryData.color) : "#55556a")
                    property bool slotReady: runtimeState ? runtimeState.ready === true : false
                    property bool slotDeployed: runtimeState ? runtimeState.deployed === true : false
                    property bool slotDragAllowed: runtimeState && dashboard.dragPermissions && dashboard.dragPermissions[String(index)] === true
                    property real energyValue: runtimeState && runtimeState.energy !== undefined ? runtimeState.energy : 0
                    property real maxEnergy: runtimeState && runtimeState.maxEnergy !== undefined ? runtimeState.maxEnergy : (entryData && entryData.energy ? entryData.energy : 0)
                    property real energyFraction: maxEnergy > 0 ? Math.max(0, Math.min(1, energyValue / maxEnergy)) : 0
                    property bool flashOn: false

                    onSlotDragAllowedChanged: {
                        if (!slotDragAllowed && dragProxy) {
                            dragProxy.visible = false
                            dragProxy.Drag.active = false
                        }
                    }

                    onSlotDeployedChanged: {
                        if (slotDeployed && dragProxy) {
                            dragProxy.visible = false
                            dragProxy.Drag.active = false
                        }
                    }

                    Timer {
                        id: flashTimer
                        interval: 600
                        running: slotReady && slotDragAllowed && !slotDeployed
                        repeat: true
                        onTriggered: flashOn = !flashOn
                    }

                    Rectangle {
                        id: card
                        anchors.fill: parent
                        radius: 12
                        border.width: 1
                        border.color: slotReady && slotDragAllowed && !slotDeployed ? (flashOn ? Qt.lighter(entryColor, 1.8) : Qt.darker(entryColor, 1.2)) : Qt.darker(entryColor, 1.5)
                        color: slotDeployed ? "#2a2a38" : Qt.darker(entryColor, 1.8)
                        opacity: slotDeployed ? 0.45 : 1.0

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 4

                            Label {
                                text: runtimeState && runtimeState.displayName ? runtimeState.displayName : (entryData ? (entryData.displayName || "Powerup") : "Empty Slot")
                                font.pixelSize: Math.round(dashboard.height * 0.05)
                                font.bold: entryData !== null
                                color: "#f4f4f7"
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 8
                                radius: 4
                                color: "#2c2c3d"
                                border.width: 1
                                border.color: Qt.darker(entryColor, 1.4)
                                visible: entryData !== null
                                Rectangle {
                                    width: parent.width * energyFraction
                                    height: parent.height
                                    radius: parent.radius
                                    color: entryColor
                                }
                            }
                        }

                        MouseArea {
                            id: dragArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: slotDragAllowed && !slotDeployed && dashboard.gridId === 1
                            drag.target: dragProxy
                            onPressed: {
                                if (!enabled)
                                    return
                                dragProxy.visible = true
                                dragProxy.x = card.mapToItem(dashboard, 0, 0).x
                                dragProxy.y = card.mapToItem(dashboard, 0, 0).y
                                card.opacity = 0.6
                            }
                            onReleased: {
                                if (!enabled) {
                                    dragProxy.visible = false
                                    card.opacity = slotDeployed ? 0.45 : 1.0
                                    return
                                }
                                var target = dragProxy.Drag.target
                                dragProxy.Drag.active = false
                                dragProxy.visible = false
                                dragProxy.anchors.fill = card
                                card.opacity = slotDeployed ? 0.45 : 1.0
                                if (target) {
                                    AppActions.requestPowerupDeployment({
                                                                           "grid_id": dashboard.gridId,
                                                                           "slot_id": slotId,
                                                                           "row": target.row,
                                                                           "column": target.column,
                                                                           "color": runtimeState ? runtimeState.color : (entryData ? entryData.color : ""),
                                                                           "displayName": runtimeState && runtimeState.displayName ? runtimeState.displayName : (entryData ? entryData.displayName : "Powerup"),
                                                                           "maxHealth": runtimeState && runtimeState.maxEnergy !== undefined ? runtimeState.maxEnergy : 0,
                                                                           "amount": runtimeState && runtimeState.amount !== undefined ? runtimeState.amount : 0,
                                                                           "powerupType": runtimeState && runtimeState.type ? runtimeState.type : (entryData ? entryData.type : "blocks"),
                                                                           "powerupTarget": runtimeState && runtimeState.target ? runtimeState.target : (entryData ? entryData.target : "opponent"),
                                                                           "gridTargets": runtimeState && runtimeState.gridTargets ? runtimeState.gridTargets : (entryData && entryData.grid_targets ? entryData.grid_targets : [])
                                                                       })
                                }
                            }
                        }

                        Rectangle {
                            id: dragProxy
                            anchors.fill: card
                            radius: card.radius
                            color: Qt.rgba(entryColor.r, entryColor.g, entryColor.b, 0.6)
                            visible: false
                            z: 10
                            Drag.active: dragArea.drag.active && dragArea.enabled
                            Drag.hotSpot.x: width / 2
                            Drag.hotSpot.y: height / 2
                            Drag.keys: [dashboard.gridId]
                            states: [
                                State {
                                    when: dragProxy.Drag.active
                                    ParentChange { target: dragProxy; parent: dashboard }
                                    AnchorChanges { target: dragProxy;  }
                                }
                            ]
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
