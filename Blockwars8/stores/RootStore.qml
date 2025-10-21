import QtQuick 2.0
import QuickFlux 1.1
import "../actions"
import "../models"

Store {
    id: rootStore
    property string text: ""
    property var my_powerup_data: {
        "0": {
            "slot": 0,
            "name": "Powerup Slot 1",
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
            "name": "Powerup Slot 2",
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
            "name": "Powerup Slot 3",
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
            "name": "Powerup Slot 4",
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

    SQLDataStorage {
        id: localPowerupDataStorage
        table: "localPowerupData"
        columnDefinitions: ({
            id: "INTEGER PRIMARY KEY",
            name: "TEXT NOT NULL",
            assignments: "TEXT",
            data: "TEXT"
        })
    }

    QtObject {
        id: powerupPersistence
        property alias storage: localPowerupDataStorage

        function hasOwn(container, key) {
            if (!container) {
                return false
            }
            if (container.hasOwnProperty) {
                return container.hasOwnProperty(key)
            }
            return true
        }

        function defaultNameForSlot(slotIndex) {
            return qsTr("Powerup Slot %1").arg(slotIndex + 1)
        }

        function assignmentKeysForSlot(slotIndex) {
            return ["SinglePlayerSlot" + (slotIndex + 1), "MultiplayerSlot" + (slotIndex + 1)]
        }

        function slotIndexFromAssignment(assignment) {
            if (!assignment || typeof assignment !== "string") {
                return null
            }
            var single = assignment.match(/SinglePlayerSlot(\d+)/)
            if (single && single.length > 1) {
                return Math.max(0, parseInt(single[1], 10) - 1)
            }
            var multi = assignment.match(/MultiplayerSlot(\d+)/)
            if (multi && multi.length > 1) {
                return Math.max(0, parseInt(multi[1], 10) - 1)
            }
            return null
        }

        function cloneData(payload) {
            if (!payload || typeof payload !== "object") {
                return {}
            }
            try {
                return JSON.parse(JSON.stringify(payload))
            } catch (error) {
                console.error("[RootStore] Failed to clone powerup payload:", error)
                return {}
            }
        }

        function normalizeSlot(sourceKey, payload) {
            if (payload && typeof payload.slot === "number") {
                return payload.slot
            }
            if (payload && typeof payload.slot === "string") {
                var parsedFromPayload = parseInt(payload.slot, 10)
                if (!isNaN(parsedFromPayload)) {
                    return parsedFromPayload
                }
            }
            var parsed = parseInt(sourceKey, 10)
            if (!isNaN(parsed)) {
                return parsed
            }
            return 0
        }

        function interpretEntry(entrySource) {
            if (entrySource === null || entrySource === undefined) {
                return {}
            }
            if (Array.isArray(entrySource)) {
                if (entrySource.length === 0) {
                    return {}
                }
                return interpretEntry(entrySource[0])
            }
            if (typeof entrySource === "object") {
                return cloneData(entrySource)
            }
            return {}
        }

        function enrichEntry(entry, slotIndex) {
            var result = cloneData(entry)
            result.slot = slotIndex
            if (!result.name || result.name === "") {
                result.name = defaultNameForSlot(slotIndex)
            }
            return result
        }

        function normalize(rawData) {
            var normalizedMap = {}
            var processEntry = function (sourceKey, value) {
                var entry = interpretEntry(value)
                if (!entry || Object.keys(entry).length === 0) {
                    return
                }
                var slotIndex = normalizeSlot(sourceKey, entry)
                normalizedMap[slotIndex] = enrichEntry(entry, slotIndex)
            }
            if (!rawData) {
                return normalizedMap
            }
            if (Array.isArray(rawData)) {
                for (var idx = 0; idx < rawData.length; ++idx) {
                    processEntry(idx, rawData[idx])
                }
            } else if (typeof rawData === "object") {
                for (var key in rawData) {
                    if (hasOwn(rawData, key)) {
                        processEntry(key, rawData[key])
                    }
                }
            }
            return normalizedMap
        }

        function encode(powerupData) {
            var normalizedMap = normalize(powerupData)
            var rows = []
            for (var key in normalizedMap) {
                if (hasOwn(normalizedMap, key)) {
                    var entry = normalizedMap[key]
                    var slotIndex = normalizeSlot(key, entry)
                    var record = enrichEntry(entry, slotIndex)
                    rows.push({
                                  index: slotIndex,
                                  name: record.name,
                                  assignments: storage.toHex(assignmentKeysForSlot(slotIndex)),
                                  data: storage.toHex(record)
                              })
                }
            }
            return rows
        }

        function decode(rows) {
            var map = {}
            if (!rows || rows.length === 0) {
                return map
            }
            for (var i = 0; i < rows.length; ++i) {
                var row = rows[i]
                var assignments = storage.fromHex(row.assignments)
                var payload = storage.fromHex(row.data)
                if (!payload || typeof payload !== "object") {
                    continue
                }
                var baseSlot = normalizeSlot(row.index, payload)
                var resolved = false
                if (Array.isArray(assignments)) {
                    for (var j = 0; j < assignments.length; ++j) {
                        var slotIndex = slotIndexFromAssignment(assignments[j])
                        if (slotIndex === null) {
                            continue
                        }
                        var resolvedEntry = enrichEntry(payload, slotIndex)
                        if (row.name) {
                            resolvedEntry.name = row.name
                        }
                        map[slotIndex] = resolvedEntry
                        resolved = true
                    }
                }
                if (!resolved) {
                    var fallbackEntry = enrichEntry(payload, baseSlot)
                    if (row.name) {
                        fallbackEntry.name = row.name
                    }
                    map[baseSlot] = fallbackEntry
                }
            }
            return map
        }
    }

    Component.onCompleted: {
        loadPowerupData()
    }
    /* database */
    function loadDatabase() {
        return
    }

    function loadPowerupData() {
        var rows = localPowerupDataStorage.selectAll()
        if (!rows || rows.length === 0) {
            return
        }
        var decoded = powerupPersistence.decode(rows)
        if (Object.keys(decoded).length > 0) {
            my_powerup_data = decoded
        }
    }

    function savePowerupData() {
        var rows = powerupPersistence.encode(my_powerup_data)
        localPowerupDataStorage.replaceAll(rows)
    }

    function ingestPowerupData(rawData) {
        var normalized = powerupPersistence.normalize(rawData)
        my_powerup_data = normalized
        savePowerupData()
    }
}
