import QtQuick 2.12
import QuickFlux 1.1
import "../actions" 1.0

Item {
    id: cpuController

    property int gridId: 0
    property Item grid: null

    readonly property int rows: grid && grid.maxRow ? grid.maxRow : 6
    readonly property int columns: grid && grid.maxColumn ? grid.maxColumn : 6

    property string pendingRequestId: ""

    function resetPendingRequest() {
        pendingRequestId = ""
    }

    function generateRequestId() {
        return Date.now().toString() + "_" + Math.floor(Math.random() * 1000000)
    }

    function buildEmptyMatrix() {
        var matrix = []
        for (var r = 0; r < rows; ++r) {
            var cols = []
            for (var c = 0; c < columns; ++c) {
                cols.push(null)
            }
            matrix.push(cols)
        }
        return matrix
    }

    function matrixFromCells(cells) {
        var matrix = buildEmptyMatrix()
        if (!cells || !cells.length) {
            return matrix
        }
        for (var i = 0; i < cells.length; ++i) {
            var cell = cells[i]
            if (!cell) {
                continue
            }
            var r = cell.row
            var c = cell.column
            if (r < 0 || c < 0 || r >= rows || c >= columns) {
                continue
            }
            matrix[r][c] = cell.color || null
        }
        return matrix
    }

    function countDirection(matrix, row, column, deltaRow, deltaCol, color) {
        var count = 0
        var r = row + deltaRow
        var c = column + deltaCol
        while (r >= 0 && r < rows && c >= 0 && c < columns) {
            if (matrix[r][c] !== color) {
                break
            }
            count += 1
            r += deltaRow
            c += deltaCol
        }
        return count
    }

    function formsMatch(matrix, row, column) {
        var color = matrix[row][column]
        if (!color) {
            return false
        }
        var horizontal = 1 + countDirection(matrix, row, column, 0, -1, color) + countDirection(matrix, row, column, 0, 1, color)
        if (horizontal >= 3) {
            return true
        }
        var vertical = 1 + countDirection(matrix, row, column, -1, 0, color) + countDirection(matrix, row, column, 1, 0, color)
        if (vertical >= 3) {
            return true
        }
        return false
    }

    function swapCreatesMatch(matrix, r1, c1, r2, c2) {
        var colorA = matrix[r1][c1]
        var colorB = matrix[r2][c2]
        if (!colorA && !colorB) {
            return false
        }
        matrix[r1][c1] = colorB
        matrix[r2][c2] = colorA
        var matched = formsMatch(matrix, r1, c1) || formsMatch(matrix, r2, c2)
        matrix[r1][c1] = colorA
        matrix[r2][c2] = colorB
        return matched
    }

    function findMove(matrix) {
        if (!matrix) {
            return null
        }
        for (var r = 0; r < rows; ++r) {
            for (var c = 0; c < columns; ++c) {
                if (!matrix[r][c]) {
                    continue
                }
                if (c + 1 < columns && matrix[r][c + 1]) {
                    if (swapCreatesMatch(matrix, r, c, r, c + 1)) {
                        return { "row": r, "column": c, "direction": "right" }
                    }
                }
                if (r + 1 < rows && matrix[r + 1][c]) {
                    if (swapCreatesMatch(matrix, r, c, r + 1, c)) {
                        return { "row": r, "column": c, "direction": "down" }
                    }
                }
            }
        }
        return null
    }

    AppListener {
        filter: ActionTypes.cpuRequestMove
        onDispatched: function(type, data) {
            if (data.grid_id !== cpuController.gridId) {
                return
            }
            if (cpuController.pendingRequestId !== "") {
                return
            }
            cpuController.pendingRequestId = cpuController.generateRequestId()
            AppActions.requestGridSnapshot({
                                                "grid_id": cpuController.gridId,
                                                "request_id": cpuController.pendingRequestId,
                                                "reason": "cpuMove"
                                            })
        }
    }

    AppListener {
        filter: ActionTypes.gridSnapshotProvided
        onDispatched: function(type, data) {
            if (data.grid_id !== cpuController.gridId) {
                return
            }
            if (!cpuController.pendingRequestId || cpuController.pendingRequestId === "") {
                return
            }
            if (data.request_id !== cpuController.pendingRequestId) {
                return
            }

            var matrix = cpuController.matrixFromCells(data.cells || [])
            var move = cpuController.findMove(matrix)
            if (move) {
                AppActions.swapBlocks(move.row, move.column, cpuController.gridId, move.direction)
            } else {
                AppActions.cpuMoveUnavailable(cpuController.gridId, {
                                                 "reason": "noValidSwap"
                                             })
            }
            cpuController.resetPendingRequest()
        }
    }
}
