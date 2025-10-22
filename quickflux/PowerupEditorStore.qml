pragma Singleton

import QtQuick 2.15
import QuickFlux 1.1
import "../Blockwars8/actions" as Actions
import "../Blockwars8/models" as Models

Store {
    id: store

    property bool isHydrated: hydrationLifecycle.isHydrated
    property bool isLoading: hydrationLifecycle.isLoading

    property bool isEditorVisible: false
    property var visibilityDirective: ({})
    property var persistenceQueue: ([])
    property var lastPersistenceRequest: null
    property bool hasPendingPersistence: false

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
        property string show: Actions.ActionTypes.powerupEditorShowDialog
        property string hide: Actions.ActionTypes.powerupEditorHideDialog
        property string persist: Actions.ActionTypes.powerupEditorPersistSlot
    }

    readonly property QtObject dispatcherMetadata: QtObject {
        function lifecycleFrom(actionKey) {
            if (!actionKey) {
                return ""
            }
            var tokens = actionKey.split(".")
            return tokens.length > 0 ? tokens[tokens.length - 1] : actionKey
        }

        function namespaceFrom(payload) {
            if (payload && payload.namespace !== undefined) {
                return payload.namespace
            }
            return Actions.ActionTypes.powerupEditorNamespace
        }

        function directive(actionKey, payload) {
            var descriptor = {}
            descriptor.namespace = namespaceFrom(payload)
            var lifecycle = payload && payload.lifecycle !== undefined
                    ? payload.lifecycle
                    : lifecycleFrom(actionKey)
            if (lifecycle && lifecycle.length > 0) {
                descriptor.lifecycle = lifecycle
            }
            var slotId = translator.slotIdFrom(payload)
            if (slotId !== null) {
                descriptor.slotId = slotId
            }
            if (payload) {
                if (payload.origin !== undefined) {
                    descriptor.origin = payload.origin
                }
                if (payload.reason !== undefined) {
                    descriptor.reason = payload.reason
                }
                if (payload.source !== undefined) {
                    descriptor.source = payload.source
                }
            }
            return descriptor
        }
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

    readonly property QtObject visibilityCoordinator: QtObject {
        property bool isVisible: false
        property var directive: ({})

        readonly property QtObject extractor: QtObject {
            function fromAction(actionKey, payload) {
                var descriptor = dispatcherMetadata.directive(actionKey, payload)
                descriptor.timestamp = Date.now()
                return descriptor
            }

            function fromMetadata(metadata) {
                var meta = metadata || {}
                var descriptor = {}
                var namespace = meta.namespace !== undefined
                        ? meta.namespace
                        : Actions.ActionTypes.powerupEditorNamespace
                descriptor.namespace = namespace
                if (meta.lifecycle !== undefined) {
                    descriptor.lifecycle = meta.lifecycle
                }
                if (meta.slotId !== undefined) {
                    descriptor.slotId = meta.slotId
                }
                if (meta.origin !== undefined) {
                    descriptor.origin = meta.origin
                }
                if (meta.reason !== undefined) {
                    descriptor.reason = meta.reason
                }
                if (meta.source !== undefined) {
                    descriptor.source = meta.source
                }
                descriptor.timestamp = Date.now()
                return descriptor
            }
        }

        function showFrom(actionKey, payload) {
            apply(true, extractor.fromAction(actionKey, payload))
        }

        function hideFrom(actionKey, payload) {
            apply(false, extractor.fromAction(actionKey, payload))
        }

        function show(metadata) {
            apply(true, extractor.fromMetadata(metadata))
        }

        function hide(metadata) {
            apply(false, extractor.fromMetadata(metadata))
        }

        function apply(visible, descriptor) {
            isVisible = visible
            directive = cloning.deep(descriptor || {})
            store.commitVisibility()
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

        function payload(record) {
            if (!record) {
                return null
            }
            var canonicalId = schema.canonicalSlotId(record.id)
            var canonicalName = schema.canonicalName(canonicalId, record.name)
            var preparedState = canonicalStateFrom(record.state)
            var payload = {
                slot_id: canonicalId,
                name: canonicalName,
                slot_assignments: schema.assignmentsFrom(record.assignments),
                data: cloning.deep(record.data || {})
            }
            for (var i = 0; i < schema.canonicalKeys.length; ++i) {
                var keyName = schema.canonicalKeys[i]
                payload[keyName] = cloning.deep(preparedState[keyName])
            }
            return payload
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

        readonly property QtObject encoder: QtObject {
            function assignments(value) {
                return storage.toHex(schema.assignmentsFrom(value))
            }

            function payload(payloadObject) {
                var normalized = payloadObject || {}
                return storage.toHex(normalized)
            }
        }

        readonly property QtObject rowComposer: QtObject {
            function fromRecord(record) {
                if (!record) {
                    return null
                }
                var slotId = schema.slotIndex(record.id)
                if (slotId === null) {
                    return null
                }
                var canonicalName = schema.canonicalName(slotId, record.name)
                var payloadSnapshot = blueprint.payload(record)
                return {
                    id: slotId,
                    name: canonicalName,
                    assignments: encoder.assignments(record.assignments),
                    data: encoder.payload(payloadSnapshot)
                }
            }

            function fromMap(map) {
                var rows = []
                if (!map) {
                    return rows
                }
                for (var key in map) {
                    if (!map.hasOwnProperty(key)) {
                        continue
                    }
                    var candidate = map[key]
                    var row = fromRecord(candidate)
                    if (!row) {
                        continue
                    }
                    rows.push(row)
                }
                rows.sort(function (a, b) { return a.id - b.id })
                return rows
            }
        }

        function writeMap(recordMap) {
            var rows = rowComposer.fromMap(recordMap)
            return storage.replaceAll(rows)
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

    readonly property QtObject persistenceLifecycle: QtObject {
        property bool isProcessing: false

        function synchronize() {
            var lastSnapshot = cloning.deep(persistenceCoordinator.lastRequest)
            if (isProcessing || !hydrationLifecycle.isHydrated || !persistenceCoordinator.hasPending) {
                return { processed: false, lastRequest: lastSnapshot }
            }
            isProcessing = true
            var recordsMap = stateCoordinator.exportRecords()
            var outcome = persistenceBridge.writeMap(recordsMap)
            if (!outcome && outcome !== undefined) {
                console.warn("[PowerupEditorStore] Persistence replaceAll returned unexpected result", outcome)
            }
            persistenceCoordinator.queue = []
            persistenceCoordinator.hasPending = false
            persistenceCoordinator.lastRequest = lastSnapshot
            isProcessing = false
            return { processed: true, lastRequest: lastSnapshot }
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

    readonly property QtObject persistenceCoordinator: QtObject {
        property var queue: ([])
        property var lastRequest: null
        property bool hasPending: false

        readonly property QtObject contract: QtObject {
            function fromAction(actionKey, payload) {
                var record = translator.fromAction(payload)
                var fallbackId = translator.slotIdFrom(payload)
                if (!record && fallbackId !== null) {
                    record = blueprint.compose(fallbackId, payload ? payload.name : undefined, payload ? payload.slot_assignments : undefined, payload, payload ? payload.data : undefined)
                }
                if (!record) {
                    return null
                }
                var descriptor = dispatcherMetadata.directive(actionKey, payload)
                var payloadSnapshot = snapshotFromRecord(record)
                if (!payloadSnapshot) {
                    return null
                }
                return finalize(descriptor, payloadSnapshot)
            }

            function snapshotFromRecord(record) {
                if (!record) {
                    return null
                }
                var snapshot = {
                    slot_id: record.id,
                    name: record.name,
                    slot_assignments: cloning.deep(record.assignments || []),
                    data: cloning.deep(record.data || {})
                }
                for (var i = 0; i < schema.canonicalKeys.length; ++i) {
                    var key = schema.canonicalKeys[i]
                    snapshot[key] = cloning.deep(record.state ? record.state[key] : undefined)
                }
                return snapshot
            }

            function finalize(directive, payloadSnapshot) {
                var descriptor = cloning.deep(directive || {})
                descriptor.timestamp = Date.now()
                return {
                    namespace: descriptor.namespace || Actions.ActionTypes.powerupEditorNamespace,
                    lifecycle: descriptor.lifecycle || "",
                    slotId: descriptor.slotId !== undefined ? descriptor.slotId : payloadSnapshot.slot_id,
                    directive: descriptor,
                    payload: payloadSnapshot
                }
            }
        }

        function capture(actionKey, payload) {
            var entry = contract.fromAction(actionKey, payload)
            if (!entry) {
                return
            }
            queue = queue.concat([entry])
            lastRequest = entry
            hasPending = queue.length > 0
            store.commitPersistence()
        }

        function clear() {
            queue = []
            lastRequest = null
            hasPending = false
            store.commitPersistence()
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
            if (persistenceCoordinator.hasPending) {
                persistenceLifecycle.synchronize()
                store.commitPersistence()
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
            persistenceCoordinator.capture(type, payload)
            visibilityCoordinator.showFrom(type, payload)
        }
    }

    AppListener {
        filter: tokens.edit
        onDispatched: function (type, payload) {
            mutationCoordinator.update(payload)
            persistenceCoordinator.capture(type, payload)
            visibilityCoordinator.showFrom(type, payload)
        }
    }

    AppListener {
        filter: tokens.remove
        onDispatched: function (type, payload) {
            mutationCoordinator.remove(payload)
            persistenceCoordinator.capture(type, payload)
        }
    }

    AppListener {
        filter: tokens.open
        onDispatched: function (type, payload) {
            mutationCoordinator.open(payload)
            visibilityCoordinator.showFrom(type, payload)
        }
    }

    AppListener {
        filter: tokens.show
        onDispatched: function (type, payload) {
            visibilityCoordinator.showFrom(type, payload)
        }
    }

    AppListener {
        filter: tokens.hide
        onDispatched: function (type, payload) {
            visibilityCoordinator.hideFrom(type, payload)
        }
    }

    AppListener {
        filter: tokens.persist
        onDispatched: function (type, payload) {
            persistenceCoordinator.capture(type, payload)
        }
    }

    function commitVisibility() {
        isEditorVisible = visibilityCoordinator.isVisible
        visibilityDirective = cloning.deep(visibilityCoordinator.directive || {})
    }

    function commitPersistence() {
        var summary = persistenceLifecycle.synchronize()
        persistenceQueue = cloning.deep(persistenceCoordinator.queue || [])
        var lastSnapshot = summary && summary.lastRequest !== undefined
                ? summary.lastRequest
                : cloning.deep(persistenceCoordinator.lastRequest)
        lastPersistenceRequest = cloning.deep(lastSnapshot)
        hasPendingPersistence = !!persistenceCoordinator.hasPending
    }

    function commitState() {
        slotRecords = stateCoordinator.exportRecords()
        slotArrays = stateCoordinator.exportArrays()
        slotAssignments = stateCoordinator.exportAssignments()
        slotNames = stateCoordinator.exportNames()
        slotOrder = stateCoordinator.exportOrder()
        activeSlotId = selectionCoordinator.focusedSlot
    }

    readonly property QtObject initializationCoordinator: QtObject {
        function start() {
            commitPersistence()
            commitVisibility()
            hydrationLifecycle.bootstrap()
            visibilityCoordinator.show({ reason: "bootstrap" })
        }
    }

    Component.onCompleted: initializationCoordinator.start()
}
