import QtQuick 2.0
import QuickFlux 1.1
import "../actions"
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

    Component.onCompleted: {
        loadPowerupData()
    }
    /* database */
    function loadDatabase() {
        return
    }

    function loadPowerupData() {
        var db = LocalStorage.openDatabaseSync("block.wars", "1.0",
                                               "Block Wars User Settings",
                                               1000000)
        var rs
        db.transaction(function (tx) {
            // Create the database if it doesn't already exist
            // tx.executeSql('DROP TABLE game_data')
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS powerup_data(slot numeric, target text, hero_targets numeric, amount numeric, grid_targets text)')

            // Add (another) greeting row
            //  tx.executeSql('INSERT INTO Greeting VALUES(?, ?)', [ 'hello', 'world' ]);

            // Show all added greetings
            rs = tx.executeSql(
                        'SELECT slot,target,hero_targets,amount,grid_targets from powerup_data')
            console.log(JSON.stringify(rs))
            if (Object.keys(rs.rows).length > 0) {
                var newData = {}
                for (var i = 0; i < rs.rows.length; i++) {
                    var row = rs.rows.item(i)
                    newData[row.slot] = {
                        "slot": row.slot,
                        "target": row.target,
                        "hero_targets": row.hero_targets,
                        "amount": row.amount,
                        "grid_targets": JSON.parse(row.grid_targets)
                    }
                }
                my_powerup_data = newData
            }
        })
    }

    function savePowerupData() {
        var db = LocalStorage.openDatabaseSync("block.wars", "1.0",
                                               "Block Wars User Settings",
                                               1000000)

        db.transaction(function (tx) {
            // Create the database if it doesn't already exist
            tx.executeSql(
                        'CREATE TABLE IF NOT EXISTS powerup_data(slot numeric primary key, target text, hero_targets numeric, amount numeric, grid_targets text)')
            tx.executeSql('DELETE from powerup_data')

            // Iterating over each powerup data and saving it to the database
            for (var slot in my_powerup_data) {
                var powerup = my_powerup_data[slot]
                tx.executeSql(
                            'INSERT OR REPLACE INTO powerup_data(slot, target, hero_targets, amount, grid_targets) VALUES (?, ?, ?, ?, ?)',
                            [powerup.slot, powerup.target, powerup.hero_targets, powerup.amount, compressData(
                                 powerup.grid_targets)])
            }
        })
    }

    function compressData(grid_targets) {
        let result = ""
        var _grid_targets = []
        if (grid_targets == null) {

            _grid_targets = [{
                                 "selected": false,
                                 "row": 0,
                                 "col": 0
                             }, {
                                 "selected": false,
                                 "row": 0,
                                 "col": 1
                             }, {
                                 "selected": false,
                                 "row": 0,
                                 "col": 2
                             }, {
                                 "selected": false,
                                 "row": 0,
                                 "col": 3
                             }, {
                                 "selected": false,
                                 "row": 0,
                                 "col": 4
                             }, {
                                 "selected": false,
                                 "row": 0,
                                 "col": 5
                             }, {
                                 "selected": false,
                                 "row": 1,
                                 "col": 0
                             }, {
                                 "selected": false,
                                 "row": 1,
                                 "col": 1
                             }, {
                                 "selected": false,
                                 "row": 1,
                                 "col": 2
                             }, {
                                 "selected": false,
                                 "row": 1,
                                 "col": 3
                             }, {
                                 "selected": false,
                                 "row": 1,
                                 "col": 4
                             }, {
                                 "selected": false,
                                 "row": 1,
                                 "col": 5
                             }, {
                                 "selected": false,
                                 "row": 2,
                                 "col": 0
                             }, {
                                 "selected": false,
                                 "row": 2,
                                 "col": 1
                             }, {
                                 "selected": false,
                                 "row": 2,
                                 "col": 2
                             }, {
                                 "selected": false,
                                 "row": 2,
                                 "col": 3
                             }, {
                                 "selected": false,
                                 "row": 2,
                                 "col": 4
                             }, {
                                 "selected": false,
                                 "row": 2,
                                 "col": 5
                             }, {
                                 "selected": false,
                                 "row": 3,
                                 "col": 0
                             }, {
                                 "selected": false,
                                 "row": 3,
                                 "col": 1
                             }, {
                                 "selected": false,
                                 "row": 3,
                                 "col": 2
                             }, {
                                 "selected": false,
                                 "row": 3,
                                 "col": 3
                             }, {
                                 "selected": false,
                                 "row": 3,
                                 "col": 4
                             }, {
                                 "selected": false,
                                 "row": 3,
                                 "col": 5
                             }, {
                                 "selected": false,
                                 "row": 4,
                                 "col": 0
                             }, {
                                 "selected": false,
                                 "row": 4,
                                 "col": 1
                             }, {
                                 "selected": false,
                                 "row": 4,
                                 "col": 2
                             }, {
                                 "selected": false,
                                 "row": 4,
                                 "col": 3
                             }, {
                                 "selected": false,
                                 "row": 4,
                                 "col": 4
                             }, {
                                 "selected": false,
                                 "row": 4,
                                 "col": 5
                             }, {
                                 "selected": false,
                                 "row": 5,
                                 "col": 0
                             }, {
                                 "selected": false,
                                 "row": 5,
                                 "col": 1
                             }, {
                                 "selected": false,
                                 "row": 5,
                                 "col": 2
                             }, {
                                 "selected": false,
                                 "row": 5,
                                 "col": 3
                             }, {
                                 "selected": false,
                                 "row": 5,
                                 "col": 4
                             }, {
                                 "selected": false,
                                 "row": 5,
                                 "col": 5
                             }]
        } else {
            _grid_targets = grid_targets
        }
        var gridTarget
        for (var i = 0; i < 6; i++) {
            for (var u = 0; u < 6; u++) {
                var foundOne = false
                for (var p = 0; p < _grid_targets.length; p++) {
                    if (_grid_targets[p].row == i) {
                        if (_grid_targets[p].col == u) {
                            result += _grid_targets[p].selected ? "1" : "0"

                            foundOne = true
                            break
                        }
                    }
                }
                if (!foundOne) {
                    result += "0"
                }
            }
        }
        return result
    }

    function decompressData(compressedStr) {
        const parts = compressedStr.split('.')
        const gridTargets = []

        let gridString = parts.slice(4).join('')
        for (var i = 0; i < 6; i++) {
            for (var u = 0; u < 6; u++) {
                gridTargets.push({
                                     "selected": gridString[i * 6 + u] === '1',
                                     "row": i,
                                     "col": u
                                 })
            }
        }

        return {
            "slot": parseInt(parts[0], 10),
            "target": parts[1],
            "amount": parseInt(parts[2], 10),
            "hero_targets": parseInt(parts[3], 10),
            "grid_targets": gridTargets
        }
    }
}
