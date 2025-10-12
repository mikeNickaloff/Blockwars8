import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Promises 1.0
import "../actions" 1.0
import "../stores" 1.0

Item {
    id: powerupEditor

    width: parent ? parent.width : 480
    height: parent ? parent.height : 640

    property string errorMessage: ""
    property bool _initialSignalSent: false

    signal powerupsLoaded(var grid_id)

    function closeDialog() {
        // Placeholder to keep compatibility with older dialog-based flows.
        while (stackView.depth > 1) {
            stackView.pop()
        }
    }

    ListModel {
        id: powerupModel
    }

    Component.onCompleted: {
        MainStore.loadPowerupData()
        refreshPowerups()
    }

    Connections {
        target: MainStore
        function onMy_powerup_dataChanged() {
            refreshPowerups()
        }
    }

    function refreshPowerups() {
        powerupModel.clear()
        var data = MainStore.my_powerup_data
        if (!data) {
            return
        }
        var keys = Object.keys(data).sort(function (a, b) {
            return parseInt(a, 10) - parseInt(b, 10)
        })
        for (var i = 0; i < keys.length; ++i) {
            var slotKey = keys[i]
            powerupModel.append({
                                     "powerup": normalizePowerup(data[slotKey])
                                 })
        }
        if (!_initialSignalSent) {
            _initialSignalSent = true
            powerupEditor.powerupsLoaded(0)
        }
    }

    function createGridTargets() {
        var arr = []
        for (var r = 0; r < 6; ++r) {
            for (var c = 0; c < 6; ++c) {
                arr.push({
                             "row": r,
                             "col": c,
                             "selected": false
                         })
            }
        }
        return arr
    }

    function gridFromSource(source) {
        var grid = createGridTargets()
        if (source === null || source === undefined) {
            return grid
        }
        if (Array.isArray(source)) {
            for (var i = 0; i < source.length; ++i) {
                var cell = source[i]
                if (cell === undefined || cell === null) {
                    continue
                }
                var row = Math.floor(i / 6)
                var col = (i % 6)
                var isSelected = false
                if (Array.isArray(cell)) {
                    row = cell.length > 0 ? cell[0] : row
                    col = cell.length > 1 ? cell[1] : col
                    isSelected = cell.length > 2 ? cell[2] === true : true
                } else {
                    row = cell.row !== undefined ? cell.row : row
                    col = cell.col !== undefined ? cell.col : col
                    if (cell && cell.hasOwnProperty("selected")) {
                        isSelected = cell.selected === true
                    } else if (cell === true) {
                        isSelected = true
                    }
                }
                var idx = row * 6 + col
                if (idx >= 0 && idx < grid.length) {
                    grid[idx].selected = isSelected
                }
            }
            return grid
        }
        if (typeof source === "string") {
            for (var j = 0; j < Math.min(source.length, grid.length); ++j) {
                grid[j].selected = source.charAt(j) === "1"
            }
            return grid
        }
        var candidate = source
        if (source.grid !== undefined) {
            candidate = source.grid
        }
        if (candidate && typeof candidate === "object") {
            for (var key in candidate) {
                if (!candidate.hasOwnProperty(key)) {
                    continue
                }
                var idxKey = parseInt(key, 10)
                if (isNaN(idxKey)) {
                    continue
                }
                if (candidate[key]) {
                    var r = Math.floor(idxKey / 6)
                    var c = idxKey % 6
                    var mapped = r * 6 + c
                    if (mapped >= 0 && mapped < grid.length) {
                        grid[mapped].selected = true
                    }
                }
            }
            return grid
        }
        return grid
    }

    function normalizePowerup(raw) {
        var slotValue = 0
        if (raw && raw.slot !== undefined && !isNaN(raw.slot)) {
            slotValue = parseInt(raw.slot, 10)
        }
        var normalized = {
            "slot": slotValue,
            "target": raw && raw.target !== undefined ? raw.target : "opponent",
            "type": raw && raw.type !== undefined ? raw.type : (raw && raw.kind !== undefined ? raw.kind : "blocks"),
            "color": raw && raw.color !== undefined ? raw.color : "red",
            "amount": raw && raw.amount !== undefined ? raw.amount : 1,
            "hero_targets": raw && raw.hero_targets !== undefined ? raw.hero_targets : 0,
            "grid_targets": gridFromSource(null)
        }
        normalized.target = (normalized.target || "opponent").toString().toLowerCase()
        normalized.type = (normalized.type || "blocks").toString().toLowerCase()
        normalized.color = (normalized.color || "red").toString().toLowerCase()
        switch (normalized.target) {
        case "self":
        case "ally":
        case "player":
        case "self_grid":
        case "my":
            normalized.target = "self"
            break
        default:
            normalized.target = "opponent"
            break
        }
        if (normalized.type === "hero" || normalized.type === "heroes") {
            normalized.type = "heros"
        }
        if (normalized.type === "block") {
            normalized.type = "blocks"
        }
        if (raw && raw.energy !== undefined) {
            normalized.energy = raw.energy
        }
        if (raw) {
            if (raw.grid_targets !== undefined) {
                normalized.grid_targets = gridFromSource(raw.grid_targets)
            } else if (raw.grid !== undefined) {
                normalized.grid_targets = gridFromSource(raw.grid)
            } else if (raw.targets !== undefined) {
                normalized.grid_targets = gridFromSource(raw.targets)
            } else if (raw.cells !== undefined) {
                normalized.grid_targets = gridFromSource(raw.cells)
            }
        }
        if (normalized.type === "blocks" && normalized.grid_targets.length !== 36) {
            normalized.grid_targets = createGridTargets()
        }
        return normalized
    }

    function copyPowerup(powerup) {
        return normalizePowerup(JSON.parse(JSON.stringify(powerup)))
    }

    function createEmptyPowerup(slot) {
        return {
            "slot": slot,
            "target": "opponent",
            "type": "blocks",
            "color": "green",
            "amount": 1,
            "hero_targets": 0,
            "grid_targets": createGridTargets()
        }
    }

    function countSelectedBlocks(powerup) {
        var grid = powerup.grid_targets || []
        var count = 0
        for (var i = 0; i < grid.length; ++i) {
            if (grid[i] && grid[i].selected) {
                count += 1
            }
        }
        return count
    }

    function calculateEnergy(powerup) {
        var amount = Math.abs(powerup.amount || 0)
        if (powerup.type === "blocks") {
            return Math.round(countSelectedBlocks(powerup) * amount * 0.5)
        }
        if (powerup.type === "heros") {
            var heroCount = powerup.hero_targets > 0 ? powerup.hero_targets : 1
            return Math.round(heroCount * amount * 0.5)
        }
        return Math.round(amount * 0.5)
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
            return "#aaaaaa"
        }
    }

    function getNextSlot() {
        var data = MainStore.my_powerup_data || {}
        var candidate = 0
        while (data.hasOwnProperty(candidate) || data.hasOwnProperty(candidate.toString())) {
            candidate += 1
        }
        return candidate
    }

    function beginCreate() {
        errorMessage = ""
        var slot = getNextSlot()
        var powerup = createEmptyPowerup(slot)
        stackView.push(createFormComponent, {
                            "powerupData": powerup,
                            "mode": "create"
                        })
    }

    function beginEdit(powerup) {
        errorMessage = ""
        stackView.push(createFormComponent, {
                            "powerupData": copyPowerup(powerup),
                            "mode": "edit"
                        })
    }

    function proceedToConfiguration(powerupData, mode) {
        if (powerupData.type === "blocks") {
            stackView.push(selectBlocksComponent, {
                                "powerupData": copyPowerup(powerupData),
                                "mode": mode
                            })
        } else {
            stackView.push(amountOnlyComponent, {
                                "powerupData": copyPowerup(powerupData),
                                "mode": mode
                            })
        }
    }

    function buildPowerupMap(existing, normalized) {
        var updated = {}
        if (existing) {
            var keys = Object.keys(existing)
            for (var i = 0; i < keys.length; ++i) {
                var key = keys[i]
                updated[key] = normalizePowerup(existing[key])
            }
        }
        updated[normalized.slot] = normalized
        return updated
    }

    function savePowerup(powerup) {
        errorMessage = ""
        var latch = PromiseUtils.create(powerupEditor)
        var finalize = function () {
            errorMessage = ""
            refreshPowerups()
            while (stackView.depth > 1) {
                stackView.pop()
            }
        }
        var fail = function (key) {
            if (key !== "validation" && errorMessage.length === 0) {
                errorMessage = "Unable to complete powerup save."
            }
        }
        if (latch) {
            var hasAllSignal = (typeof latch.all === 'function' && typeof latch.all.connect === 'function')
            var hasFailedSignal = (typeof latch.failed === 'function' && typeof latch.failed.connect === 'function')
            if (hasAllSignal) {
                latch.all.connect(finalize)
            }
            if (hasFailedSignal) {
                latch.failed.connect(fail)
            }
            latch.require(function (resolve, reject) {
                if (powerup.type === "blocks" && countSelectedBlocks(powerup) === 0) {
                    errorMessage = "Select at least one block for this powerup."
                    reject("validation")
                    return
                }
                if (powerup.type === "heros" && powerup.hero_targets < 1) {
                    errorMessage = "Choose at least one hero target."
                    reject("validation")
                    return
                }
                resolve()
            })
            latch.require(function (resolve, reject) {
                try {
                    var normalized = normalizePowerup(powerup)
                    var combined = buildPowerupMap(MainStore.my_powerup_data, normalized)
                    MainStore.my_powerup_data = combined
                    MainStore.savePowerupData()
                    resolve()
                } catch (err) {
                    errorMessage = "Failed to save powerup."
                    reject("save")
                }
            })

            if (!hasAllSignal && !hasFailedSignal) {
                if (errorMessage.length === 0) {
                    finalize()
                } else {
                    fail("validation")
                }
            }
        } else {
            if (powerup.type === "blocks" && countSelectedBlocks(powerup) === 0) {
                errorMessage = "Select at least one block for this powerup."
                fail("validation")
                return
            }
            if (powerup.type === "heros" && powerup.hero_targets < 1) {
                errorMessage = "Choose at least one hero target."
                fail("validation")
                return
            }
            try {
                var normalizedPowerup = normalizePowerup(powerup)
                var merged = buildPowerupMap(MainStore.my_powerup_data, normalizedPowerup)
                MainStore.my_powerup_data = merged
                MainStore.savePowerupData()
                finalize()
            } catch (errSave) {
                errorMessage = "Failed to save powerup."
                fail("save")
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: menuPageComponent
    }

    Component {
        id: menuPageComponent
        Item {
            width: parent ? parent.width : powerupEditor.width
            height: parent ? parent.height : powerupEditor.height

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width * 0.65
                spacing: 16

                Label {
                    text: "Powerup Editor"
                    font.pixelSize: 28
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }

                Button {
                    text: "Create New"
                    Layout.fillWidth: true
                    onClicked: powerupEditor.beginCreate()
                }

                Button {
                    text: "Edit Existing"
                    Layout.fillWidth: true
                    enabled: powerupModel.count > 0
                    onClicked: stackView.push(editListComponent)
                }

                Button {
                    text: "Back to Main Menu"
                    Layout.fillWidth: true
                    onClicked: AppActions.enterZoneMainMenu()
                }

                Label {
                    text: powerupEditor.errorMessage
                    visible: powerupEditor.errorMessage.length > 0
                    color: "#ff6666"
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
            }
        }
    }

    Component {
        id: editListComponent
        Item {
            width: parent ? parent.width : powerupEditor.width
            height: parent ? parent.height : powerupEditor.height

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: parent.width * 0.05
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Choose Powerup"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    ToolButton {
                        text: "X"
                        onClicked: stackView.pop()
                        background: Rectangle {
                            color: "#b22222"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: powerupModel
                    spacing: 12
                    clip: true

                    delegate: Frame {
                        width: ListView.view.width
                        implicitHeight: 120

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                Rectangle {
                                    width: 48
                                    height: 48
                                    radius: 6
                                    color: colorForName(model.powerup.color)
                                    border.color: "#222222"
                                    border.width: 2
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Label {
                                        text: "Slot " + model.powerup.slot + " • " + model.powerup.type
                                        font.bold: true
                                    }
                                    Label {
                                        text: "Target: " + model.powerup.target
                                    }
                                    Label {
                                        text: model.powerup.type === "blocks" ?
                                                  ("Blocks selected: " + countSelectedBlocks(model.powerup)) :
                                                  (model.powerup.type === "heros" ?
                                                       ("Hero targets: " + model.powerup.hero_targets) :
                                                       "Player Health")
                                    }
                                }

                                ColumnLayout {
                                    spacing: 4

                                    Label {
                                        text: "Amount"
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                    Label {
                                        text: model.powerup.amount
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }

                                ColumnLayout {
                                    spacing: 4

                                    Label {
                                        text: "Energy"
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                    Label {
                                        text: calculateEnergy(model.powerup)
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: powerupEditor.beginEdit(model.powerup)
                        }
                    }

                    footer: Item {
                        implicitHeight: 0
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: powerupModel.count === 0 ? "No saved powerups yet." : ""
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    Component {
        id: createFormComponent
        Item {
            property var powerupData
            property string mode: "create"

            width: parent ? parent.width : powerupEditor.width
            height: parent ? parent.height : powerupEditor.height

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: parent.width * 0.05
                spacing: 18

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: mode === "edit" ? "Edit Powerup" : "Create Powerup"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    ToolButton {
                        text: "X"
                        onClicked: stackView.pop()
                        background: Rectangle {
                            color: "#b22222"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                ComboBox {
                    id: targetPlayerCombo
                    Layout.fillWidth: true
                    model: ["Enemy", "Self"]
                }

                ComboBox {
                    id: targetTypeCombo
                    Layout.fillWidth: true
                    model: ["Blocks", "Hero(s)", "Player Health"]
                }

                ComboBox {
                    id: colorCombo
                    Layout.fillWidth: true
                    model: ["Red", "Green", "Blue", "Yellow"]
                }

                Item {
                    Layout.fillHeight: true
                }

                Button {
                    text: "Next"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        powerupData.target = targetPlayerCombo.currentIndex === 1 ? "self" : "opponent"
                        powerupData.type = targetTypeCombo.currentIndex === 0 ? "blocks" : (targetTypeCombo.currentIndex === 1 ? "heros" : "health")
                        powerupData.color = colorCombo.currentText.toLowerCase()
                        if (powerupData.type === "heros" && (!powerupData.hero_targets || powerupData.hero_targets < 1)) {
                            powerupData.hero_targets = 1
                        }
                        powerupEditor.proceedToConfiguration(powerupData, mode)
                    }
                }

                Component.onCompleted: {
                    targetPlayerCombo.currentIndex = powerupData.target === "self" ? 1 : 0
                    if (powerupData.type === "blocks") {
                        targetTypeCombo.currentIndex = 0
                    } else if (powerupData.type === "heros") {
                        targetTypeCombo.currentIndex = 1
                    } else {
                        targetTypeCombo.currentIndex = 2
                    }
                    var colorIndex = colorCombo.model.indexOf(powerupData.color ? powerupData.color.charAt(0).toUpperCase() + powerupData.color.slice(1) : "Green")
                    if (colorIndex >= 0) {
                        colorCombo.currentIndex = colorIndex
                    } else {
                        colorCombo.currentIndex = 1
                    }
                }
            }
        }
    }

    Component {
        id: selectBlocksComponent
        Item {
            property var powerupData
            property string mode: "create"

            width: parent ? parent.width : powerupEditor.width
            height: parent ? parent.height : powerupEditor.height

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: parent.width * 0.05
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Select Blocks"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    ToolButton {
                        text: "X"
                        onClicked: stackView.pop()
                        background: Rectangle {
                            color: "#b22222"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Grid {
                    id: blockGrid
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.preferredWidth: Math.min(parent.width * 0.7, parent.width * 0.9)
                    Layout.preferredHeight: Layout.preferredWidth
                    width: Layout.preferredWidth
                    height: Layout.preferredHeight
                    columns: 6
                    rows: 6
                    columnSpacing: 6
                    rowSpacing: 6

                    Repeater {
                        model: powerupData.grid_targets.length
                        delegate: Rectangle {
                            id: blockCell
                            width: (blockGrid.width - ((blockGrid.columns - 1) * blockGrid.columnSpacing)) / blockGrid.columns
                            height: width
                            radius: 8
                            color: "transparent"
                            border.width: 0

                            property bool isSelected: powerupData.grid_targets[index].selected === true
                            property color baseColor: isSelected ? colorForName(powerupData.color) : "#6b6b6b"

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: parent.width * 0.08
                                radius: parent.radius * 0.8
                                border.width: isSelected ? 3 : 2
                                border.color: isSelected ? Qt.lighter(blockCell.baseColor, 1.3) : "#4a4a4a"
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: Qt.lighter(blockCell.baseColor, 1.25) }
                                    GradientStop { position: 0.45; color: blockCell.baseColor }
                                    GradientStop { position: 1.0; color: Qt.darker(blockCell.baseColor, isSelected ? 1.45 : 1.2) }
                                }
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width * 0.55
                                height: width
                                radius: width / 2
                                color: isSelected ? Qt.lighter(blockCell.baseColor, 1.5) : "#bcbcbc"
                                border.width: 1
                                border.color: isSelected ? Qt.darker(blockCell.baseColor, 1.4) : "#858585"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    powerupData.grid_targets[index].selected = !powerupData.grid_targets[index].selected
                                }
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Label {
                        text: "Amount: " + powerupData.amount
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Slider {
                        id: amountSlider
                        from: 1
                        to: 20
                        stepSize: 1
                        Layout.fillWidth: true
                        value: Math.max(1, powerupData.amount)
                        onMoved: powerupData.amount = Math.round(value)
                        onValueChanged: powerupData.amount = Math.round(value)
                    }
                }

                Label {
                    text: powerupEditor.errorMessage
                    visible: powerupEditor.errorMessage.length > 0
                    color: "#ff6666"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Button {
                    text: mode === "edit" ? "Save" : "Finish"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: powerupEditor.savePowerup(powerupData)
                }
            }
        }
    }

    Component {
        id: amountOnlyComponent
        Item {
            property var powerupData
            property string mode: "create"

            width: parent ? parent.width : powerupEditor.width
            height: parent ? parent.height : powerupEditor.height

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: parent.width * 0.05
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: powerupData.type === "heros" ? "Configure Hero Powerup" : "Configure Powerup"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    ToolButton {
                        text: "X"
                        onClicked: stackView.pop()
                        background: Rectangle {
                            color: "#b22222"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Label {
                        text: "Amount: " + powerupData.amount
                    }

                    Slider {
                        from: 0
                        to: 100
                        stepSize: 1
                        Layout.fillWidth: true
                        value: Math.max(0, powerupData.amount)
                        onMoved: powerupData.amount = Math.round(value)
                        onValueChanged: powerupData.amount = Math.round(value)
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: powerupData.type === "heros"

                    Label {
                        text: "Hero Targets: " + powerupData.hero_targets
                    }

                    Slider {
                        from: 1
                        to: 6
                        stepSize: 1
                        Layout.fillWidth: true
                        value: Math.max(1, powerupData.hero_targets)
                        onMoved: powerupData.hero_targets = Math.round(value)
                        onValueChanged: powerupData.hero_targets = Math.round(value)
                    }
                }

                Label {
                    text: powerupEditor.errorMessage
                    visible: powerupEditor.errorMessage.length > 0
                    color: "#ff6666"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Button {
                    text: mode === "edit" ? "Save" : "Finish"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: powerupEditor.savePowerup(powerupData)
                }
            }
        }
    }
}
