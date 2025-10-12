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
                                }
                            }

                            GameBoardDashboard {
                                id: topDashboard
                                Layout.preferredWidth: Math.min(gameHost.width * 0.24, 220)
                                Layout.fillHeight: true
                                gridId: 0
                                Connections {
                                    target: topDashboard
                                    function onReadyStateMod(grid, ready, role) {
                                        gameHost.topDashboardReady = ready
                                        if (ready) {
                                            AppActions.gameBoardDashboardsReady({ "grid_id": grid, "role": role })
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
                                    rotation: 180
                                    transformOrigin: gameGridBottom.Center
                                    grid_id: 1
                                }
                            }

                            GameBoardDashboard {
                                id: bottomDashboard
                                Layout.preferredWidth: Math.min(gameHost.width * 0.24, 220)
                                Layout.fillHeight: true
                                gridId: 1
                                Connections {
                                    target: bottomDashboard
                                    function onReadyStateMod(grid, ready, role) {
                                        gameHost.bottomDashboardReady = ready
                                        if (ready) {
                                            AppActions.gameBoardDashboardsReady({ "grid_id": grid, "role": role })
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
                    AppActions.beginFillCycle(0, "initial")
                    AppActions.beginFillCycle(1, "initial")
                    AppActions.createOneShotTimer(gameHost, 240, function() {
                        AppActions.initializeTurnCycle({
                                                         "attacker_grid_id": turnController.playerGridId,
                                                         "defender_grid_id": turnController.cpuGridId,
                                                         "moves": turnController.movesPerTurn
                                                     })
                    }, ({}))
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
