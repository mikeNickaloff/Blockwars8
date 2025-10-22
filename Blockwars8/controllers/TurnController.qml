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

    QtObject {
        id: turnStateCoordinator

        property var states: ({})
        property var pendingHandOff: null

        function keyFor(gridId) {
            return String(gridId)
        }

        function clear() {
            states = ({})
            pendingHandOff = null
        }

        function ensure(gridId) {
            var key = keyFor(gridId)
            if (!states.hasOwnProperty(key)) {
                states[key] = {
                    gridId: gridId,
                    movesAllowed: 0,
                    movesRemaining: 0,
                    swapsStarted: 0,
                    pendingLaunches: 0,
                    awaitingSettlement: false,
                    phase: "idle",
                    blocksEnabled: false,
                    pendingMove: false
                }
            }
            return states[key]
        }

        function resetForTurn(gridId, moves) {
            var state = ensure(gridId)
            state.movesAllowed = moves
            state.movesRemaining = moves
            state.swapsStarted = 0
            state.pendingLaunches = 0
            state.awaitingSettlement = true
            state.phase = "settling"
            state.blocksEnabled = false
            state.pendingMove = false
            return state
        }

        function configureOpponent(gridId) {
            var state = ensure(gridId)
            state.movesRemaining = 0
            state.swapsStarted = 0
            state.pendingLaunches = 0
            state.awaitingSettlement = false
            state.phase = "waitingOpponent"
            state.pendingMove = false
            return state
        }

        function canStartSwap(gridId) {
            var state = ensure(gridId)
            return state.swapsStarted < state.movesAllowed
        }

        function markSwapStarted(gridId) {
            var state = ensure(gridId)
            state.swapsStarted += 1
            state.movesRemaining = Math.max(0, state.movesAllowed - state.swapsStarted)
            state.pendingLaunches += 1
            state.awaitingSettlement = true
            state.phase = "resolving"
            state.pendingMove = true
            return {
                state: state,
                quotaReached: state.swapsStarted >= state.movesAllowed
            }
        }

        function markAnimationsCompleted(gridId) {
            var state = ensure(gridId)
            if (state.pendingLaunches > 0) {
                state.pendingLaunches -= 1
            }
            state.pendingMove = false
            state.phase = state.awaitingSettlement ? "settling" : (state.swapsStarted >= state.movesAllowed ? "exhausted" : "awaitingInput")
            return state
        }

        function markSettlement(gridId, hasEmpty) {
            var state = ensure(gridId)
            if (hasEmpty === true) {
                state.awaitingSettlement = true
                state.phase = "settling"
            } else {
                state.awaitingSettlement = false
                state.phase = state.swapsStarted >= state.movesAllowed ? "exhausted" : "awaitingInput"
            }
            if (pendingHandOff && pendingHandOff.attackerId === gridId && hasEmpty !== true) {
                pendingHandOff.awaitingSettlement = false
            }
            return state
        }

        function readyForInput(gridId) {
            var state = ensure(gridId)
            return state.swapsStarted < state.movesAllowed && state.pendingLaunches === 0 && state.awaitingSettlement === false
        }

        function swapQuotaSatisfied(gridId) {
            var state = ensure(gridId)
            return state.swapsStarted >= state.movesAllowed
        }

        function canFinishTurn(gridId) {
            var state = ensure(gridId)
            return swapQuotaSatisfied(gridId) && state.pendingLaunches === 0 && state.awaitingSettlement === false
        }

        function recordBlocksEnabled(gridId, enabled) {
            ensure(gridId).blocksEnabled = enabled === true
        }

        function planHandOff(fromGridId, toGridId, moves) {
            pendingHandOff = {
                attackerId: toGridId,
                defenderId: fromGridId,
                moves: moves,
                awaitingSettlement: true
            }
        }

        function hasPendingHandOff(gridId) {
            return pendingHandOff && pendingHandOff.attackerId === gridId
        }

        function markHandOffReadyIfSettled(gridId) {
            if (pendingHandOff && pendingHandOff.attackerId === gridId) {
                var state = ensure(gridId)
                if (state.awaitingSettlement === false) {
                    pendingHandOff.awaitingSettlement = false
                }
            }
        }

        function consumeHandOff(gridId) {
            if (pendingHandOff && pendingHandOff.attackerId === gridId && pendingHandOff.awaitingSettlement === false) {
                var nextTurn = pendingHandOff
                pendingHandOff = null
                return nextTurn
            }
            return null
        }
    }

    function gridState(gridId) {
        return turnStateCoordinator.ensure(gridId)
    }

    function otherGrid(gridId) {
        if (gridOrder && gridOrder.length > 1) {
            var idx = gridOrder.indexOf(gridId)
            if (idx !== -1) {
                return gridOrder[(idx + 1) % gridOrder.length]
            }
        }
        return gridId === cpuGridId ? playerGridId : cpuGridId
    }

    function resetAllState() {
        turnStateCoordinator.clear()
        activeGrid = -1
        attackerGridId = -1
        defenderGridId = -1
    }

    function beginTurn(gridId, options) {
        var moves = movesPerTurn
        if (options && options.moves !== undefined) {
            moves = options.moves
        }
        attackerGridId = gridId
        defenderGridId = otherGrid(gridId)
        activeGrid = gridId

        var attackerState = turnStateCoordinator.resetForTurn(gridId, moves)
        turnStateCoordinator.configureOpponent(defenderGridId)

        AppActions.enableBlocks(gridId, false)
        AppActions.beginFillCycle(gridId, "turnStart")
        AppActions.setFillingEnabled(gridId, true)
        AppActions.setLaunchOnMatchEnabled(gridId, true)

        AppActions.setFillingEnabled(defenderGridId, false)
        AppActions.setLaunchOnMatchEnabled(defenderGridId, false)

        AppActions.turnCycleTurnBegan({
                                           "grid_id": gridId,
                                           "defender_grid_id": defenderGridId,
                                           "moves_remaining": attackerState.movesRemaining,
                                           "phase": attackerState.phase
                                       })
        AppActions.turnCycleTurnResolving({
                                               "grid_id": gridId,
                                               "moves_remaining": attackerState.movesRemaining,
                                               "phase": attackerState.phase
                                           })
        AppActions.setActiveGrid(gridId)
    }

    function handleSwapStarted(data) {
        var gridId = data.grid_id
        if (gridId !== activeGrid) {
            return
        }
        if (!turnStateCoordinator.readyForInput(gridId)) {
            return
        }
        var swapResult = turnStateCoordinator.markSwapStarted(gridId)
        AppActions.turnCycleTurnResolving({
                                               "grid_id": gridId,
                                               "moves_remaining": swapResult.state.movesRemaining,
                                               "phase": swapResult.state.phase
                                           })
        if (swapResult.quotaReached) {
            AppActions.enableBlocks(gridId, false)
        }
        AppActions.swapLaunchingStarted({
                                             "grid_id": gridId,
                                             "moves_remaining": swapResult.state.movesRemaining,
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
        var state = gridState(gridId)
        if (!state.pendingMove && state.pendingLaunches === 0) {
            return
        }
        state = turnStateCoordinator.markAnimationsCompleted(gridId)
        AppActions.turnCycleTurnResolving({
                                               "grid_id": gridId,
                                               "moves_remaining": state.movesRemaining,
                                               "phase": state.phase
                                           })
    }

    function handleGridSettled(info) {
        if (!info || info.grid_id === undefined) {
            return
        }
        var gridId = info.grid_id
        var state = turnStateCoordinator.markSettlement(gridId, info.has_empty === true)
        if (info.has_empty === true) {
            AppActions.beginFillCycle(gridId, "autoFill")
            return
        }
        var pendingTurn = turnStateCoordinator.consumeHandOff(gridId)
        if (pendingTurn) {
            beginTurn(gridId, {
                          "moves": pendingTurn.moves
                      })
            return
        }
        if (gridId === activeGrid) {
            if (turnStateCoordinator.canFinishTurn(gridId)) {
                finishTurn(gridId)
            } else if (turnStateCoordinator.readyForInput(gridId)) {
                AppActions.turnCycleTurnReady({
                                                 "grid_id": gridId,
                                                 "moves_remaining": state.movesRemaining,
                                                 "phase": state.phase
                                             })
                AppActions.enableBlocks(gridId, true)
                if (gridId === cpuGridId) {
                    maybeRequestCpuMove()
                }
            } else {
                AppActions.turnCycleTurnResolving({
                                                   "grid_id": gridId,
                                                   "moves_remaining": state.movesRemaining,
                                                   "phase": state.phase
                                               })
            }
        } else {
            state.phase = "waitingOpponent"
        }
    }

    function finishTurn(gridId) {
        var nextGrid = otherGrid(gridId)
        var attackerState = gridState(gridId)
        attackerState.phase = "waitingOpponent"
        attackerState.awaitingSettlement = false
        attackerState.pendingMove = false
        AppActions.enableBlocks(gridId, false)
        AppActions.turnCycleTurnResolving({
                                           "grid_id": nextGrid,
                                           "moves_remaining": movesPerTurn,
                                           "phase": "waitingHandshake"
                                       })
        turnStateCoordinator.planHandOff(gridId, nextGrid, movesPerTurn)
        activeGrid = -1
        turnStateCoordinator.markHandOffReadyIfSettled(nextGrid)
        var readyTurn = turnStateCoordinator.consumeHandOff(nextGrid)
        AppActions.requestNextTurn({
                                        "from_grid_id": gridId,
                                        "to_grid_id": nextGrid
                                    })
        if (readyTurn) {
            beginTurn(nextGrid, {
                          "moves": readyTurn.moves
                      })
        }
    }

    function maybeRequestCpuMove() {
        if (activeGrid !== cpuGridId) {
            return
        }
        var state = gridState(cpuGridId)
        if (!turnStateCoordinator.readyForInput(cpuGridId)) {
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
            gridState(attacker)
            gridState(defender)
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
            turnStateCoordinator.recordBlocksEnabled(data.grid_id, data.blocks_enabled)
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
            var state = gridState(activeGrid)
            state.movesRemaining = 0
            state.pendingMove = false
            state.swapsStarted = state.movesAllowed
            finishTurn(activeGrid)
        }
    }
}
