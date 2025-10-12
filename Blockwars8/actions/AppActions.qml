pragma Singleton

import QtQuick 2.0
import QuickFlux 1.1
import "../components" 1.0
import "../stores" 1.0


ActionCreator {
    id: obj_inst
    signal startApp

    signal enterZoneMainMenu
    signal quitApp

    function executeGridEvent(grid_event) {

        AppDispatcher.dispatch("executeGridEvent", grid_event)
    }
    function gridEventDone(grid_event) {

        AppDispatcher.dispatch("gridEventDone", grid_event)
    }

    function blockFireAtTarget(i_data) {
        AppDispatcher.dispatch(ActionTypes.blockFireAtTarget, i_data)
    }

    function blockKilledFromFrontEnd(i_data) {
        AppDispatcher.dispatch(ActionTypes.blockKilledFromFrontEnd, i_data)
    }

    function particleBlockKilledExplodeAtGlobal(i_data) {
        AppDispatcher.dispatch(ActionTypes.particleBlockKilledExplodeAtGlobal,
                               i_data)
    }

    function particleBlockLaunchedGlobal(i_data) {
        AppDispatcher.dispatch(ActionTypes.particleBlockLaunchedGlobal, i_data)
    }
    function blockLaunchCompleted(i_data) {
        AppDispatcher.dispatch(ActionTypes.blockLaunchCompleted, i_data)
    }
    function enqueueGridEvent(eventType, grid_id, eventParams) {
        var params = eventParams
        params.event_type = eventType
        params.grid_id = grid_id

        AppDispatcher.dispatch(ActionTypes.enqueueGridEvent, params)
    }

    function createOneShotTimer(element, duration, action, params) {
        var comp = Qt.createComponent(
                    'qrc:///Blockwars8/components/SingleShotTimer.qml')
        comp.createObject(element, {
                              "action": action,
                              "interval": duration,
                              "element": element,
                              "params": params
                          })
    }

    function fillGrid(grid_id, end_move_after) {
        AppDispatcher.dispatch(ActionTypes.fillGrid, {
                                   "grid_id": grid_id,
                                   "end_move_after": end_move_after
                               })
    }
    function beginFillCycle(grid_id, source_event) {
        AppDispatcher.dispatch(ActionTypes.beginFillCycle, {
                                   "grid_id": grid_id,
                                   "source_event": source_event
                               })
    }
    function createOneBlock(grid_id, row, column) {
        AppDispatcher.dispatch(ActionTypes.createOneBlock, {
                                   "grid_id": grid_id,
                                   "row": row,
                                   "column": column
                               })
    }
    function swapBlocks(row, column, grid_id, direction) {
        AppDispatcher.dispatch(ActionTypes.swapBlocks, {
                                   "row": row,
                                   "column": column,
                                   "grid_id": grid_id,
                                   "direction": direction
                               })
    }
    function enableBlocks(grid_id, blocks_enabled) {
        AppDispatcher.dispatch(ActionTypes.enableBlocks, {
                                   "grid_id": grid_id,
                                   "blocks_enabled": blocks_enabled
                               })
    }

    function setFillingEnabled(grid_id, enabled) {
        AppDispatcher.dispatch(ActionTypes.setFillingEnabled, {
                                   "grid_id": grid_id,
                                   "enabled": enabled === true
                               })
    }

    function setLaunchOnMatchEnabled(grid_id, enabled) {
        AppDispatcher.dispatch(ActionTypes.setLaunchOnMatchEnabled, {
                                   "grid_id": grid_id,
                                   "enabled": enabled === true
                               })
    }

    function powerupEnergyDelta(grid_id, slot_id, color, amount, reason) {
        AppDispatcher.dispatch(ActionTypes.powerupEnergyDelta, {
                                   "grid_id": grid_id,
                                   "slot_id": slot_id,
                                   "color": color,
                                   "amount": amount,
                                   "reason": reason
                               })
    }

    function powerupEnergyReset(grid_id, slot_id) {
        AppDispatcher.dispatch(ActionTypes.powerupEnergyReset, {
                                   "grid_id": grid_id,
                                   "slot_id": slot_id
                               })
    }

    function powerupReadyState(grid_id, slot_id, ready) {
        AppDispatcher.dispatch(ActionTypes.powerupReadyState, {
                                   "grid_id": grid_id,
                                   "slot_id": slot_id,
                                   "ready": ready === true
                               })
    }

    function requestPowerupDeployment(params) {
        var payload = {}
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.deployPowerupRequest, payload)
    }

    function confirmPowerupDeployment(params) {
        var payload = {}
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.deployPowerupApplied, payload)
    }

    function executePowerupAbility(params) {
        var payload = {}
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.executePowerupAbility, payload)
    }

    function applyPowerupBlocksEffect(params) {
        var payload = {}
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.applyPowerupBlocksEffect, payload)
    }

    function applyPowerupCardHealth(params) {
        var payload = {}
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.applyPowerupCardHealth, payload)
    }

    function powerupPlayerHealthDelta(grid_id, amount, reason) {
        AppDispatcher.dispatch(ActionTypes.powerupPlayerHealthDelta, {
                                   "grid_id": grid_id,
                                   "amount": amount,
                                   "reason": reason
                               })
    }

    // sent from players immediately upon making a swap, however it will not be executed on the remote client's
    //  game until their game has completed the grid events and is idle.
    //  this small requirement essentially will avoid any desync from happening as far as game timing, and will
    //   require an implementation of a NetworkEventQueue which will hold the last received network event until its needed
    //   then pass it as a GridEvent and send back the NetworkEventDone response so the client who sends the
    //   NetworkEvent will stop blocking and proceed to the next gridEvent
    //  This small additional requirement means that the network event flow will have to be enapsulated into a GridEvent on
    //   the sender's game and then wait to perform the next event until the NetworkEventDone signal is received back.
    //   this will go a long way towards eliminating lag-related unexpected behavior on the receivng client's game.
    //  consequently, it will also prevent speed-hacking because both games will have to be fully caught up in order
    //   to successfully complete a move. This also solves issues related to slower devices, but does not really
    //   address issues such as losing network connectivity and rejoining -- that will have to be implemented using
    //   a very low ping timeout on the server or a KEEPALIVE system. Both need to be implemented into  the logic which
    //   controls what happens to NetworkEvents that don't receive NetworkEventDone
    function sendNetworkEvent(eventType, eventParams) {
        var params = eventParams
        params.event_type = eventType

        AppDispatcher.dispatch(ActionTypes.sendNetworkEvent, params)
    }
    function receiveNetworkEvent(params) {
        AppDispatcher.dispatch(ActionTypes.receiveNetworkEvent, params)
    }
    function sendNetworkEventDone(eventParams) {
        AppDispatcher.dispatch(ActionTypes.sendNetworkEventDone, eventParams)
    }
    function receiveNetworkEventDone(eventParams) {
        AppDispatcher.dispatch(ActionTypes.sendNetworkEventDone, eventParams)
    }
    function sendGameStateEvent(gameState, eventParams) {
        var params = eventParams
        params.gameState = gameState
        AppDispatcher.dispatch(ActionTypes.sendGameStateEvent, params)
    }
    function initializeTurnCycle(params) {
        var payload = {
            "attacker_grid_id": params && params.attacker_grid_id !== undefined ? params.attacker_grid_id : 0,
            "defender_grid_id": params && params.defender_grid_id !== undefined ? params.defender_grid_id : 1,
            "moves": params && params.moves !== undefined ? params.moves : 3
        }
        if (params && params.context !== undefined) {
            payload.context = params.context
        }
        AppDispatcher.dispatch(ActionTypes.initializeTurnCycle, payload)
    }
    function requestNextTurn(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.requestNextTurn, payload)
    }
    function turnCycleTurnBegan(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.turnCycleTurnBegan, payload)
    }
    function swapLaunchingStarted(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.swapLaunchingStarted, payload)
    }
    function swapLaunchingAnimationsDone(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.swapLaunchingAnimationsDone, payload)
    }
    function informGridFillInNeeded(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.informGridFillInNeeded, payload)
    }
    function cpuRequestMove(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.cpuRequestMove, payload)
    }
    function cpuMoveUnavailable(grid_id, details) {
        var payload = { "grid_id": grid_id }
        if (details) {
            for (var key in details) {
                if (details.hasOwnProperty(key) && key !== "grid_id") {
                    payload[key] = details[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.cpuMoveUnavailable, payload)
    }

    function resetSinglePlayerPowerupSelection(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.singlePlayerSelectionReset, payload)
    }

    function setSinglePlayerPowerupSelection(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.singlePlayerSelectionSet, payload)
    }

    function confirmSinglePlayerPowerupSelection(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.singlePlayerSelectionConfirmed, payload)
    }

    function gridSettled(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.gridSettled, payload)
    }

    function cascadeEnded(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.cascadeEnded, payload)
    }

    function requestGridSnapshot(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.requestGridSnapshot, payload)
    }

    function gridSnapshotProvided(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.gridSnapshotProvided, payload)
    }


    function gameBoardDashboardsReady(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.gameBoardDashboardsReady, payload)
    }

    function requestGameBoardSeed(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.gameBoardSeedRequested, payload)
    }

    function acknowledgeGameBoardSeed(params) {
        var payload = { }
        if (params) {
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    payload[key] = params[key]
                }
            }
        }
        AppDispatcher.dispatch(ActionTypes.gameBoardSeedAcknowledged, payload)
    }

    function setBlockProperty(row, col, grid_id, propName, propValue) {
        var params = ({
                          "row": row,
                          "col": col,
                          "grid_id": grid_id,
                          "propName": propName,
                          "propValue": propValue
                      })
        AppDispatcher.dispatch(ActionTypes.setBlockProperty, params)
    }

    function activatePowerup(slot_id, grid_id) {
        console.log("Activating powerup", slot_id, grid_id)
        var runtime = MainStore.powerup_runtime_state || {}
        var gridState = runtime[String(grid_id)]
        if (!gridState || !gridState.slots) {
            return
        }
        var slotState = gridState.slots[String(slot_id)]
        if (!slotState) {
            return
        }
        var payload = {
            "slot_id": slot_id,
            "grid_id": grid_id,
            "ability": JSON.parse(JSON.stringify(slotState))
        }
        AppDispatcher.dispatch(ActionTypes.activatePowerup, payload)
        executePowerupAbility(payload)
    }
    function modifyBlockHealth(row, column, grid_id, amount) {
        var params = ({
                          "row": row,
                          "column": column,
                          "grid_id": grid_id,
                          "amount": amount
                      })
        AppDispatcher.dispatch(ActionTypes.modifyBlockHealth, params)
    }
    function setActiveGrid(grid_id) {
        var params = ({ "grid_id": grid_id })
        AppDispatcher.dispatch(ActionTypes.setActiveGrid, params)
    }
}
