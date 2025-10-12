import QtQuick 2.12
import QuickFlux 1.1
import "../actions" 1.0

Item {
    id: turnController

    // Configuration
    property var gridOrder: [0, 1]
    property int cpuGridId: 0
    property int playerGridId: 1
    property int movesPerTurn: 3

    // Runtime state
    property int activeGrid: -1
    property int attackerGridId: -1
    property int defenderGridId: -1
    property var stateByGrid: ({})

    function otherGrid(gridId) {
        if (gridOrder && gridOrder.length > 1) {
            var idx = gridOrder.indexOf(gridId)
            if (idx !== -1) {
                return gridOrder[(idx + 1) % gridOrder.length]
            }
        }
        return gridId === cpuGridId ? playerGridId : cpuGridId
    }

    function ensureState(gridId) {
        var key = String(gridId)
        if (!stateByGrid.hasOwnProperty(key)) {
            stateByGrid[key] = {
                movesRemaining: 0,
                phase: "idle",
                awaitingReadySignal: false,
                awaitingSettlement: false,
                pendingMove: false,
                blocksEnabled: false
            }
        }
        return stateByGrid[key]
    }

    function resetAllState() {
        stateByGrid = ({})
        activeGrid = -1
        attackerGridId = -1
        defenderGridId = -1
    }

    function beginTurn(gridId, options) {
        var state = ensureState(gridId)
        var moves = movesPerTurn
        if (options && options.moves !== undefined) {
            moves = options.moves
        }
        attackerGridId = gridId
        defenderGridId = otherGrid(gridId)
        activeGrid = gridId

        state.movesRemaining = moves
        state.phase = "settling"
        state.awaitingReadySignal = false
        state.awaitingSettlement = true
        state.pendingMove = false

        AppActions.enableBlocks(gridId, false)
        AppActions.beginFillCycle(gridId, "turnStart")
        AppActions.setFillingEnabled(gridId, true)
        AppActions.setLaunchOnMatchEnabled(gridId, true)

        AppActions.setFillingEnabled(defenderGridId, false)
        AppActions.setLaunchOnMatchEnabled(defenderGridId, false)

        var defenderState = ensureState(defenderGridId)
        defenderState.phase = "waitingOpponent"
        defenderState.pendingMove = false
        defenderState.awaitingReadySignal = false
        defenderState.awaitingSettlement = false

        AppActions.turnCycleTurnBegan({
                                           "grid_id": gridId,
                                           "defender_grid_id": defenderGridId,
                                           "moves_remaining": state.movesRemaining
                                       })
        AppActions.setActiveGrid(gridId)
    }

    function handleSwapStarted(data) {
        var gridId = data.grid_id
        if (gridId !== activeGrid) {
            return
        }
        var state = ensureState(gridId)
        if (state.phase !== "awaitingInput") {
            return
        }
        state.movesRemaining = Math.max(0, state.movesRemaining - 1)
        state.phase = "resolving"
        state.pendingMove = true
        state.awaitingReadySignal = false
        state.awaitingSettlement = true
        AppActions.swapLaunchingStarted({
                                             "grid_id": gridId,
                                             "moves_remaining": state.movesRemaining,
                                             "row": data.row,
                                             "column": data.column,
                                             "direction": data.direction
                                         })
    }

    function handleAnimationsCompleted(info) {
        var gridId = info.grid_id
        if (gridId !== activeGrid) {
            return
        }
        var state = ensureState(gridId)
        if (!state.pendingMove) {
            return
        }
        state.pendingMove = false
        state.phase = "settling"
        state.awaitingReadySignal = false
        state.awaitingSettlement = true
    }

    function handleGridSettled(info) {
        if (!info || info.grid_id === undefined) {
            return
        }
        var gridId = info.grid_id
        var state = ensureState(gridId)
        if (info.has_empty === true) {
            state.awaitingSettlement = true
            AppActions.beginFillCycle(gridId, "autoFill")
            return
        }
        state.awaitingSettlement = false
        if (gridId === activeGrid) {
            if (state.movesRemaining <= 0) {
                finishTurn(gridId)
            } else {
                state.phase = "awaitingInput"
                AppActions.enableBlocks(gridId, true)
                if (gridId === cpuGridId) {
                    maybeRequestCpuMove()
                }
            }
        } else {
            ensureState(gridId).phase = "waitingOpponent"
        }
    }

    function finishTurn(gridId) {
        var nextGrid = otherGrid(gridId)
        var attackerState = ensureState(gridId)
        attackerState.phase = "waitingOpponent"
        attackerState.awaitingSettlement = false
        attackerState.pendingMove = false
        AppActions.enableBlocks(gridId, false)
        AppActions.requestNextTurn({
                                        "from_grid_id": gridId,
                                        "to_grid_id": nextGrid
                                    })
        beginTurn(nextGrid, {
                      "moves": movesPerTurn
                  })
    }

    function maybeRequestCpuMove() {
        if (activeGrid !== cpuGridId) {
            return
        }
        var state = ensureState(cpuGridId)
        if (state.phase !== "awaitingInput") {
            return
        }
        if (state.movesRemaining <= 0) {
            return
        }
        AppActions.cpuRequestMove({
                                     "grid_id": cpuGridId,
                                     "moves_remaining": state.movesRemaining,
                                     "defender_grid_id": defenderGridId
                                 })
    }

    AppListener {
        filter: ActionTypes.initializeTurnCycle
        onDispatched: function(type, data) {
            resetAllState()
            movesPerTurn = data && data.moves !== undefined ? data.moves : movesPerTurn
            var attacker = data && data.attacker_grid_id !== undefined ? data.attacker_grid_id : playerGridId
            var defender = data && data.defender_grid_id !== undefined ? data.defender_grid_id : otherGrid(attacker)
            ensureState(attacker)
            ensureState(defender)
            beginTurn(attacker, {
                          "moves": movesPerTurn
                      })
        }
    }

    AppListener {
        filter: ActionTypes.swapBlocks
        onDispatched: function(type, data) {
            handleSwapStarted(data)
        }
    }

    AppListener {
        filter: ActionTypes.enableBlocks
        onDispatched: function(type, data) {
            // Track block state if needed; turn controller now manages enabling
            ensureState(data.grid_id).blocksEnabled = data.blocks_enabled
        }
    }

    AppListener {
        filter: ActionTypes.swapLaunchingAnimationsDone
        onDispatched: function(type, data) {
            if (data.grid_id !== activeGrid) {
                return
            }
            handleAnimationsCompleted(data)
        }
    }

    AppListener {
        filter: ActionTypes.gridSettled
        onDispatched: function(type, data) {
            handleGridSettled(data)
        }
    }

    AppListener {
        filter: ActionTypes.enqueueGridEvent
        onDispatched: function(type, data) {
            if (data.grid_id !== activeGrid) {
                return
            }
            if (data.event_type === "shuffleDown" || data.event_type === "createBlocks") {
                AppActions.informGridFillInNeeded({
                                                     "grid_id": data.grid_id,
                                                     "event_type": data.event_type
                                                 })
            }
        }
    }

    AppListener {
        filter: ActionTypes.cpuMoveUnavailable
        onDispatched: function(type, data) {
            if (data.grid_id !== activeGrid) {
                return
            }
            var state = ensureState(activeGrid)
            state.movesRemaining = 0
            state.pendingMove = false
            finishTurn(activeGrid)
        }
    }
}
