import QtQuick 2.15
import QtQuick.LocalStorage 2.15

QtObject {
    id: sqlDataStorage

    property string databaseName: "block.wars"
    property string version: "1.0"
    property string description: "Block Wars User Settings"
    property int estimatedSize: 1000000
    property string table: ""
    property var columnDefinitions: ({})
    property bool autoCreateTable: true

    Component.onCompleted: {
        if (autoCreateTable) {
            ensureTable()
        }
    }

    function database() {
        try {
            return LocalStorage.openDatabaseSync(databaseName, version, description, estimatedSize)
        } catch (error) {
            console.error("[SQLDataStorage] Failed to open database:", error)
            return null
        }
    }

    function withTransaction(operation) {
        if (typeof operation !== "function") {
            console.warn("[SQLDataStorage] Transaction requires a function callback")
            return null
        }
        var db = database()
        if (!db) {
            return null
        }
        var result = null
        try {
            db.transaction(function (tx) {
                if (autoCreateTable) {
                    ensureTable(tx)
                }
                result = operation(tx)
            })
        } catch (error) {
            console.error("[SQLDataStorage] Transaction error:", error)
        }
        return result
    }

    function ensureTable(tx) {
        if (!table || !columnDefinitions || Object.keys(columnDefinitions).length === 0) {
            return false
        }
        var columns = []
        for (var key in columnDefinitions) {
            columns.push(key + " " + columnDefinitions[key])
        }
        var statement = "CREATE TABLE IF NOT EXISTS " + table + " (" + columns.join(", ") + ")"
        return execute(tx, statement, [])
    }

    function execute(tx, statement, values) {
        if (!tx) {
            return withTransaction(function (innerTx) {
                return execute(innerTx, statement, values)
            })
        }
        try {
            var resultSet = tx.executeSql(statement, values || [])
            return {
                rows: rowsFromResultSet(resultSet),
                raw: resultSet
            }
        } catch (error) {
            console.error("[SQLDataStorage] SQL error (" + statement + "):", error)
            return {
                rows: [],
                error: error
            }
        }
    }

    function rowsFromResultSet(resultSet) {
        var rows = []
        if (!resultSet || !resultSet.rows) {
            return rows
        }
        var length = resultSet.rows.length
        for (var i = 0; i < length; ++i) {
            rows.push(resultSet.rows.item(i))
        }
        return rows
    }

    function insert(row) {
        if (!row) {
            return null
        }
        return withTransaction(function (tx) {
            var columns = []
            var placeholders = []
            var values = []
            for (var key in row) {
                columns.push(key)
                placeholders.push("?")
                values.push(row[key])
            }
            var sql = "INSERT OR REPLACE INTO " + table + " (" + columns.join(", ") + ") VALUES (" + placeholders.join(", ") + ")"
            return execute(tx, sql, values)
        })
    }

    function update(values, criteria) {
        if (!values || Object.keys(values).length === 0) {
            return null
        }
        return withTransaction(function (tx) {
            var setClauses = []
            var params = []
            for (var key in values) {
                setClauses.push(key + " = ?")
                params.push(values[key])
            }
            var whereClause = ""
            if (criteria && Object.keys(criteria).length) {
                var whereParts = []
                for (var key2 in criteria) {
                    whereParts.push(key2 + " = ?")
                    params.push(criteria[key2])
                }
                whereClause = " WHERE " + whereParts.join(" AND ")
            }
            var sql = "UPDATE " + table + " SET " + setClauses.join(", ") + whereClause
            return execute(tx, sql, params)
        })
    }

    function select(criteria, columns) {
        var columnList = "*"
        if (columns && columns.length) {
            columnList = columns.join(", ")
        }
        return withTransaction(function (tx) {
            var params = []
            var whereClause = ""
            if (criteria && Object.keys(criteria).length) {
                var whereParts = []
                for (var key in criteria) {
                    whereParts.push(key + " = ?")
                    params.push(criteria[key])
                }
                whereClause = " WHERE " + whereParts.join(" AND ")
            }
            var sql = "SELECT " + columnList + " FROM " + table + whereClause
            var execution = execute(tx, sql, params)
            return execution ? execution.rows : []
        })
    }

    function selectAll(columns) {
        return select(null, columns)
    }

    function remove(criteria) {
        return withTransaction(function (tx) {
            var params = []
            var whereClause = ""
            if (criteria && Object.keys(criteria).length) {
                var whereParts = []
                for (var key in criteria) {
                    whereParts.push(key + " = ?")
                    params.push(criteria[key])
                }
                whereClause = " WHERE " + whereParts.join(" AND ")
            }
            var sql = "DELETE FROM " + table + whereClause
            return execute(tx, sql, params)
        })
    }

    function deleteAll() {
        return remove(null)
    }

    function replaceAll(rows) {
        rows = rows || []
        return withTransaction(function (tx) {
            ensureTable(tx)
            execute(tx, "DELETE FROM " + table, [])
            for (var i = 0; i < rows.length; ++i) {
                var row = rows[i]
                var columns = []
                var placeholders = []
                var values = []
                for (var key in row) {
                    columns.push(key)
                    placeholders.push("?")
                    values.push(row[key])
                }
                var statement = "INSERT OR REPLACE INTO " + table + " (" + columns.join(", ") + ") VALUES (" + placeholders.join(", ") + ")"
                execute(tx, statement, values)
            }
            return true
        })
    }

    function toHex(value) {
        var normalized
        try {
            normalized = JSON.stringify(value)
        } catch (error) {
            console.error("[SQLDataStorage] Unable to stringify value for hex conversion:", error)
            normalized = JSON.stringify(null)
        }
        if (!normalized) {
            normalized = JSON.stringify(null)
        }
        var utf8
        try {
            utf8 = unescape(encodeURIComponent(normalized))
        } catch (error) {
            console.error("[SQLDataStorage] UTF-8 encoding failed:", error)
            utf8 = normalized
        }
        var hex = ""
        for (var i = 0; i < utf8.length; ++i) {
            var code = utf8.charCodeAt(i).toString(16).toUpperCase()
            if (code.length < 2) {
                code = "0" + code
            }
            hex += code
        }
        return hex
    }

    function fromHex(hex) {
        if (!hex) {
            return null
        }
        var cleanHex = ("" + hex).toUpperCase()
        var bytes = []
        for (var i = 0; i < cleanHex.length; i += 2) {
            var pair = cleanHex.substr(i, 2)
            if (pair.length < 2) {
                continue
            }
            var value = parseInt(pair, 16)
            if (isNaN(value)) {
                continue
            }
            bytes.push(String.fromCharCode(value))
        }
        var ascii = bytes.join("")
        var jsonString
        try {
            jsonString = decodeURIComponent(escape(ascii))
        } catch (error) {
            console.error("[SQLDataStorage] UTF-8 decoding failed:", error)
            jsonString = ascii
        }
        try {
            return JSON.parse(jsonString)
        } catch (error) {
            console.warn("[SQLDataStorage] JSON parse failed, returning raw string:", error)
            return jsonString
        }
    }
}
