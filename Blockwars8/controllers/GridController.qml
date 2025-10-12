import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQml 2.15
import QtQml.Models 2.15
import "../models"
import QtMultimedia 5.5
import QtQuick.Controls 2.0
import "../constants" 1.0
import "../actions" 1.0
import "../stores" 1.0
import QuickFlux 1.1
import "../zones" 1.0
import QtQuick.LocalStorage 2.15
import com.blockwars 1.0

Item {
    id: controller_root
    property var grid_id: 0
    property var grid_event_queue: []
    property var grid_block_data: new Array(36)
    property Item gridItem: null

    property var waitingForCallback: false
    Pool {
        id: pool_0
    }
    Pool {
        id: pool_1
    }
    Pool {
        id: pool_2
    }
    Pool {
        id: pool_3
    }
    Pool {
        id: pool_4
    }
    Pool {
        id: pool_5
    }
    property var pool_0_index: Math.floor(Math.random() * 1000)

    property var pool_1_index: Math.floor(Math.random() * 1000)

    property var pool_2_index: Math.floor(Math.random() * 1000)

    property var pool_3_index: Math.floor(Math.random() * 1000)

    property var pool_4_index: Math.floor(Math.random() * 1000)

    property var pool_5_index: Math.floor(Math.random() * 1000)

    function index(row, column) {
        return column + (row * 6)
    }

    onGridItemChanged: refreshGridBlockData()

    function refreshGridBlockData() {
        for (var idx = 0; idx < grid_block_data.length; idx++) {
            grid_block_data[idx] = null
        }

        if (!gridItem || !gridItem.grid_blocks) {
            return
        }

        for (var r = 0; r < 6; r++) {
            for (var c = 0; c < 6; c++) {
                var sourceIdx = gridItem.index(r, c)
                var blockObj = gridItem.grid_blocks[sourceIdx]
                if (blockObj && Qt.isQtObject(blockObj) && blockObj.objectName === "Block") {
                    grid_block_data[index(r, c)] = blockObj.block_color
                }
            }
        }
    }

    Component.onCompleted: {
        for (var i = 0; i < 36; i++) {
            grid_block_data[i] = null
        }
    }

    AppListener {
        filter: ActionTypes.swapBlocks
        onDispatched: function (type, a) {
            if (a.grid_id == controller_root.grid_id) {
                var nx = a.column
                var ny = a.row
                switch (a.direction) {
                case "up":
                    ny -= 1
                    break
                case "down":
                    ny += 1
                    break
                case "left":
                    nx -= 1
                    break
                case "right":
                    nx += 1
                    break
                case "none":
                    return
                }
                var evt = ({})
                evt.event_type = "swapBlocks"
                evt.row1 = a.row
                evt.row2 = ny
                evt.column1 = a.column
                evt.column2 = nx
                evt.grid_id = grid_id
                grid_event_queue.push(evt)
                executeNextGridEvent()
            }
        }
    }

    AppListener {
        filter: ActionTypes.gridEventDone
        onDispatched: function (type, message) {
            console.log("grid event complete", JSON.stringify(message))
            executeNextGridEvent()
        }
    }
    AppListener {
        filter: ActionTypes.blockFireAtTarget
    }
    AppListener {
        filter: ActionTypes.enqueueGridEvent
        onDispatched: function (dtype, ddata) {
            if (ddata.grid_id == controller_root.grid_id) {
                var evt = ddata
                grid_event_queue.push(evt)
                console.log("event queue", JSON.stringify(grid_event_queue))
                if (!waitingForCallback) {
                    executeNextGridEvent()
                }
            }
        }
    }
    AppListener {
        filter: ActionTypes.fillGrid
        onDispatched: function (dtype, ddata) {
            var evt = ddata
            if (evt.grid_id == grid_id) {
                fill()
            }
        }
    }
    AppListener {
        filter: ActionTypes.requestGridSnapshot
        onDispatched: function (dtype, ddata) {
            if (ddata.grid_id != controller_root.grid_id) {
                return
            }
            var snapshot = createGridSnapshot()
            var payload = ({
                               "grid_id": controller_root.grid_id,
                               "cells": snapshot,
                               "request_id": ddata.request_id !== undefined ? ddata.request_id : "",
                               "reason": ddata.reason !== undefined ? ddata.reason : "unspecified"
                           })
            AppActions.gridSnapshotProvided(payload)
        }
    }
    AppListener {
        filter: ActionTypes.beginFillCycle
        onDispatched: function (dtype, ddata) {
            if (ddata.grid_id == controller_root.grid_id) {
                var evt = ({})
                evt.event_type = "beginFillCycle"
                evt.source_event = ddata.source_event
                grid_event_queue.push(evt)
                if (!waitingForCallback) {
                    executeNextGridEvent()
                }
            }
        }
    }
    AppListener {
        filter: ActionTypes.createOneBlock
        onDispatched: function (type, message) {

            if (message.grid_id == grid_id) {
                var evt = ({})
                evt.event_type = "createOneBlock"
                evt.row = message.row
                evt.column = message.column
                grid_event_queue.push(evt)
                if (!waitingForCallback) {
                    executeNextGridEvent()
                }
            }
        }
    }

    function executeNextGridEvent() {
        if (grid_event_queue.length > 0) {
            waitingForCallback = true
            var nextEvent = grid_event_queue.shift()
            nextEvent.grid_id = grid_id
            AppActions.executeGridEvent(nextEvent)
        } else {
            waitingForCallback = false
        }
    }

    function getPool(column) {
        switch (column) {
        case 0:
            return pool_0
        case 1:
            return pool_1
        case 2:
            return pool_2
        case 3:
            return pool_3
        case 4:
            return pool_4
        case 5:
            return pool_5
        default:
            return pool_0
        }
    }
    function getPoolIndex(column) {
        switch (column) {
        case 0:
            return pool_0_index
        case 1:
            return pool_1_index
        case 2:
            return pool_2_index
        case 3:
            return pool_3_index
        case 4:
            return pool_4_index
        case 5:
            return pool_5_index
        default:
            return pool_0_index
        }
    }
    function increasePoolIndex(column) {
        var cur = getPoolIndex(column)
        cur++
        switch (column) {
        case 0:
            pool_0_index = cur
            break
        case 1:
            pool_1_index = cur
            break
        case 2:
            pool_2_index = cur
            break
        case 3:
            pool_3_index = cur
            break
        case 4:
            pool_4_index = cur
            break
        case 5:
            pool_5_index = cur
            break
        }
    }
    function fill() {

        refreshGridBlockData()
        var creationCounts = ({})
        console.log("filling in")
        for (var i = 0; i < 6; i++) {
            var colMissingCount = 0
            for (var u = 0; u < 6; u++) {
                if (grid_block_data[index(u, i)] == null) {
                    colMissingCount++
                }
            }
            if (colMissingCount > 0) {
                creationCounts[String(i)] = {
                    "missing": colMissingCount
                }
            }
        }
        console.log("needed blocks", JSON.stringify(creationCounts))
        var evt = ({})
        evt.event_type = "createBlocks"
        evt.create_counts = creationCounts
        grid_event_queue.push(evt)

        if (!waitingForCallback) {
            executeNextGridEvent()
        }
    }
    function autoFillGrid(player) {
          const emptyCells = getEmptyGridCells(player);
          emptyCells.forEach((cell, index) => {
              setTimeout(() => {
                  fillBlockAtCell(cell);
                  if (index === emptyCells.length - 1) {
                      enableSwitching();
                  }
              }, index * 500); // Stagger the filling process
          });
      }

      // Begin player turn
      function startPlayerTurn(player) {
          disableSwitching();
          autoFillGrid(player);
      }

      // Fill a block into a cell
      function fillBlockAtCell(cell) {
          cell.block = createBlock();
          if (isGridFullyFilled()) {
              enableSwitching();
          }
      }

    function createGridSnapshot() {
        var cells = []
        if (!gridItem || !gridItem.getBlock) {
            return cells
        }
        for (var r = 0; r < 6; r++) {
            for (var c = 0; c < 6; c++) {
                var blk = gridItem.getBlock(r, c)
                if (blk && Qt.isQtObject(blk) && blk.objectName === "Block") {
                    cells.push({
                                   "row": r,
                                   "column": c,
                                   "color": blk.block_color,
                                   "health": blk.block_health
                               })
                }
            }
        }
        return cells
    }
}
