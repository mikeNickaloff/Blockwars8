pragma Singleton

import QtQuick 2.15
import QuickFlux 1.1
import "../Blockwars8/actions" as Actions
import "../Blockwars8/models" as Models

Store {
    id: store

    property bool isHydrated: hydrationLifecycle.isHydrated
    property bool isLoading: hydrationLifecycle.isLoading

    property var slotRecords: ({})
    property var slotArrays: ({})
    property var slotAssignments: ([])
    property var slotNames: ([])
    property var slotOrder: ([])
    property int activeSlotId: selectionCoordinator.focusedSlot

    readonly property QtObject tokens: QtObject {
        property string create: Actions.ActionTypes.powerupEditorCreateSlot
        property string edit: Actions.ActionTypes.powerupEditorEditSlot
        property string remove: Actions.ActionTypes.powerupEditorDeleteSlot
        property string open: Actions.ActionTypes.powerupEditorOpenCard
    }

    readonly property QtObject cloning: QtObject {
        function deep(value) {
            if (value === undefined) {
                return undefined
            }
            try {
                return JSON.parse(JSON.stringify(value))
            } catch (error) {
                console.warn("[PowerupEditorStore] Failed to deep clone value:", error)
                return value
            }
        }
    }

    readonly property QtObject schema: QtObject {
        readonly property var canonicalKeys: [
            "slot_grids",
            "slot_targets",
            "slot_types",
            "slot_amounts",
            "slot_colors",
            "slot_energy"
        ]
        property int gridColumns: 6

        function defaultFor(key) {
            switch (key) {
            case "slot_grids":
                return {}
            case "slot_targets":
            case "slot_types":
            case "slot_colors":
                return ""
            case "slot_amounts":
            case "slot_energy":
                return 0
            default:
                return null
            }
        }

        function slotIndex(value) {
            if (value === undefined || value === null || value === "") {
                return null
            }
            if (typeof value === "number") {
                return value < 0 || isNaN(value) ? null : Math.floor(value)
            }
            var parsed = parseInt(value, 10)
            if (isNaN(parsed) || parsed < 0) {
                return null
            }
            return parsed
        }

        function canonicalSlotId(value) {
            var index = slotIndex(value)
            return index === null ? 0 : index
        }

        function canonicalName(slotId, provided) {
            var baseId = canonicalSlotId(slotId)
            if (provided !== undefined && provided !== null) {
                var text = ("" + provided).trim()
                if (text.length > 0) {
                    return text
                }
            }
            return qsTr("Powerup Slot %1").arg(baseId + 1)
        }

        function assignmentsFrom(value) {
            if (value === undefined || value === null) {
                return []
            }
            if (Array.isArray(value)) {
                var list = []
                for (var i = 0; i < value.length; ++i) {
                    if (value[i] === undefined || value[i] === null) {
                        continue
                    }
                    list.push("" + value[i])
                }
                return list
            }
            return ["" + value]
        }

        function numberValue(value, fallback) {
            if (value === undefined || value === null || value === "") {
                return fallback !== undefined ? fallback : 0
            }
            if (typeof value === "number") {
                return isNaN(value) ? (fallback !== undefined ? fallback : 0) : value
            }
            var parsed = parseInt(value, 10)
            if (isNaN(parsed)) {
                return fallback !== undefined ? fallback : 0
            }
            return parsed
        }

        function stringValue(value, fallback) {
            if (value === undefined || value === null) {
                return fallback !== undefined ? fallback : ""
            }
            return "" + value
        }

        function gridIndex(row, column) {
            var resolvedRow = numberValue(row, null)
            var resolvedColumn = numberValue(column, null)
            if (resolvedRow === null || resolvedColumn === null) {
                return -1
            }
            return resolvedColumn + (resolvedRow * gridColumns)
        }

        function gridFromTargets(targets) {
            var grid = {}
            if (!Array.isArray(targets)) {
                return grid
            }
            for (var i = 0; i < targets.length; ++i) {
                var entry = targets[i] || {}
                var index = gridIndex(entry.row, entry.col)
                if (index < 0) {
                    continue
                }
                var selection = entry.selected
                grid[index] = selection === undefined ? true : !!selection
            }
            return grid
        }

        function gridValue(value) {
            if (value === undefined || value === null) {
                return {}
            }
            if (Array.isArray(value)) {
                return gridFromTargets(value)
            }
            if (typeof value === "object") {
                var result = {}
                for (var key in value) {
                    if (!value.hasOwnProperty(key)) {
                        continue
                    }
                    result[key] = !!value[key]
                }
                return result
            }
            return {}
        }

        function alternateValueFor(key, payload) {
            if (!payload) {
                return undefined
            }
            if (key === "slot_grids") {
                if (payload.grid !== undefined) {
                    return payload.grid
                }
                if (payload.data && payload.data.grid !== undefined) {
                    return payload.data.grid
                }
                if (Array.isArray(payload.grid_targets)) {
                    return payload.grid_targets
                }
                if (payload.data && Array.isArray(payload.data.grid_targets)) {
                    return payload.data.grid_targets
                }
                return undefined
            }
            if (key === "slot_targets") {
                if (payload.target !== undefined) {
                    return payload.target
                }
                if (payload.data && payload.data.target !== undefined) {
                    return payload.data.target
                }
                return undefined
            }
            if (key === "slot_types") {
                if (payload.type !== undefined) {
                    return payload.type
                }
                if (payload.data && payload.data.type !== undefined) {
                    return payload.data.type
                }
                return undefined
            }
            if (key === "slot_amounts") {
                if (payload.amount !== undefined) {
                    return payload.amount
                }
                if (payload.data && payload.data.amount !== undefined) {
                    return payload.data.amount
                }
                return undefined
            }
            if (key === "slot_colors") {
                if (payload.color !== undefined) {
                    return payload.color
                }
                if (payload.data && payload.data.color !== undefined) {
                    return payload.data.color
                }
                return undefined
            }
            if (key === "slot_energy") {
                if (payload.energy !== undefined) {
                    return payload.energy
                }
                if (payload.data && payload.data.energy !== undefined) {
                    return payload.data.energy
                }
                return undefined
            }
            return undefined
        }

        function prepareValue(key, value) {
            if (value === undefined || value === null) {
                value = defaultFor(key)
            }
            switch (key) {
            case "slot_grids":
                return gridValue(value)
            case "slot_amounts":
            case "slot_energy":
                return numberValue(value, defaultFor(key))
            case "slot_targets":
            case "slot_types":
            case "slot_colors":
                return stringValue(value, defaultFor(key))
            default:
                return cloning.deep(value)
            }
        }

        function valueFor(key, payload, slotId) {
            if (!payload) {
                return prepareValue(key, undefined)
            }
            var source = payload[key]
            if (Array.isArray(source)) {
                var fromArray = source[slotId]
                if (fromArray !== undefined) {
                    return prepareValue(key, fromArray)
                }
            } else if (source && typeof source === "object" && source.hasOwnProperty && source.hasOwnProperty(slotId)) {
                return prepareValue(key, source[slotId])
            } else if (source !== undefined) {
                return prepareValue(key, source)
            }
            var alternate = alternateValueFor(key, payload)
            if (alternate !== undefined) {
                return prepareValue(key, alternate)
            }
            return prepareValue(key, undefined)
        }
    }

    readonly property QtObject blueprint: QtObject {
        function canonicalState(payload, slotId) {
            var state = {}
            for (var i = 0; i < schema.canonicalKeys.length; ++i) {
                var key = schema.canonicalKeys[i]
                state[key] = schema.valueFor(key, payload, slotId)
            }
            return state
        }

        function canonicalStateFrom(state) {
            var snapshot = {}
            for (var i = 0; i < schema.canonicalKeys.length; ++i) {
                var key = schema.canonicalKeys[i]
                snapshot[key] = schema.prepareValue(key, state ? state[key] : undefined)
            }
            return snapshot
        }

        function compose(slotId, name, assignments, state, data) {
            var resolvedId = schema.canonicalSlotId(slotId)
            return {
                id: resolvedId,
                name: schema.canonicalName(resolvedId, name),
                assignments: schema.assignmentsFrom(assignments),
                state: canonicalStateFrom(state),
                data: cloning.deep(data || {})
            }
        }
    }

    readonly property QtObject persistenceBridge: QtObject {
        readonly property Models.SQLDataStorage storage: Models.SQLDataStorage {
            id: localStorage
            table: "localPowerupData"
            columnDefinitions: ({
                id: "INTEGER PRIMARY KEY",
                name: "TEXT NOT NULL",
                assignments: "TEXT",
                data: "TEXT"
            })
        }

        function readRows() {
            var rows = storage.selectAll()
            return rows || []
        }

        function decodeAssignments(row) {
            if (!row) {
                return []
            }
            if (row.assignments === undefined || row.assignments === null) {
                if (row.slot_assignments !== undefined) {
                    return schema.assignmentsFrom(row.slot_assignments)
                }
                return []
            }
            return schema.assignmentsFrom(storage.fromHex(row.assignments))
        }

        function decodePayload(row) {
            if (!row) {
                return {}
            }
            var encoded = row.data
            if (encoded === undefined || encoded === null) {
                if (row.payload !== undefined) {
                    encoded = row.payload
                } else if (row.record !== undefined) {
                    encoded = row.record
                }
            }
            var decoded = encoded
            if (typeof encoded === "string") {
                decoded = storage.fromHex(encoded)
            }
            if (!decoded || typeof decoded !== "object") {
                decoded = {}
            }
            return decoded
        }
    }

    readonly property QtObject translator: QtObject {
        function slotIdFrom(payload, fallback) {
            var candidates = []
            if (payload) {
                if (payload.slot_id !== undefined && payload.slot_id !== null && payload.slot_id !== "") {
                    candidates.push(payload.slot_id)
                }
                if (payload.slot !== undefined && payload.slot !== null && payload.slot !== "") {
                    candidates.push(payload.slot)
                }
                if (payload.id !== undefined && payload.id !== null && payload.id !== "") {
                    candidates.push(payload.id)
                }
                if (payload.index !== undefined && payload.index !== null && payload.index !== "") {
                    candidates.push(payload.index)
                }
            }
            if (fallback !== undefined && fallback !== null && fallback !== "") {
                candidates.push(fallback)
            }
            for (var i = 0; i < candidates.length; ++i) {
                var candidate = candidates[i]
                var parsed = schema.slotIndex(candidate)
                if (parsed !== null) {
                    return parsed
                }
            }
            return null
        }

        function recordFromPayload(payload, fallbackSlot, metadata) {
            var slotId = slotIdFrom(payload, fallbackSlot)
            var meta = metadata || {}
            var state = blueprint.canonicalState(payload, slotId)
            var resolvedName = payload && payload.name !== undefined ? payload.name : meta.name
            var assignments = payload && payload.slot_assignments !== undefined ? payload.slot_assignments : meta.assignments
            var rawData = payload && payload.data !== undefined ? payload.data : payload
            return blueprint.compose(slotId, resolvedName, assignments, state, rawData)
        }

        function fromAction(payload) {
            if (!payload) {
                return null
            }
            return recordFromPayload(payload, payload.slot_id, { name: payload.name, assignments: payload.slot_assignments })
        }

        function fromPersistence(rows) {
            var results = []
            var dataset = rows || []
            for (var i = 0; i < dataset.length; ++i) {
                var row = dataset[i]
                var decoded = persistenceBridge.decodePayload(row)
                var assignments = persistenceBridge.decodeAssignments(row)
                var slotId = slotIdFrom(decoded, row && (row.id !== undefined ? row.id : row.index))
                var name = row && row.name !== undefined ? row.name : (decoded ? decoded.name : undefined)
                results.push(recordFromPayload(decoded, slotId, { name: name, assignments: assignments }))
            }
            return results
        }

        function fromLegacyMap(source) {
            var results = []
            if (!source) {
                return results
            }
            if (Array.isArray(source)) {
                for (var i = 0; i < source.length; ++i) {
                    var payload = source[i]
                    results.push(recordFromPayload(payload, i, { name: payload ? payload.name : undefined }))
                }
                return results
            }
            if (typeof source === "object") {
                for (var key in source) {
                    if (!source.hasOwnProperty(key)) {
                        continue
                    }
                    var entry = source[key]
                    results.push(recordFromPayload(entry, key, { name: entry ? entry.name : undefined }))
                }
            }
            return results
        }
    }

    readonly property QtObject selectionCoordinator: QtObject {
        property int focusedSlot: -1

        function focus(slotId) {
            var resolved = schema.slotIndex(slotId)
            if (resolved === null) {
                return
            }
            if (focusedSlot === resolved) {
                return
            }
            focusedSlot = resolved
            store.commitState()
        }

        function ensureFocus(order) {
            if (!order || order.length === 0) {
                if (focusedSlot !== -1) {
                    focusedSlot = -1
                }
                return
            }
            if (order.indexOf(focusedSlot) !== -1) {
                return
            }
            var next = order[0]
            if (focusedSlot !== next) {
                focusedSlot = next
            }
        }
    }

    readonly property QtObject stateCoordinator: QtObject {
        property var map: ({})
        property var order: ([])
        property var arraysCache: ({})
        property var assignmentsCache: ([])
        property var namesCache: ([])

        function normalized(record) {
            if (!record) {
                return null
            }
            return blueprint.compose(record.id, record.name, record.assignments, record.state, record.data)
        }

        function adopt(records) {
            var next = {}
            var dataset = records || []
            for (var i = 0; i < dataset.length; ++i) {
                var canonical = normalized(dataset[i])
                if (!canonical) {
                    continue
                }
                next[canonical.id] = canonical
            }
            map = next
            refresh()
        }

        function upsert(record) {
            var canonical = normalized(record)
            if (!canonical) {
                return
            }
            map[canonical.id] = canonical
            refresh()
        }

        function remove(slotId) {
            var resolved = schema.slotIndex(slotId)
            if (resolved === null) {
                return
            }
            if (map.hasOwnProperty(resolved)) {
                delete map[resolved]
            }
            refresh()
        }

        function refresh() {
            var snapshot = aggregator.compose(map)
            order = snapshot.order
            arraysCache = snapshot.canonical
            assignmentsCache = snapshot.assignments
            namesCache = snapshot.names
            selectionCoordinator.ensureFocus(order)
            store.commitState()
        }

        function exportRecords() {
            return cloning.deep(map || {})
        }

        function exportArrays() {
            return cloning.deep(arraysCache || {})
        }

        function exportAssignments() {
            return cloning.deep(assignmentsCache || [])
        }

        function exportNames() {
            return cloning.deep(namesCache || [])
        }

        function exportOrder() {
            return order ? order.slice(0) : []
        }

        readonly property QtObject aggregator: QtObject {
            function compose(sourceMap) {
                var canonical = {}
                var assignments = []
                var names = []
                var order = []
                var highest = -1
                for (var key in sourceMap) {
                    if (!sourceMap.hasOwnProperty(key)) {
                        continue
                    }
                    var record = sourceMap[key]
                    if (!record) {
                        continue
                    }
                    var index = schema.slotIndex(record.id)
                    if (index === null) {
                        continue
                    }
                    if (order.indexOf(index) === -1) {
                        order.push(index)
                    }
                    if (index > highest) {
                        highest = index
                    }
                }
                order.sort(function (a, b) { return a - b })
                for (var i = 0; i < schema.canonicalKeys.length; ++i) {
                    canonical[schema.canonicalKeys[i]] = []
                }
                for (var slot = 0; slot <= highest; ++slot) {
                    for (var j = 0; j < schema.canonicalKeys.length; ++j) {
                        var keyName = schema.canonicalKeys[j]
                        canonical[keyName][slot] = schema.prepareValue(keyName, undefined)
                    }
                    assignments[slot] = []
                    names[slot] = schema.canonicalName(slot, null)
                }
                for (var orderIndex = 0; orderIndex < order.length; ++orderIndex) {
                    var slotId = order[orderIndex]
                    var recordForSlot = sourceMap[slotId]
                    if (!recordForSlot) {
                        continue
                    }
                    for (var k = 0; k < schema.canonicalKeys.length; ++k) {
                        var canonicalKey = schema.canonicalKeys[k]
                        canonical[canonicalKey][slotId] = schema.prepareValue(canonicalKey, recordForSlot.state[canonicalKey])
                    }
                    assignments[slotId] = schema.assignmentsFrom(recordForSlot.assignments)
                    names[slotId] = recordForSlot.name
                }
                return {
                    canonical: canonical,
                    assignments: assignments,
                    names: names,
                    order: order
                }
            }
        }
    }

    readonly property QtObject hydrationLifecycle: QtObject {
        property bool isHydrated: false
        property bool isLoading: false

        function bootstrap() {
            if (isHydrated) {
                return
            }
            isLoading = true
            var rows = persistenceBridge.readRows()
            var records = translator.fromPersistence(rows)
            stateCoordinator.adopt(records)
            isHydrated = true
            isLoading = false
            if (!stateCoordinator.order || stateCoordinator.order.length === 0) {
                selectionCoordinator.focus(-1)
            }
        }
    }

    readonly property QtObject mutationCoordinator: QtObject {
        function ingest(payload) {
            var record = translator.fromAction(payload)
            if (!record) {
                return
            }
            stateCoordinator.upsert(record)
            selectionCoordinator.focus(record.id)
        }

        function update(payload) {
            var record = translator.fromAction(payload)
            if (!record) {
                return
            }
            stateCoordinator.upsert(record)
        }

        function remove(payload) {
            var slotId = translator.slotIdFrom(payload)
            if (slotId === null) {
                return
            }
            stateCoordinator.remove(slotId)
        }

        function open(payload) {
            var slotId = translator.slotIdFrom(payload)
            if (slotId === null) {
                return
            }
            selectionCoordinator.focus(slotId)
        }
    }

    AppListener {
        filter: tokens.create
        onDispatched: function (type, payload) {
            mutationCoordinator.ingest(payload)
        }
    }

    AppListener {
        filter: tokens.edit
        onDispatched: function (type, payload) {
            mutationCoordinator.update(payload)
        }
    }

    AppListener {
        filter: tokens.remove
        onDispatched: function (type, payload) {
            mutationCoordinator.remove(payload)
        }
    }

    AppListener {
        filter: tokens.open
        onDispatched: function (type, payload) {
            mutationCoordinator.open(payload)
        }
    }

    function commitState() {
        slotRecords = stateCoordinator.exportRecords()
        slotArrays = stateCoordinator.exportArrays()
        slotAssignments = stateCoordinator.exportAssignments()
        slotNames = stateCoordinator.exportNames()
        slotOrder = stateCoordinator.exportOrder()
        activeSlotId = selectionCoordinator.focusedSlot
    }

    Component.onCompleted: hydrationLifecycle.bootstrap()
}
