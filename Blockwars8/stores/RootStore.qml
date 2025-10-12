import QtQuick 2.0
import QuickFlux 1.1
import QtQuick.LocalStorage 2.15

Store {
    id: rootStore
    property string text: ""
    property var my_powerup_data: {
        "0": {
            "slot": 0,
            "target": "opponent_grid",
            "amount": 9,
            "hero_targets": 1,
            "grid_targets": [{
                    "row": 0,
                    "col": 1,
                    "selected": false
                }, {
                    "row": 0,
                    "col": 1,
                    "selected": true
                }]
        },
        "1": {
            "slot": 1,
            "target": "grid",
            "amount": 7,
            "hero_targets": 1,
            "grid_targets": [{
                    "row": 0,
                    "col": 1,
                    "selected": false
                }]
        },
        "2": {
            "slot": 2,
            "target": "grid",
            "amount": 9,
            "hero_targets": 1,
            "grid_targets": [{
                    "row": 0,
                    "col": 1,
                    "selected": true
                }, {
                    "row": 2,
                    "col": 0,
                    "selected": true
                }]
        },
        "3": {
            "slot": 3,
            "target": "opponent_grid",
            "amount": 9,
            "hero_targets": 1,
            "grid_targets": [{
                    "row": 0,
                    "col": 1,
                    "selected": true
                }, {
                    "row": 2,
                    "col": 0,
                    "selected": true
                }, {
                    "row": 2,
                    "col": 0,
                    "selected": true
                }, {
                    "row": 2,
                    "col": 5,
                    "selected": true
                }]
        }
    }
    property var enemy_powerup_data: [{
            "amount": 25,
            "color": "green",
            "energy": 450,
            "grid": {
                "0": false,
                "1": true,
                "10": true,
                "11": false,
                "12": false,
                "13": true,
                "14": false,
                "15": true,
                "16": false,
                "17": true,
                "18": true,
                "19": false,
                "2": false,
                "20": true,
                "21": false,
                "22": true,
                "23": false,
                "24": false,
                "25": true,
                "26": false,
                "27": true,
                "28": false,
                "29": true,
                "3": true,
                "30": true,
                "31": false,
                "32": true,
                "33": false,
                "34": true,
                "35": false,
                "4": false,
                "5": true,
                "6": true,
                "7": false,
                "8": true,
                "9": false
            },
            "target": "opponent",
            "type": "blocks"
        }, {
            "amount": 16,
            "color": "blue",
            "energy": 256,
            "grid": {
                "1": true,
                "14": true,
                "15": true,
                "2": true,
                "20": true,
                "21": true,
                "26": true,
                "27": true,
                "3": true,
                "31": true,
                "32": true,
                "33": true,
                "34": true,
                "4": true,
                "8": true,
                "9": true
            },
            "target": "opponent",
            "type": "blocks"
        }, {
            "amount": 11,
            "color": "yellow",
            "energy": 220,
            "grid": {
                "0": true,
                "1": true,
                "10": true,
                "13": true,
                "14": false,
                "15": false,
                "16": true,
                "19": true,
                "2": true,
                "22": true,
                "25": true,
                "28": true,
                "3": true,
                "30": true,
                "31": true,
                "32": true,
                "33": true,
                "34": true,
                "35": true,
                "4": true,
                "5": true,
                "7": true
            },
            "target": "self",
            "type": "blocks"
        }, {
            "amount": 26,
            "color": "red",
            "energy": 520,
            "grid": {
                "0": true,
                "1": false,
                "10": true,
                "11": true,
                "12": true,
                "13": true,
                "14": false,
                "15": false,
                "16": true,
                "17": true,
                "18": true,
                "19": true,
                "20": false,
                "21": false,
                "22": true,
                "23": true,
                "24": true,
                "25": true,
                "28": true,
                "29": true,
                "30": true,
                "31": false,
                "34": false,
                "35": true,
                "4": false,
                "5": true,
                "6": true,
                "7": true
            },
            "target": "self",
            "type": "blocks"
        }]

    property var default_powerup_library: []
    property var single_player_selected_powerups: {
        "0": null,
        "1": null,
        "2": null,
        "3": null
    }
    property bool single_player_selection_ready: false
    property var single_player_dashboard_data: {
        "0": null,
        "1": null
    }
    property var single_player_dashboard_ready: {
        "0": false,
        "1": false
    }
    property var powerup_runtime_state: {
        "0": { "grid_id": 0, "slots": {} },
        "1": { "grid_id": 1, "slots": {} }
    }
    property var player_health: {
        "0": 2000,
        "1": 2000
    }

    Component.onCompleted: {
        loadPowerupData()
        loadDefaultPowerups()
        resetSinglePlayerSelectionState()
    }
    /* database */
    function loadDatabase() {
        return
    }

    function loadPowerupData() {
        var db = LocalStorage.openDatabaseSync("block.wars", "1.0",
                                               "Block Wars User Settings",
                                               1000000)
        db.transaction(function (tx) {
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS powerup_data(slot numeric, target text, hero_targets numeric, amount numeric, grid_targets text)')
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS powerup_data_v2(slot integer primary key, data text)')

            var updatedData = {}
            var rsV2 = tx.executeSql('SELECT slot, data FROM powerup_data_v2 ORDER BY slot')
            if (rsV2 && rsV2.rows && rsV2.rows.length > 0) {
                for (var i = 0; i < rsV2.rows.length; ++i) {
                    var row = rsV2.rows.item(i)
                    var parsed = {}
                    try {
                        parsed = JSON.parse(row.data)
                    } catch (err) {
                        parsed = {}
                    }
                    updatedData[row.slot] = normalizePowerupObject(parsed, row.slot)
                }
                my_powerup_data = updatedData
                return
            }

            var rs = tx.executeSql('SELECT slot,target,hero_targets,amount,grid_targets FROM powerup_data ORDER BY slot')
            if (rs && rs.rows && rs.rows.length > 0) {
                for (var j = 0; j < rs.rows.length; ++j) {
                    var rowLegacy = rs.rows.item(j)
                    var raw = {
                        "slot": rowLegacy.slot,
                        "target": rowLegacy.target,
                        "hero_targets": rowLegacy.hero_targets,
                        "amount": rowLegacy.amount
                    }
                    if (rowLegacy.grid_targets !== undefined && rowLegacy.grid_targets !== null) {
                        var parsedGrid = rowLegacy.grid_targets
                        if (typeof parsedGrid === 'string') {
                            try {
                                parsedGrid = JSON.parse(parsedGrid)
                            } catch (err2) {
                                parsedGrid = rowLegacy.grid_targets
                            }
                        }
                        raw.grid_targets = parsedGrid
                    }
                    updatedData[rowLegacy.slot] = normalizePowerupObject(raw, rowLegacy.slot)
                }
                my_powerup_data = updatedData
            }
        })
    }

    function savePowerupData() {
        var db = LocalStorage.openDatabaseSync("block.wars", "1.0",
                                               "Block Wars User Settings",
                                               1000000)

        db.transaction(function (tx) {
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS powerup_data(slot numeric primary key, target text, hero_targets numeric, amount numeric, grid_targets text)')
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS powerup_data_v2(slot integer primary key, data text)')
            tx.executeSql('DELETE FROM powerup_data')
            tx.executeSql('DELETE FROM powerup_data_v2')

            var refreshed = {}
            var keys = Object.keys(my_powerup_data)
            for (var i = 0; i < keys.length; ++i) {
                var key = keys[i]
                var normalized = normalizePowerupObject(my_powerup_data[key], parseInt(key, 10))
                refreshed[normalized.slot] = normalized
                tx.executeSql(
                            'INSERT OR REPLACE INTO powerup_data(slot, target, hero_targets, amount, grid_targets) VALUES (?, ?, ?, ?, ?)',
                            [normalized.slot, normalized.target, normalized.hero_targets, normalized.amount, compressData(
                                 normalized.grid_targets)])
                tx.executeSql(
                            'INSERT OR REPLACE INTO powerup_data_v2(slot, data) VALUES (?, ?)',
                            [normalized.slot, JSON.stringify(normalized)])
            }
            my_powerup_data = refreshed
        })
    }

    function emptyGridTargets() {
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

    function expandGridTargets(source) {
        var arr = emptyGridTargets()
        if (source === null || source === undefined) {
            return arr
        }

        if (typeof source === 'string') {
            for (var i = 0; i < arr.length && i < source.length; ++i) {
                arr[i].selected = source.charAt(i) === '1'
            }
            return arr
        }

        if (Array.isArray(source)) {
            for (var i = 0; i < source.length; ++i) {
                var cell = source[i]
                if (cell === undefined || cell === null) {
                    continue
                }
                var row = Math.floor(i / 6)
                var col = i % 6
                var selected = false
                if (Array.isArray(cell)) {
                    row = cell.length > 0 ? cell[0] : row
                    col = cell.length > 1 ? cell[1] : col
                    selected = cell.length > 2 ? cell[2] === true : true
                } else {
                    if (cell.row !== undefined) {
                        row = cell.row
                    }
                    if (cell.col !== undefined) {
                        col = cell.col
                    }
                    if (cell.selected !== undefined) {
                        selected = cell.selected === true
                    } else if (cell === true) {
                        selected = true
                    }
                }
                var idx = row * 6 + col
                if (idx >= 0 && idx < arr.length) {
                    arr[idx].row = row
                    arr[idx].col = col
                    arr[idx].selected = selected
                }
            }
            return arr
        }

        if (typeof source === 'object') {
            for (var key in source) {
                if (!source.hasOwnProperty(key)) {
                    continue
                }
                var idx = parseInt(key, 10)
                if (isNaN(idx)) {
                    continue
                }
                if (source[key]) {
                    var rowObj = Math.floor(idx / 6)
                    var colObj = idx % 6
                    var mapped = rowObj * 6 + colObj
                    if (mapped >= 0 && mapped < arr.length) {
                        arr[mapped].row = rowObj
                        arr[mapped].col = colObj
                        arr[mapped].selected = true
                    }
                }
            }
        }
        return arr
    }

    function compressData(grid_targets) {
        var arr = expandGridTargets(grid_targets)
        var result = ""
        for (var i = 0; i < arr.length; ++i) {
            result += arr[i].selected ? "1" : "0"
        }
        return result
    }

    function normalizePowerupObject(raw, slotOverride) {
        var normalized = {
            "slot": slotOverride !== undefined && !isNaN(slotOverride) ? slotOverride : 0,
            "target": "opponent",
            "type": "blocks",
            "color": "red",
            "amount": 1,
            "hero_targets": 0,
            "grid_targets": emptyGridTargets()
        }

        if (!raw) {
            return normalized
        }

        if (raw.slot !== undefined && !isNaN(raw.slot)) {
            normalized.slot = raw.slot
        }
        if (raw.target !== undefined) {
            normalized.target = ("" + raw.target).toLowerCase()
        }
        if (raw.type !== undefined) {
            normalized.type = ("" + raw.type).toLowerCase()
        }
        if (raw.color !== undefined) {
            normalized.color = ("" + raw.color).toLowerCase()
        }
        if (raw.amount !== undefined) {
            normalized.amount = raw.amount
        }
        if (raw.hero_targets !== undefined) {
            normalized.hero_targets = raw.hero_targets
        }
        if (raw.energy !== undefined) {
            normalized.energy = raw.energy
        }

        if (normalized.target !== "self") {
            normalized.target = "opponent"
        }
        if (normalized.type === "hero" || normalized.type === "heroes") {
            normalized.type = "heros"
        } else if (normalized.type !== "blocks" && normalized.type !== "heros" && normalized.type !== "health") {
            normalized.type = "blocks"
        }

        if (raw.grid_targets !== undefined) {
            normalized.grid_targets = expandGridTargets(raw.grid_targets)
        } else if (raw.grid !== undefined) {
            normalized.grid_targets = expandGridTargets(raw.grid)
        } else if (raw.targets !== undefined) {
            normalized.grid_targets = expandGridTargets(raw.targets)
        }

        return normalized
    }

    function cloneSelectionMap(source) {
        var result = {
            "0": null,
            "1": null,
            "2": null,
            "3": null
        }
        if (source) {
            for (var key in result) {
                if (source.hasOwnProperty(key)) {
                    result[key] = source[key]
                }
            }
        }
        return result
    }

    function resetSinglePlayerSelectionState() {
        single_player_selected_powerups = cloneSelectionMap()
        single_player_selection_ready = false
        single_player_dashboard_data = {
            "0": null,
            "1": null
        }
        single_player_dashboard_ready = {
            "0": false,
            "1": false
        }
    }

    function createSelectionPowerup(raw, slotOverride, sourceName) {
        var normalized = normalizePowerupObject(raw, slotOverride !== undefined ? slotOverride : (raw && raw.slot !== undefined ? raw.slot : 0))
        var result = {}
        for (var key in normalized) {
            if (normalized.hasOwnProperty(key)) {
                result[key] = normalized[key]
            }
        }
        result.slot = slotOverride !== undefined ? slotOverride : result.slot
        result.source = sourceName || (raw && raw.source !== undefined ? raw.source : "player")
        if (raw && raw.displayName !== undefined) {
            result.displayName = raw.displayName
        } else if (raw && raw.name !== undefined) {
            result.displayName = raw.name
        } else if (result.source === "default") {
            result.displayName = "Default Powerup " + (result.slot + 1)
        } else {
            result.displayName = "Custom Powerup " + (result.slot + 1)
        }
        return result
    }

    function runtimeSlotState(gridId, slotId) {
        var gridKey = String(gridId)
        if (!powerup_runtime_state.hasOwnProperty(gridKey)) {
            powerup_runtime_state[gridKey] = { "grid_id": gridId, "slots": {} }
        }
        var gridState = powerup_runtime_state[gridKey]
        var slotKey = String(slotId)
        if (!gridState.slots.hasOwnProperty(slotKey)) {
            gridState.slots[slotKey] = {
                "slot": slotId,
                "energy": 0,
                "maxEnergy": 0,
                "ready": false,
                "color": "red",
                "deployed": false,
                "displayName": "Powerup",
                "gridTargets": [],
                "amount": 0,
                "type": "blocks",
                "target": "opponent",
                "position": null,
                "health": 0
            }
        }
        return gridState.slots[slotKey]
    }

    function updateRuntimePowerups(gridId) {
        var selections = gridId === 0 ? collectCpuDashboardPowerups() : collectDashboardPowerupsFromSelections()
        var gridKey = String(gridId)
        if (!powerup_runtime_state.hasOwnProperty(gridKey)) {
            powerup_runtime_state[gridKey] = { "grid_id": gridId, "slots": {} }
        }
        var gridState = powerup_runtime_state[gridKey]
        var slotsObj = {}
        for (var i = 0; i < selections.length; ++i) {
            var p = selections[i]
            var slotId = p.slot !== undefined ? p.slot : i
            var slotState = runtimeSlotState(gridId, slotId)
            slotState.grid_id = gridId
            slotState.slot = slotId
            slotState.displayName = p.displayName || (p.source === "default" ? ("Default Powerup " + (slotId + 1)) : ("Custom Powerup " + (slotId + 1)))
            slotState.color = p.color || "red"
            slotState.maxEnergy = p.energy !== undefined ? p.energy : 100
            slotState.gridTargets = p.grid_targets || []
            slotState.type = p.type || "blocks"
            slotState.target = p.target || "opponent"
            slotState.amount = p.amount !== undefined ? p.amount : 0
            if (slotState.energy > slotState.maxEnergy) {
                slotState.energy = slotState.maxEnergy
            }
            slotState.ready = slotState.energy >= slotState.maxEnergy
            if (slotState.deployed !== true) {
                slotState.position = null
            }
            slotsObj[String(slotId)] = slotState
        }
        gridState.slots = slotsObj
        powerup_runtime_state[gridKey] = gridState
        publishRuntimeState()
    }

    function ensureRuntimeInitialized() {
        updateRuntimePowerups(0)
        updateRuntimePowerups(1)
    }

    function publishRuntimeState() {
        var clone = {}
        for (var key in powerup_runtime_state) {
            if (!powerup_runtime_state.hasOwnProperty(key)) {
                continue
            }
            clone[key] = JSON.parse(JSON.stringify(powerup_runtime_state[key]))
        }
        powerup_runtime_state = clone
    }

    function loadDefaultPowerups() {
        var seeds = [
            { "slot": 0, "target": "opponent", "type": "blocks", "color": "red", "amount": 5, "grid_targets": [[0, 1, true], [0, 2, true], [0, 3, true]], "displayName": "Fire Line" },
            { "slot": 1, "target": "opponent", "type": "blocks", "color": "blue", "amount": 6, "grid_targets": [[1, 2, true], [1, 3, true], [1, 4, true]], "displayName": "Frost Sweep" },
            { "slot": 2, "target": "self", "type": "blocks", "color": "green", "amount": 4, "grid_targets": [[2, 2, true], [2, 3, true], [3, 2, true], [3, 3, true]], "displayName": "Nature Shield" },
            { "slot": 3, "target": "self", "type": "blocks", "color": "yellow", "amount": 3, "grid_targets": [[4, 1, true], [4, 2, true], [4, 3, true]], "displayName": "Solar Refill" },
            { "slot": 4, "target": "opponent", "type": "blocks", "color": "green", "amount": 7, "grid_targets": [[0, 5, true], [1, 5, true], [2, 5, true]], "displayName": "Vine Snare" },
            { "slot": 5, "target": "opponent", "type": "blocks", "color": "yellow", "amount": 8, "grid_targets": [[0, 0, true], [1, 0, true], [2, 0, true]], "displayName": "Solar Lance" },
            { "slot": 6, "target": "self", "type": "blocks", "color": "blue", "amount": 4, "grid_targets": [[5, 2, true], [4, 2, true], [3, 2, true]], "displayName": "Glacier Guard" },
            { "slot": 7, "target": "opponent", "type": "blocks", "color": "red", "amount": 9, "grid_targets": [[2, 0, true], [2, 1, true], [2, 2, true], [2, 3, true]], "displayName": "Ember Barrage" },
            { "slot": 8, "target": "self", "type": "blocks", "color": "yellow", "amount": 5, "grid_targets": [[5, 3, true], [5, 4, true], [5, 5, true]], "displayName": "Radiant Bloom" },
            { "slot": 9, "target": "opponent", "type": "blocks", "color": "blue", "amount": 10, "grid_targets": [[0, 4, true], [1, 4, true], [2, 4, true], [3, 4, true]], "displayName": "Tidal Crush" }
        ]
        var converted = []
        for (var i = 0; i < seeds.length; ++i) {
            var seed = seeds[i]
            var convertedPowerup = createSelectionPowerup(seed, seed.slot !== undefined ? seed.slot : i, "default")
            converted.push(convertedPowerup)
        }
        default_powerup_library = converted
    }

    function getPlayerPowerupsAsList() {
        var list = []
        if (my_powerup_data) {
            for (var slot in my_powerup_data) {
                if (my_powerup_data.hasOwnProperty(slot)) {
                    var raw = my_powerup_data[slot]
                    var normalized = createSelectionPowerup(raw, parseInt(slot, 10), "player")
                    list.push(normalized)
                }
            }
        }
        list.sort(function (a, b) {
            return a.slot - b.slot
        })
        return list
    }

    function getDefaultPowerupsAsList() {
        return default_powerup_library
    }

    function getSinglePlayerSelections() {
        return single_player_selected_powerups
    }

    function collectDashboardPowerupsFromSelections() {
        var list = []
        for (var i = 0; i < 4; ++i) {
            var key = i.toString()
            if (single_player_selected_powerups.hasOwnProperty(key)) {
                var entry = single_player_selected_powerups[key]
                if (entry) {
                    list.push(createSelectionPowerup(entry, i, entry.source || "player"))
                }
            }
        }
        list.sort(function (a, b) {
            return a.slot - b.slot
        })
        return list
    }

    function collectCpuDashboardPowerups() {
        var defaults = getDefaultPowerupsAsList()
        var list = []
        for (var i = 0; i < 4 && i < defaults.length; ++i) {
            var entry = defaults[i]
            list.push(createSelectionPowerup(entry, i, "default"))
        }
        return list
    }

    function prepareSinglePlayerDashboards() {
        var cpuPowerups = collectCpuDashboardPowerups()
        var playerPowerups = collectDashboardPowerupsFromSelections()
        powerup_runtime_state = {
            "0": { "grid_id": 0, "slots": {} },
            "1": { "grid_id": 1, "slots": {} }
        }
        player_health = {
            "0": 2000,
            "1": 2000
        }
        single_player_dashboard_data = {
            "0": {
                "grid_id": 0,
                "role": "cpu",
                "powerups": cpuPowerups
            },
            "1": {
                "grid_id": 1,
                "role": "player",
                "powerups": playerPowerups
            }
        }
        single_player_dashboard_ready = {
            "0": false,
            "1": false
        }
        updateRuntimePowerups(0)
        updateRuntimePowerups(1)
    }

    AppListener {
        filter: "singlePlayerSelectionReset"
        onDispatched: function (type, message) {
            resetSinglePlayerSelectionState()
        }
    }

    AppListener {
        filter: "singlePlayerSelectionSet"
        onDispatched: function (type, message) {
            if (!message || message.slot === undefined) {
                return
            }
            var slot = parseInt(message.slot, 10)
            if (isNaN(slot) || slot < 0 || slot > 3) {
                return
            }
            var updated = cloneSelectionMap(single_player_selected_powerups)
            if (message.powerup === null) {
                updated[slot] = null
                single_player_selected_powerups = updated
                single_player_selection_ready = false
                return
            }
            var normalized = createSelectionPowerup(message.powerup, slot, message.source || "player")
            if (message.grid_id !== undefined) {
                normalized.grid_id = message.grid_id
            }
            normalized.slot = slot
            updated[slot] = normalized
            single_player_selected_powerups = updated
            single_player_selection_ready = false
        }
    }

    AppListener {
        filter: "singlePlayerSelectionConfirmed"
        onDispatched: function (type, message) {
            single_player_selection_ready = true
            prepareSinglePlayerDashboards()
            updateRuntimePowerups(1)
        }
    }

    AppListener {
        filter: "gameBoardDashboardsReady"
        onDispatched: function (type, message) {
            if (!message || message.grid_id === undefined) {
                return
            }
            var gridKey = message.grid_id.toString()
            var updated = {
                "0": single_player_dashboard_ready["0"],
                "1": single_player_dashboard_ready["1"]
            }
            updated[gridKey] = true
            single_player_dashboard_ready = updated
            updateRuntimePowerups(message.grid_id)
        }
    }

    AppListener {
        filter: "powerupEnergyDelta"
        onDispatched: function(type, data) {
            if (!data || data.grid_id === undefined || data.slot_id === undefined) {
                return
            }
            ensureRuntimeInitialized()
            var amount = data.amount !== undefined ? data.amount : 0
            if (amount === 0) {
                return
            }
            var colorFilter = data.color ? ("" + data.color).toLowerCase() : null
            var gridKey = String(data.grid_id)
            var slots = powerup_runtime_state[gridKey] ? powerup_runtime_state[gridKey].slots : {}
            var targetSlots = []
            if (data.slot_id !== undefined && data.slot_id !== null && data.slot_id >= 0) {
                targetSlots.push(runtimeSlotState(data.grid_id, data.slot_id))
            } else {
                for (var slotKey in slots) {
                    if (!slots.hasOwnProperty(slotKey)) {
                        continue
                    }
                    targetSlots.push(slots[slotKey])
                }
            }
            for (var i = 0; i < targetSlots.length; ++i) {
                var slotState = targetSlots[i]
                if (!slotState) {
                    continue
                }
                if (colorFilter && slotState.color && slotState.color.toLowerCase() !== colorFilter) {
                    continue
                }
                var previousReady = slotState.ready
                slotState.energy = Math.max(0, Math.min(slotState.energy + amount, slotState.maxEnergy))
                slotState.ready = slotState.energy >= slotState.maxEnergy
                powerup_runtime_state[gridKey].slots[String(slotState.slot)] = slotState
                if (slotState.ready && !previousReady) {
                    // ready flag will be observed via runtime state publication
                }
            }
            publishRuntimeState()
        }
    }

    AppListener {
        filter: "powerupEnergyReset"
        onDispatched: function(type, data) {
            if (!data || data.grid_id === undefined || data.slot_id === undefined) {
                return
            }
            ensureRuntimeInitialized()
            var slotState = runtimeSlotState(data.grid_id, data.slot_id)
            slotState.energy = 0
            slotState.ready = false
            powerup_runtime_state[String(data.grid_id)].slots[String(data.slot_id)] = slotState
            publishRuntimeState()
        }
    }

    AppListener {
        filter: "deployPowerupApplied"
        onDispatched: function(type, data) {
            if (!data || data.grid_id === undefined || data.slot_id === undefined) {
                return
            }
            if (data.success === false) {
                publishRuntimeState()
                return
            }
            ensureRuntimeInitialized()
            var slotState = runtimeSlotState(data.grid_id, data.slot_id)
            slotState.deployed = true
            slotState.energy = 0
            slotState.ready = false
            slotState.position = {
                "row": data.row !== undefined ? data.row : -1,
                "column": data.column !== undefined ? data.column : -1
            }
            if (!slotState.maxEnergy || slotState.maxEnergy <= 0) {
                slotState.maxEnergy = Math.max(1, slotState.amount)
            }
            slotState.health = slotState.maxEnergy
            powerup_runtime_state[String(data.grid_id)].slots[String(data.slot_id)] = slotState
            publishRuntimeState()
        }
    }

    AppListener {
        filter: "applyPowerupCardHealth"
        onDispatched: function(type, data) {
            if (!data || data.grid_id === undefined || data.slot_id === undefined || data.amount === undefined) {
                return
            }
            ensureRuntimeInitialized()
            var slotState = runtimeSlotState(data.grid_id, data.slot_id)
            if (!slotState.deployed) {
                return
            }
            var newHealth = slotState.health !== undefined ? slotState.health + data.amount : data.amount
            if (slotState.maxEnergy && slotState.maxEnergy > 0) {
                if (newHealth > slotState.maxEnergy) {
                    newHealth = slotState.maxEnergy
                }
            }
            slotState.health = Math.max(0, newHealth)
            powerup_runtime_state[String(data.grid_id)].slots[String(data.slot_id)] = slotState
            publishRuntimeState()
        }
    }

    AppListener {
        filter: "powerupPlayerHealthDelta"
        onDispatched: function(type, data) {
            if (!data || data.grid_id === undefined || data.amount === undefined) {
                return
            }
            var key = String(data.grid_id)
            var current = player_health[key] !== undefined ? player_health[key] : 0
            var updated = current + data.amount
            if (updated < 0) {
                updated = 0
            }
            player_health = Object.assign({}, player_health, { [key]: updated })
        }
    }
}
