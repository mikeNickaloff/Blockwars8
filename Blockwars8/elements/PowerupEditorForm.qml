import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

Pane {
    id: editorForm

    property QtObject bridge
    property QtObject actions
    property int slotId: -1

    readonly property bool isEditable: bridge && actions && slotId >= 0
    property bool isLoading: false
    property var localState: ({
        name: "",
        target: "opponent",
        type: "blocks",
        color: "red",
        amount: 0,
        life: 0,
        grid: ({})
    })
    property int computedEnergy: 0
    property var gridSelection: ({})

    readonly property var targetOptions: [
        { text: qsTr("Opponent"), value: "opponent" },
        { text: qsTr("Self"), value: "self" }
    ]
    readonly property var typeOptions: [
        { text: qsTr("Blocks"), value: "blocks" },
        { text: qsTr("Health"), value: "health" },
        { text: qsTr("Heros"), value: "heros" }
    ]
    readonly property var colorOptions: [
        { text: qsTr("Red"), value: "red" },
        { text: qsTr("Green"), value: "green" },
        { text: qsTr("Blue"), value: "blue" },
        { text: qsTr("Yellow"), value: "yellow" }
    ]

    padding: 18

    background: Rectangle {
        radius: 16
        color: "#151c2a"
        border.width: 1
        border.color: "#262f45"
    }

    Timer {
        id: commitTimer
        interval: 80
        repeat: false
        onTriggered: editorForm.commit()
    }

    function mergeState(target, changes) {
        var merged = {}
        for (var key in target) {
            if (target.hasOwnProperty(key)) {
                merged[key] = target[key]
            }
        }
        for (var c in changes) {
            if (changes.hasOwnProperty(c)) {
                merged[c] = changes[c]
            }
        }
        return merged
    }

    function selectionClone(source) {
        var clone = {}
        if (!source) {
            return clone
        }
        for (var key in source) {
            if (source.hasOwnProperty(key) && source[key]) {
                clone[key] = true
            }
        }
        return clone
    }

    function scheduleCommit() {
        if (!isEditable || isLoading) {
            return
        }
        commitTimer.restart()
    }

    function updateLocal(changes) {
        localState = mergeState(localState, changes)
    }

    function refreshFromStore() {
        if (!bridge || !bridge.store || slotId < 0) {
            isLoading = true
            localState = mergeState(localState, {
                                          grid: ({}),
                                          name: "",
                                          target: "opponent",
                                          type: "blocks",
                                          color: "red",
                                          amount: 0,
                                          life: 0
                                      })
            gridSelection = ({})
            computedEnergy = 0
            isLoading = false
            return
        }
        isLoading = true
        var record = bridge.extractor.record(slotId)
        var displayName = record && record.name !== undefined ? ("" + record.name) : bridge.extractor.displayName(slotId)
        var target = bridge.extractor.textFor("slot_targets", slotId)
        if (!target || target.length === 0) {
            target = "opponent"
        }
        var type = bridge.extractor.textFor("slot_types", slotId)
        if (!type || type.length === 0) {
            type = "blocks"
        }
        var color = bridge.extractor.textFor("slot_colors", slotId)
        if (!color || color.length === 0) {
            color = "red"
        }
        var amount = bridge.extractor.numericFor("slot_amounts", slotId)
        var lifeValue = bridge.extractor.numericFor("slot_life", slotId)
        var grid = bridge.extractor.gridFor(slotId)
        computedEnergy = bridge.extractor.numericFor("slot_energy", slotId)
        localState = {
            name: displayName,
            target: target,
            type: type,
            color: color,
            amount: amount,
            life: lifeValue,
            grid: selectionClone(grid)
        }
        gridSelection = selectionClone(grid)
        nameField.text = displayName
        targetSelector.currentIndex = optionIndex(targetOptions, target)
        typeSelector.currentIndex = optionIndex(typeOptions, type)
        colorSelector.currentIndex = optionIndex(colorOptions, color)
        damageSpin.value = amount
        lifeSpin.value = lifeValue
        isLoading = false
    }

    function optionIndex(list, value) {
        for (var i = 0; i < list.length; ++i) {
            if (list[i].value === value) {
                return i
            }
        }
        return 0
    }

    function commit() {
        if (!isEditable || isLoading) {
            return
        }
        var payload = {
            name: localState.name,
            slot_targets: localState.target,
            slot_types: localState.type,
            slot_colors: localState.color,
            slot_amounts: localState.amount,
            slot_life: localState.life,
            slot_grids: selectionClone(gridSelection),
            slot_assignments: bridge ? bridge.extractor.assignmentList(slotId) : []
        }
        if (actions && actions.editSlot) {
            actions.editSlot(slotId, payload, { origin: "form" })
        }
    }

    function persist() {
        if (!isEditable || !actions || !actions.persistSlot) {
            return
        }
        commit()
        actions.persistSlot(slotId, {
                                 name: localState.name,
                                 slot_targets: localState.target,
                                 slot_types: localState.type,
                                 slot_colors: localState.color,
                                 slot_amounts: localState.amount,
                                 slot_life: localState.life,
                                 slot_grids: selectionClone(gridSelection),
                                 slot_assignments: bridge ? bridge.extractor.assignmentList(slotId) : []
                             }, {
                                 origin: "form",
                                 reason: "manual-save"
                             })
    }

    function resetToStore() {
        refreshFromStore()
    }

    onSlotIdChanged: refreshFromStore()

    onGridSelectionChanged: {
        localState = mergeState(localState, { grid: selectionClone(gridSelection) })
        scheduleCommit()
    }

    Component.onCompleted: refreshFromStore()

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        Label {
            Layout.fillWidth: true
            text: isEditable ? qsTr("Configure Powerup Card") : qsTr("Select a slot to edit its configuration.")
            font.pixelSize: 20
            font.bold: true
            color: "#eef2ff"
            wrapMode: Text.WordWrap
        }

        TextField {
            id: nameField
            Layout.fillWidth: true
            enabled: isEditable
            placeholderText: qsTr("Card name")
            onTextChanged: {
                if (editorForm.isLoading) {
                    return
                }
                editorForm.updateLocal({ name: text })
                editorForm.scheduleCommit()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label {
                    text: qsTr("Target")
                    color: "#9aa9c9"
                    font.pixelSize: 12
                }

                ComboBox {
                    id: targetSelector
                    Layout.fillWidth: true
                    enabled: isEditable
                    model: targetOptions
                    textRole: "text"
                    valueRole: "value"
                    onCurrentValueChanged: {
                        if (editorForm.isLoading) {
                            return
                        }
                        editorForm.updateLocal({ target: currentValue })
                        editorForm.scheduleCommit()
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label {
                    text: qsTr("Type")
                    color: "#9aa9c9"
                    font.pixelSize: 12
                }

                ComboBox {
                    id: typeSelector
                    Layout.fillWidth: true
                    enabled: isEditable
                    model: typeOptions
                    textRole: "text"
                    valueRole: "value"
                    onCurrentValueChanged: {
                        if (editorForm.isLoading) {
                            return
                        }
                        editorForm.updateLocal({ type: currentValue })
                        editorForm.scheduleCommit()
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label {
                    text: qsTr("Color")
                    color: "#9aa9c9"
                    font.pixelSize: 12
                }

                ComboBox {
                    id: colorSelector
                    Layout.fillWidth: true
                    enabled: isEditable
                    model: colorOptions
                    textRole: "text"
                    valueRole: "value"
                    onCurrentValueChanged: {
                        if (editorForm.isLoading) {
                            return
                        }
                        editorForm.updateLocal({ color: currentValue })
                        editorForm.scheduleCommit()
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label {
                    text: qsTr("Damage")
                    color: "#9aa9c9"
                    font.pixelSize: 12
                }

                SpinBox {
                    id: damageSpin
                    Layout.fillWidth: true
                    enabled: isEditable
                    from: -200
                    to: 200
                    stepSize: 1
                    onValueChanged: {
                        if (editorForm.isLoading) {
                            return
                        }
                        editorForm.updateLocal({ amount: value })
                        editorForm.scheduleCommit()
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Label {
                    text: qsTr("Card Life")
                    color: "#9aa9c9"
                    font.pixelSize: 12
                }

                SpinBox {
                    id: lifeSpin
                    Layout.fillWidth: true
                    enabled: isEditable
                    from: 0
                    to: 2000
                    stepSize: 10
                    onValueChanged: {
                        if (editorForm.isLoading) {
                            return
                        }
                        editorForm.updateLocal({ life: value })
                        editorForm.scheduleCommit()
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: qsTr("Grid Coverage")
            color: "#9aa9c9"
            font.pixelSize: 12
        }

        PowerupGridSelector {
            id: gridSelector
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            Layout.maximumHeight: 240
            editable: isEditable
            selection: editorForm.gridSelection
            onSelectionEdited: editorForm.gridSelection = selection
        }

        Frame {
            Layout.fillWidth: true
            padding: 12
            background: Rectangle {
                radius: 10
                color: "#101722"
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 6

                Label {
                    text: qsTr("Activation Energy")
                    color: "#98a6c8"
                    font.pixelSize: 14
                }

                Label {
                    text: computedEnergy
                    color: "#f4f6fb"
                    font.pixelSize: 20
                    font.bold: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                Layout.fillWidth: true
                enabled: isEditable
                text: qsTr("Save")
                onClicked: editorForm.persist()
            }

            Button {
                Layout.fillWidth: true
                enabled: isEditable
                text: qsTr("Reset")
                onClicked: editorForm.resetToStore()
            }
        }
    }

    Connections {
        target: bridge ? bridge.store : null
        ignoreUnknownSignals: true
        onSlotArraysChanged: editorForm.refreshFromStore()
        onSlotAssignmentsChanged: editorForm.refreshFromStore()
        onSlotNamesChanged: editorForm.refreshFromStore()
        onSlotRecordsChanged: editorForm.refreshFromStore()
        onActiveSlotIdChanged: editorForm.refreshFromStore()
    }
}
