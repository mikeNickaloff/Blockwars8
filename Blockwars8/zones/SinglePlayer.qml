import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQml.Models 2.15
import QtMultimedia 5.5
import QtQuick.Controls 2.0
import QtQuick.LocalStorage 2.15
import QuickFlux 1.1
import com.blockwars 1.0
import "../models"
import "../constants" 1.0
import "../actions" 1.0
import "../stores" 1.0
import "../elements" 1.0
import "../controllers" 1.0

Item {
    id: singlePlayerRoot
    width: parent ? parent.width : 480
    height: parent ? parent.height : 640

    readonly property bool powerupDataLoaded: loaderCompleted
    property bool loaderCompleted: false
    property bool gameActivated: false

    PowerupEditor {
        id: hiddenLoader
        visible: false
        onPowerupsLoaded: {
            AppActions.resetSinglePlayerPowerupSelection({ "grid_id": 1, "context": "single_player" })
            loaderCompleted = true
            hiddenLoader.closeDialog()
            hiddenLoader.destroy()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#0f101b"
        opacity: powerupDataLoaded ? 0.0 : 1.0
        visible: !powerupDataLoaded
    }

    StackView {
        id: flowStack
        anchors.fill: parent
        visible: powerupDataLoaded
        initialItem: powerupSelectionComponent
    }

    Component {
        id: powerupSelectionComponent

        Item {
            id: selectionRoot
            width: flowStack.width
            height: flowStack.height

            property var slotSelections: []
            property var cachedPlayerList: []
            property var cachedDefaultList: []
            property int pickerSlot: -1
            property var pickerEntries: []

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#1b1b27" }
                    GradientStop { position: 1.0; color: "#11111b" }
                }
            }

            function colorForName(name) {
                var key = (name || "").toString().toLowerCase()
                switch (key) {
                case "red": return "#d9534f"
                case "green": return "#5cb85c"
                case "blue": return "#5bc0de"
                case "yellow": return "#f0ad4e"
                default: return "#8a8aa0"
                }
            }

            function countSelectedCells(powerup) {
                if (!powerup || !powerup.grid_targets) {
                    return 0
                }
                var total = 0
                for (var i = 0; i < powerup.grid_targets.length; ++i) {
                    var cell = powerup.grid_targets[i]
                    if (cell && (cell.selected === true || cell === true)) {
                        total += 1
                    }
                }
                return total
            }

            function refreshLists() {
                cachedPlayerList = MainStore.getPlayerPowerupsAsList() || []
                cachedDefaultList = MainStore.getDefaultPowerupsAsList() || []
            }

            function refreshSelections() {
                var selections = MainStore.getSinglePlayerSelections() || {}
                var updated = []
                for (var i = 0; i < 4; ++i) {
                    var key = i.toString()
                    updated.push({
                                     "slot": i,
                                     "powerup": selections.hasOwnProperty(key) ? selections[key] : null
                                 })
                }
                slotSelections = updated
            }

            function allSlotsChosen() {
                for (var i = 0; i < slotSelections.length; ++i) {
                    if (!slotSelections[i].powerup) {
                        return false
                    }
                }
                return true
            }

            function openPicker(slot) {
                pickerSlot = slot
                refreshLists()
                buildPickerEntries()
                powerupPicker.open()
            }

            function buildPickerEntries() {
                var entries = []
                if (cachedPlayerList.length > 0) {
                    entries.push({ "entryType": "header", "title": "My Powerups" })
                    for (var i = 0; i < cachedPlayerList.length; ++i) {
                        entries.push({ "entryType": "powerup", "source": "player", "powerup": cachedPlayerList[i] })
                    }
                }
                if (cachedDefaultList.length > 0) {
                    if (entries.length > 0) {
                        entries.push({ "entryType": "divider" })
                    }
                    entries.push({ "entryType": "header", "title": "Default Powerups" })
                    for (var j = 0; j < cachedDefaultList.length; ++j) {
                        entries.push({ "entryType": "powerup", "source": "default", "powerup": cachedDefaultList[j] })
                    }
                }
                pickerEntries = entries
            }

            function setSlot(slot, entry) {
                AppActions.setSinglePlayerPowerupSelection({
                                                              "slot": slot,
                                                              "grid_id": 1,
                                                              "powerup": entry ? entry.powerup : null,
                                                              "source": entry ? entry.source : "player"
                                                          })
            }

            ScrollView {
                id: cardsScroll
                anchors.fill: parent
                anchors.margins: selectionRoot.width * 0.06
                clip: true

                ColumnLayout {
                    width: cardsScroll.width
                    spacing: selectionRoot.height * 0.03

                    Label {
                        text: "Select Your Powerups"
                        font.pixelSize: Math.round(selectionRoot.height * 0.06)
                        font.bold: true
                        color: "#f5f5fa"
                    }

                    Label {
                        text: "Choose four powerups to bring into battle."
                        font.pixelSize: Math.round(selectionRoot.height * 0.03)
                        color: "#c2c3d8"
                    }

                    Repeater {
                        model: slotSelections
                        delegate: Rectangle {
                            property var slotData: modelData
                            property int slotIndex: slotData && slotData.slot !== undefined ? slotData.slot : index
                            property var powerupEntry: slotData ? slotData.powerup : null

                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.min(selectionRoot.height * 0.16, 140)
                            radius: 14
                            border.width: powerupEntry ? 2 : 1
                            border.color: powerupEntry ? colorForName(powerupEntry.color) : "#40404f"
                            color: powerupEntry ? Qt.darker(colorForName(powerupEntry.color), 1.7) : "#191926"

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 6

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 12

                                        Rectangle {
                                            width: 48
                                            height: 48
                                            radius: 10
                                            color: powerupEntry ? colorForName(powerupEntry.color) : "#4e4e64"
                                            border.width: 1
                                            border.color: powerupEntry ? Qt.darker(colorForName(powerupEntry.color), 1.3) : "#5f6075"
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2

                                            Label {
                                                text: powerupEntry ? (powerupEntry.displayName || ((powerupEntry.source === "default" ? "Default" : "Custom") + " Powerup")) : "Select Powerup..."
                                                font.pixelSize: Math.round(selectionRoot.height * 0.03)
                                                font.bold: true
                                                color: "#f4f4f9"
                                            }
                                            Label {
                                                text: powerupEntry ? (powerupEntry.type === "heros" ? "Target: Heroes" : powerupEntry.type === "health" ? "Target: Health" : (powerupEntry.target === "self" ? "Target: Self Grid" : "Target: Enemy Grid")) : "Slot " + (slotIndex + 1)
                                                font.pixelSize: Math.round(selectionRoot.height * 0.023)
                                                color: "#d4d4e8"
                                            }
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 14

                                        Label {
                                        text: powerupEntry ? ("Amount: " + powerupEntry.amount) : ""
                                        font.pixelSize: Math.round(selectionRoot.height * 0.022)
                                        color: "#d4d4e8"
                                        visible: powerupEntry !== null
                                    }

                                        Label {
                                        text: powerupEntry && powerupEntry.type === "blocks" ? ("Cells: " + countSelectedCells(powerupEntry)) : ""
                                        font.pixelSize: Math.round(selectionRoot.height * 0.022)
                                        color: "#d4d4e8"
                                        visible: powerupEntry !== null && powerupEntry.type === "blocks"
                                    }

                                        Label {
                                        text: powerupEntry ? (powerupEntry.source === "default" ? "Default" : "Custom") : ""
                                        font.pixelSize: Math.round(selectionRoot.height * 0.022)
                                        color: "#a4a4bd"
                                        visible: powerupEntry !== null
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 10

                                    Button {
                                        text: powerupEntry ? "Change" : "Select"
                                        Layout.preferredWidth: 160
                                        onClicked: openPicker(slotIndex)
                                    }

                                    Button {
                                        text: "Clear"
                                        visible: powerupEntry !== null
                                        onClicked: setSlot(slotIndex, null)
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(selectionRoot.height * 0.1, 80)
                        radius: 12
                        border.width: 1
                        border.color: "#46465c"
                        color: "#1b1b28"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 4

                            Label {
                                text: allSlotsChosen() ? "Powerups Selected" : "Waiting for Selections"
                                font.pixelSize: Math.round(selectionRoot.height * 0.028)
                                font.bold: true
                                color: "#f9f9ff"
                            }
                            Label {
                                text: allSlotsChosen() ? "Press Ready to begin" : "Choose four powerups to continue"
                                font.pixelSize: Math.round(selectionRoot.height * 0.022)
                                color: "#c2c2d5"
                            }
                        }
                    }

                    Button {
                        text: "Ready!"
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(selectionRoot.height * 0.075, 64)
                        enabled: allSlotsChosen()
                        font.pixelSize: Math.round(selectionRoot.height * 0.032)
                        onClicked: AppActions.confirmSinglePlayerPowerupSelection({ "grid_id": 1, "context": "single_player" })
                    }
                }
            }

            Popup {
                id: powerupPicker
                x: selectionRoot.width * 0.1
                y: selectionRoot.height * 0.12
                width: selectionRoot.width * 0.8
                height: Math.min(selectionRoot.height * 0.7, selectionRoot.height - selectionRoot.height * 0.2)
                modal: true
                focus: true

                background: Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: "#1c1c28"
                    border.width: 1
                    border.color: "#3e3e50"
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    Label {
                        text: "Choose a Powerup"
                        font.pixelSize: Math.round(selectionRoot.height * 0.035)
                        font.bold: true
                        color: "#f4f4f7"
                    }

                    ListView {
                        id: pickerView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 6
                        model: pickerEntries

                        delegate: Item {
                            width: pickerView.width
                            height: modelData.entryType === "powerup" ? selectionRoot.height * 0.12 : (modelData.entryType === "divider" ? 20 : selectionRoot.height * 0.06)

                            Rectangle {
                                anchors.fill: parent
                                radius: modelData.entryType === "powerup" ? 10 : 0
                                visible: modelData.entryType === "powerup"
                                color: "#202030"
                                border.width: 1
                                border.color: "#35354b"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: 8
                                        color: modelData.entryType === "powerup" ? selectionRoot.colorForName(modelData.powerup.color) : "transparent"
                                        border.width: modelData.entryType === "powerup" ? 1 : 0
                                        border.color: modelData.entryType === "powerup" ? Qt.darker(selectionRoot.colorForName(modelData.powerup.color), 1.3) : "transparent"
                                        visible: modelData.entryType === "powerup"
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Label {
                                            text: modelData.entryType === "powerup" ? (modelData.powerup.displayName || "Powerup") : ""
                                            font.pixelSize: Math.round(selectionRoot.height * 0.028)
                                            font.bold: true
                                            color: "#f4f4f7"
                                            visible: modelData.entryType === "powerup"
                                        }
                                        Label {
                                            text: modelData.entryType === "powerup" ? ((modelData.powerup.target === "self" ? "Self" : "Enemy") + " • " + modelData.powerup.type) : ""
                                            font.pixelSize: Math.round(selectionRoot.height * 0.022)
                                            color: "#c5c6d6"
                                            visible: modelData.entryType === "powerup"
                                        }
                                    }

                                    Label {
                                        text: modelData.entryType === "powerup" ? ("Amount: " + modelData.powerup.amount) : ""
                                        font.pixelSize: Math.round(selectionRoot.height * 0.022)
                                        color: "#c5c6d6"
                                        visible: modelData.entryType === "powerup"
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: modelData.entryType === "powerup"
                                    onClicked: {
                                        setSlot(pickerSlot, modelData)
                                        powerupPicker.close()
                                    }
                                }
                            }

                            Label {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 6
                                font.pixelSize: Math.round(selectionRoot.height * 0.026)
                                font.bold: true
                                color: "#f4f4f7"
                                text: modelData.entryType === "header" ? modelData.title : ""
                                visible: modelData.entryType === "header"
                            }

                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width * 0.8
                                height: 1
                                color: "#3a3a48"
                                visible: modelData.entryType === "divider"
                            }
                        }
                    }

                    Button {
                        text: "Cancel"
                        Layout.alignment: Qt.AlignRight
                        onClicked: powerupPicker.close()
                    }
                }

                onClosed: {
                    pickerSlot = -1
                    pickerEntries = []
                }
            }

            Component.onCompleted: {
                refreshLists()
                refreshSelections()
            }

            Connections {
                target: MainStore
                function onSingle_player_selected_powerupsChanged() {
                    refreshSelections()
                }
            }
        }
    }

    Component {
        id: singlePlayerGameComponent

        Item {
            id: gameHost
            width: flowStack.width
            height: flowStack.height

            property bool topDashboardReady: false
            property bool bottomDashboardReady: false
            property bool powerupsLoaded0: false
            property bool powerupsLoaded1: false
            property bool initialSetupDispatched: false
            property bool seedsBroadcast: false
            property bool indexSet0: false
            property bool indexSet1: false
            property int dashboardSeed0: -1
            property int dashboardSeed1: -1
            property bool gameInitialized: false
            property bool turnCycleStarted: false
            property bool initialGridReady0: false
            property bool initialGridReady1: false
            property var dashboardPowerData: ({ "0": [], "1": [] })
            property var powerupRuntimeState: ({})
            property var dragPermissions: ({ "0": {}, "1": {} })
            property var gridIdleState: ({ "0": false, "1": false })
            property var gridMovesRemaining: ({ "0": 0, "1": 0 })
            property int activeGridId: -1

            signal dashboardSetSwitchingEnabled(int gridId, bool enabled)
            signal dashboardSetFillingEnabled(int gridId, bool enabled)
            signal dashboardBeginFilling(int gridId, var payload)
            signal dashboardTurnEnded(int gridId, var payload)
            signal dashboardBeginTurn(int gridId, var payload)
            signal dashboardSetLaunchOnMatchEnabled(int gridId, bool enabled)
            signal dashboardActivatePowerup(int gridId, var payload)
            signal powerupRuntimeChanged()

            function handleDashboardCommand(gridId, command, payload) {
                switch (command) {
                case "PowerDataLoaded":
                    storeDashboardPowerups(gridId, payload)
                    break
                case "indexSet":
                    storeDashboardSeed(gridId, payload)
                    break
                default:
                    break
                }
            }

            function runtimeSlotsFor(gridId) {
                var key = String(gridId)
                if (powerupRuntimeState && powerupRuntimeState.hasOwnProperty(key)) {
                    return powerupRuntimeState[key].slots || {}
                }
                return {}
            }

            function runtimeSlotById(gridId, slotId) {
                var slots = runtimeSlotsFor(gridId)
                return slots[String(slotId)] || null
            }

            function storeDashboardPowerups(gridId, payload) {
                var key = gridId === 0 ? "0" : "1"
                var storedPayload = []
                if (payload !== undefined && payload !== null) {
                    try {
                        storedPayload = JSON.parse(JSON.stringify(payload))
                    } catch (err) {
                        storedPayload = payload
                    }
                }
                dashboardPowerData[key] = storedPayload
                if (gridId === 0) {
                    if (!powerupsLoaded0) {
                        powerupsLoaded0 = true
                    } else {
                        checkPowerupHandshake()
                    }
                } else if (gridId === 1) {
                    if (!powerupsLoaded1) {
                        powerupsLoaded1 = true
                    } else {
                        checkPowerupHandshake()
                    }
                }
            }

            function storeDashboardSeed(gridId, payload) {
                var value = -1
                if (payload && payload.seed !== undefined) {
                    var parsed = parseInt(payload.seed, 10)
                    if (!isNaN(parsed)) {
                        value = parsed
                    }
                }
                if (gridId === 0) {
                    dashboardSeed0 = value
                    indexSet0 = value >= 0
                } else if (gridId === 1) {
                    dashboardSeed1 = value
                    indexSet1 = value >= 0
                }
                checkIndexHandshake()
            }

            function checkPowerupHandshake() {
                if (initialSetupDispatched) {
                    return
                }
                if (!(powerupsLoaded0 && powerupsLoaded1)) {
                    return
                }
                initialSetupDispatched = true
                Qt.callLater(function() {
                    if (!seedsBroadcast) {
                        broadcastSeeds()
                    }
                    checkIndexHandshake()
                })
            }

            function broadcastSeeds() {
                if (seedsBroadcast) {
                    return
                }
                var seed0 = Math.floor(Math.random() * 500) + 1
                var seed1 = Math.floor(Math.random() * 500) + 1
                seedsBroadcast = true
                Qt.callLater(function() {
                    if (topDashboard && topDashboard.setSeed) {
                        topDashboard.setSeed(seed0)
                    }
                    if (bottomDashboard && bottomDashboard.setSeed) {
                        bottomDashboard.setSeed(seed1)
                    }
                })
            }

            function checkIndexHandshake() {
                if (gameInitialized) {
                    return
                }
                if (!(indexSet0 && indexSet1)) {
                    return
                }
                initializeGame()
            }

            function initializeGame() {
                if (gameInitialized) {
                    return
                }
                gameInitialized = true
                dashboardSetSwitchingEnabled(0, false)
                dashboardSetSwitchingEnabled(1, false)
                dashboardSetFillingEnabled(0, true)
                dashboardSetFillingEnabled(1, true)
                dashboardSetLaunchOnMatchEnabled(0, true)
                dashboardSetLaunchOnMatchEnabled(1, true)
                dashboardBeginFilling(0, { "source": "initializeGame" })
                dashboardBeginFilling(1, { "source": "initializeGame" })
                AppActions.setFillingEnabled(0, true)
                AppActions.setFillingEnabled(1, true)
                AppActions.setLaunchOnMatchEnabled(0, true)
                AppActions.setLaunchOnMatchEnabled(1, true)
                AppActions.beginFillCycle(0, "powerups_loaded")
                AppActions.beginFillCycle(1, "powerups_loaded")
                maybeStartTurnCycle()
            }

            function handleInitialGridReady(info) {
                if (!info) {
                    return
                }
                if (info.grid_id === 0 && info.initial_fill === false && info.has_empty === false) {
                    initialGridReady0 = true
                } else if (info.grid_id === 1 && info.initial_fill === false && info.has_empty === false) {
                    initialGridReady1 = true
                }
                maybeStartTurnCycle()
            }

            function maybeStartTurnCycle() {
                if (!gameInitialized || turnCycleStarted) {
                    return
                }
                if (!(initialGridReady0 && initialGridReady1)) {
                    return
                }
                turnCycleStarted = true
                AppActions.initializeTurnCycle({
                                                 "attacker_grid_id": turnController.playerGridId,
                                                 "defender_grid_id": turnController.cpuGridId,
                                                 "moves": turnController.movesPerTurn
                                             })
            }

            function updateRuntimeState(runtime) {
                powerupRuntimeState = runtime || {}
                computeDragPermissions()
                powerupRuntimeChanged()
                if (topDashboard) {
                    topDashboard.runtimeSlots = runtimeSlotsFor(0)
                }
                if (bottomDashboard) {
                    bottomDashboard.runtimeSlots = runtimeSlotsFor(1)
                }
            }

            function updateGridIdle(info) {
                if (!info || info.grid_id === undefined) {
                    return
                }
                var key = String(info.grid_id)
                var idle = info.state === "idle" && info.has_empty === false
                var updated = {}
                updated[key] = idle
                gridIdleState = Object.assign({}, gridIdleState, updated)
                computeDragPermissions()
            }

            function updateMoves(gridId, moves) {
                var key = String(gridId)
                var updated = {}
                updated[key] = moves
                gridMovesRemaining = Object.assign({}, gridMovesRemaining, updated)
                computeDragPermissions()
            }

            function updateActiveGrid(gridId) {
                activeGridId = gridId
                computeDragPermissions()
            }

            function computeDragPermissions() {
                var permissions = { "0": {}, "1": {} }
                if (activeGridId === -1) {
                    dragPermissions = permissions
                    return
                }
                var activeKey = String(activeGridId)
                var defenderKey = activeKey === "0" ? "1" : "0"
                if (gridMovesRemaining[activeKey] <= 0) {
                    dragPermissions = permissions
                    return
                }
                if (!(gridIdleState[activeKey] === true && gridIdleState[defenderKey] === true)) {
                    dragPermissions = permissions
                    return
                }
                var slots = runtimeSlotsFor(activeGridId)
                for (var slotKey in slots) {
                    if (!slots.hasOwnProperty(slotKey)) {
                        continue
                    }
                    var slotState = slots[slotKey]
                    permissions[activeKey][slotKey] = slotState.ready === true && slotState.deployed !== true
                }
                dragPermissions = permissions
                if (topDashboard) {
                    topDashboard.dragPermissions = dragPermissions["0"]
                }
                if (bottomDashboard) {
                    bottomDashboard.dragPermissions = dragPermissions["1"]
                }
            }

            function otherGridId(gridId) {
                return gridId === 0 ? 1 : 0
            }

            function extractSelectedCells(targets) {
                var cells = []
                if (!targets) {
                    return cells
                }
                if (typeof targets === "string") {
                    for (var s = 0; s < targets.length; ++s) {
                        if (targets.charAt(s) === "1") {
                            var r = Math.floor(s / 6)
                            var c = s % 6
                            cells.push({ "row": r, "column": c })
                        }
                    }
                    return cells
                }
                for (var i = 0; i < targets.length; ++i) {
                    var cell = targets[i]
                    if (cell === undefined || cell === null) {
                        continue
                    }
                    var row = Math.floor(i / 6)
                    var column = i % 6
                    var selected = false
                    if (typeof cell === "boolean") {
                        selected = cell
                    } else if (typeof cell === "object") {
                        if (cell.row !== undefined) {
                            row = cell.row
                        }
                        if (cell.column !== undefined) {
                            column = cell.column
                        } else if (cell.col !== undefined) {
                            column = cell.col
                        }
                        if (cell.selected !== undefined) {
                            selected = cell.selected === true
                        } else if (cell === true) {
                            selected = true
                        }
                    }
                    if (selected && row >= 0 && row < 6 && column >= 0 && column < 6) {
                        cells.push({ "row": row, "column": column })
                    }
                }
                return cells
            }

            function randomDeployedSlot(gridId) {
                var slots = runtimeSlotsFor(gridId)
                var deployed = []
                for (var key in slots) {
                    if (!slots.hasOwnProperty(key)) {
                        continue
                    }
                    var slotState = slots[key]
                    if (slotState.deployed === true && (slotState.health === undefined || slotState.health > 0)) {
                        deployed.push(slotState)
                    }
                }
                if (deployed.length === 0) {
                    return null
                }
                var index = Math.floor(Math.random() * deployed.length)
                return deployed[index]
            }

            function executePowerupAbility(data) {
                if (!data || data.grid_id === undefined || data.slot_id === undefined || !data.ability) {
                    return
                }
                var ability = data.ability
                var sourceGrid = data.grid_id
                var targetKeyRaw = (ability.target || "opponent").toString().toLowerCase()
                var targetKey = targetKeyRaw
                if (targetKeyRaw === "ally") {
                    targetKey = "self"
                } else if (targetKeyRaw === "enemy") {
                    targetKey = "opponent"
                }
                var abilityType = (ability.type || "blocks").toString().toLowerCase()
                var amount = ability.amount !== undefined ? ability.amount : 0
                var abilityColor = ability.color !== undefined ? ability.color : null
                if (abilityType === "blocks") {
                    var cells = extractSelectedCells(ability.gridTargets || ability.grid_targets)
                    if (cells.length === 0 || amount === 0) {
                        return
                    }
                    var targetGrid = targetKey === "self" ? sourceGrid : otherGridId(sourceGrid)
                    var mode = targetKey === "self" ? "heal" : "damage"
                    AppActions.applyPowerupBlocksEffect({
                                                           "grid_id": targetGrid,
                                                           "source_grid_id": sourceGrid,
                                                           "slot_id": data.slot_id,
                                                           "cells": cells,
                                                           "amount": Math.abs(amount),
                                                           "mode": mode,
                                                           "color": abilityColor
                                                       })
                } else if (abilityType === "powerup_health" || abilityType === "powerup" || abilityType === "powerup_card_health") {
                    var targetGridId = targetKey === "self" ? sourceGrid : otherGridId(sourceGrid)
                    var slotState = randomDeployedSlot(targetGridId)
                    if (!slotState || amount === 0) {
                        return
                    }
                    var delta = Math.abs(amount)
                    if (targetKey === "opponent") {
                        delta = -delta
                    }
                    AppActions.applyPowerupCardHealth({
                                                         "grid_id": targetGridId,
                                                         "slot_id": slotState.slot,
                                                         "amount": delta
                                                     })
                } else if (abilityType === "health" || abilityType === "player_health") {
                    if (amount === 0) {
                        return
                    }
                    var targetGridForHealth = targetKey === "self" ? sourceGrid : otherGridId(sourceGrid)
                    var deltaHealth = Math.abs(amount)
                    if (targetKey === "opponent") {
                        deltaHealth = -deltaHealth
                    }
                    AppActions.powerupPlayerHealthDelta(targetGridForHealth, deltaHealth, "powerup")
                }
            }

            onPowerupsLoaded0Changed: checkPowerupHandshake()
            onPowerupsLoaded1Changed: checkPowerupHandshake()

            Rectangle {
                anchors.fill: parent
                color: "black"

                TurnController {
                    id: turnController
                    gridOrder: [0, 1]
                    movesPerTurn: 3
                    cpuGridId: 0
                    playerGridId: 1
                }

                CpuController {
                    id: cpuController
                    gridId: 0
                    grid: gameGridTop
                }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: gameHost.height * 0.015
                spacing: gameHost.height * 0.02

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: gameHost.height * 0.45

                        RowLayout {
                            anchors.fill: parent
                            spacing: gameHost.width * 0.03

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                GameGrid {
                                    id: gameGridTop
                                    anchors.fill: parent
                                    grid_id: 0
                                    fillDirection: 1
                                }
                            }

                            GameBoardDashboard {
                                id: topDashboard
                                Layout.preferredWidth: Math.min(gameHost.width * 0.24, 220)
                                Layout.fillHeight: true
                                gridId: 0
                                runtimeSlots: ({})
                                dragPermissions: ({})
                                Connections {
                                    target: topDashboard
                                    function onReadyStateMod(grid, ready, role) {
                                        gameHost.topDashboardReady = ready
                                        if (ready) {
                                            AppActions.gameBoardDashboardsReady({ "grid_id": grid, "role": role })
                                        }
                                    }
                                    function onDashboardCommand(grid, command, payload) {
                                        gameHost.handleDashboardCommand(grid, command, payload)
                                    }
                                }
                                Connections {
                                    target: gameHost
                                    function onDashboardSetSwitchingEnabled(grid, enabled) {
                                        if (grid === topDashboard.gridId) {
                                            topDashboard.setSwitchingEnabled(enabled)
                                        }
                                    }
                                    function onDashboardSetFillingEnabled(grid, enabled) {
                                        if (grid === topDashboard.gridId) {
                                            topDashboard.setFillingEnabled(enabled)
                                        }
                                    }
                                    function onDashboardBeginFilling(grid, payload) {
                                        if (grid === topDashboard.gridId) {
                                            topDashboard.beginFilling(payload)
                                        }
                                    }
                                    function onDashboardTurnEnded(grid, payload) {
                                        if (grid === topDashboard.gridId) {
                                            topDashboard.turnEnded(payload)
                                        }
                                    }
                                    function onDashboardBeginTurn(grid, payload) {
                                        if (grid === topDashboard.gridId) {
                                            topDashboard.beginTurn(payload)
                                        }
                                    }
                                    function onDashboardSetLaunchOnMatchEnabled(grid, enabled) {
                                        if (grid === topDashboard.gridId) {
                                            topDashboard.setLaunchOnMatchEnabled(enabled)
                                        }
                                    }
                                    function onDashboardActivatePowerup(grid, payload) {
                                        if (grid === topDashboard.gridId) {
                                            topDashboard.activatePowerup(payload)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: gameHost.height * 0.05

                        Text {
                            anchors.centerIn: parent
                            text: "Waiting for Opponent"
                            color: "#f6f6ff"
                            font.pixelSize: Math.round(gameHost.height * 0.035)
                            visible: !(gameHost.topDashboardReady && gameHost.bottomDashboardReady)
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: gameHost.height * 0.45

                        RowLayout {
                            anchors.fill: parent
                            spacing: gameHost.width * 0.03

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                GameGrid {
                                    id: gameGridBottom
                                    anchors.fill: parent
                                    grid_id: 1
                                    fillDirection: -1
                                }
                            }

                            GameBoardDashboard {
                                id: bottomDashboard
                                Layout.preferredWidth: Math.min(gameHost.width * 0.24, 220)
                                Layout.fillHeight: true
                                gridId: 1
                                runtimeSlots: ({})
                                dragPermissions: ({})
                                Connections {
                                    target: bottomDashboard
                                    function onReadyStateMod(grid, ready, role) {
                                        gameHost.bottomDashboardReady = ready
                                        if (ready) {
                                            AppActions.gameBoardDashboardsReady({ "grid_id": grid, "role": role })
                                        }
                                    }
                                    function onDashboardCommand(grid, command, payload) {
                                        gameHost.handleDashboardCommand(grid, command, payload)
                                    }
                                }
                                Connections {
                                    target: gameHost
                                    function onDashboardSetSwitchingEnabled(grid, enabled) {
                                        if (grid === bottomDashboard.gridId) {
                                            bottomDashboard.setSwitchingEnabled(enabled)
                                        }
                                    }
                                    function onDashboardSetFillingEnabled(grid, enabled) {
                                        if (grid === bottomDashboard.gridId) {
                                            bottomDashboard.setFillingEnabled(enabled)
                                        }
                                    }
                                    function onDashboardBeginFilling(grid, payload) {
                                        if (grid === bottomDashboard.gridId) {
                                            bottomDashboard.beginFilling(payload)
                                        }
                                    }
                                    function onDashboardTurnEnded(grid, payload) {
                                        if (grid === bottomDashboard.gridId) {
                                            bottomDashboard.turnEnded(payload)
                                        }
                                    }
                                    function onDashboardBeginTurn(grid, payload) {
                                        if (grid === bottomDashboard.gridId) {
                                            bottomDashboard.beginTurn(payload)
                                        }
                                    }
                                    function onDashboardSetLaunchOnMatchEnabled(grid, enabled) {
                                        if (grid === bottomDashboard.gridId) {
                                            bottomDashboard.setLaunchOnMatchEnabled(enabled)
                                        }
                                    }
                                    function onDashboardActivatePowerup(grid, payload) {
                                        if (grid === bottomDashboard.gridId) {
                                            bottomDashboard.activatePowerup(payload)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                GridController {
                    id: gridControllerTop
                    grid_id: 0
                    gridItem: gameGridTop
                }

                GridController {
                    id: gridControllerBottom
                    grid_id: 1
                    gridItem: gameGridBottom
                }

                Component.onCompleted: {
                    checkPowerupHandshake()
                    gameHost.updateRuntimeState(MainStore.powerup_runtime_state)
                }

                AppListener {
                    filter: ActionTypes.enableBlocks
                    onDispatched: function(type, data) {
                        if (!data || data.grid_id === undefined) {
                            return
                        }
                        gameHost.dashboardSetSwitchingEnabled(data.grid_id, data.blocks_enabled === true)
                    }
                }

                AppListener {
                    filter: ActionTypes.beginFillCycle
                    onDispatched: function(type, data) {
                        if (!data || data.grid_id === undefined) {
                            return
                        }
                        gameHost.dashboardSetFillingEnabled(data.grid_id, true)
                        gameHost.dashboardBeginFilling(data.grid_id, data || ({}))
                        var key = String(data.grid_id)
                        var updated = {}
                        updated[key] = false
                        gameHost.gridIdleState = Object.assign({}, gameHost.gridIdleState, updated)
                    }
                }

                AppListener {
                    filter: ActionTypes.gridSettled
                    onDispatched: function(type, info) {
                        if (!info || info.grid_id === undefined) {
                            return
                        }
                        gameHost.dashboardSetFillingEnabled(info.grid_id, info.has_empty === true)
                        if (!gameHost.turnCycleStarted) {
                            gameHost.handleInitialGridReady(info)
                        }
                        gameHost.updateGridIdle(info)
                    }
                }

                AppListener {
                    filter: ActionTypes.setFillingEnabled
                    onDispatched: function(type, data) {
                        if (!data || data.grid_id === undefined) {
                            return
                        }
                        gameHost.dashboardSetFillingEnabled(data.grid_id, data.enabled === true)
                        if (data.enabled === true) {
                            gameHost.dashboardBeginFilling(data.grid_id, { "source": "resume" })
                            var key = String(data.grid_id)
                            var updated = {}
                            updated[key] = false
                            gameHost.gridIdleState = Object.assign({}, gameHost.gridIdleState, updated)
                        }
                    }
                }

                AppListener {
                    filter: ActionTypes.turnCycleTurnBegan
                    onDispatched: function(type, data) {
                        if (!data || data.grid_id === undefined) {
                            return
                        }
                        gameHost.updateActiveGrid(data.grid_id)
                        gameHost.updateMoves(data.grid_id, data.moves_remaining !== undefined ? data.moves_remaining : 0)
                        if (data.defender_grid_id !== undefined) {
                            gameHost.updateMoves(data.defender_grid_id, 0)
                        }
                        gameHost.dashboardBeginTurn(data.grid_id, data || ({}))
                    }
                }

                AppListener {
                    filter: ActionTypes.requestNextTurn
                    onDispatched: function(type, data) {
                        if (!data || data.from_grid_id === undefined) {
                            return
                        }
                        gameHost.dashboardTurnEnded(data.from_grid_id, data || ({}))
                        gameHost.updateMoves(data.from_grid_id, 0)
                    }
                }

                AppListener {
                    filter: ActionTypes.swapLaunchingStarted
                    onDispatched: function(type, data) {
                        if (!data || data.grid_id === undefined) {
                            return
                        }
                        gameHost.dashboardSetLaunchOnMatchEnabled(data.grid_id, false)
                        gameHost.updateMoves(data.grid_id, data.moves_remaining !== undefined ? data.moves_remaining : 0)
                    }
                }

                AppListener {
                    filter: ActionTypes.swapLaunchingAnimationsDone
                    onDispatched: function(type, data) {
                        if (!data || data.grid_id === undefined) {
                            return
                        }
                        gameHost.dashboardSetLaunchOnMatchEnabled(data.grid_id, true)
                    }
                }

                AppListener {
                    filter: ActionTypes.setLaunchOnMatchEnabled
                    onDispatched: function(type, data) {
                        if (!data || data.grid_id === undefined) {
                            return
                        }
                        gameHost.dashboardSetLaunchOnMatchEnabled(data.grid_id, data.enabled === true)
                    }
                }

                AppListener {
                    filter: ActionTypes.activatePowerup
                    onDispatched: function(type, data) {
                        if (!data || data.grid_id === undefined) {
                            return
                        }
                        gameHost.dashboardActivatePowerup(data.grid_id, data || ({}))
                    }
                }

                AppListener {
                    filter: ActionTypes.executePowerupAbility
                    onDispatched: function(type, data) {
                        gameHost.executePowerupAbility(data)
                    }
                }

                Connections {
                    target: MainStore
                    function onPowerup_runtime_stateChanged() {
                        gameHost.updateRuntimeState(MainStore.powerup_runtime_state)
                    }
                }


            }
        }
    }

    AppListener {
        filter: "singlePlayerSelectionConfirmed"
        onDispatched: function (type, message) {
            if (!loaderCompleted) {
                return
            }
            if (!gameActivated) {
                flowStack.replace(singlePlayerGameComponent)
                gameActivated = true
            }
        }
    }
}
