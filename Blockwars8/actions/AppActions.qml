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
    function runFunctionOnGrid(grid_id, input_function, eventData) {
        AppDispatcher.dispatch(ActionTypes.runFunctionOnGrid, { grid_id: grid_id, input_function: input_function, input_data: eventData })
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
                                   "end_move_after": end_move_after,

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
    function enablePowerups(grid_id, enabled) {
        // Stubbed action for future wiring
        AppDispatcher.dispatch(ActionTypes.enablePowerups, {
                                   "grid_id": grid_id,
                                   "enabled": enabled
                               })
    }

    function beginFillCycle(grid_id, reason) {
        AppDispatcher.dispatch(ActionTypes.beginFillCycle, {
                                   "grid_id": grid_id,
                                   "reason": reason
                               })
    }

    function setFillingEnabled(grid_id, enabled) {
        AppDispatcher.dispatch(ActionTypes.setFillingEnabled, {
                                   "grid_id": grid_id,
                                   "enabled": enabled
                               })
    }

    function setLaunchOnMatchEnabled(grid_id, enabled) {
        AppDispatcher.dispatch(ActionTypes.setLaunchOnMatchEnabled, {
                                   "grid_id": grid_id,
                                   "enabled": enabled
                               })
    }

    function swapLaunchingStarted(payload) {
        AppDispatcher.dispatch(ActionTypes.swapLaunchingStarted, payload)
    }

    function turnCycleTurnBegan(payload) {
        AppDispatcher.dispatch(ActionTypes.turnCycleTurnBegan, payload)
    }

    function turnCycleTurnResolving(payload) {
        AppDispatcher.dispatch(ActionTypes.turnCycleTurnResolving, payload)
    }

    function turnCycleTurnReady(payload) {
        AppDispatcher.dispatch(ActionTypes.turnCycleTurnReady, payload)
    }

    function requestNextTurn(payload) {
        AppDispatcher.dispatch(ActionTypes.requestNextTurn, payload)
    }

    function cpuRequestMove(payload) {
        AppDispatcher.dispatch(ActionTypes.cpuRequestMove, payload)
    }

    function informGridFillInNeeded(payload) {
        AppDispatcher.dispatch(ActionTypes.informGridFillInNeeded, payload)
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
        var powerupArray = []
        console.log("Activating powerup", slot_id, grid_id)
        if (grid_id == 0) {
            powerupArray = MainStore.my_powerup_data
        }
        if (grid_id == 1) {
            powerupArray = MainStore.enemy_powerup_data
        }
        console.log("Poweup Data", JSON.stringify(powerupArray))
        var powerupType = getPowerupProperty(powerupArray, slot_id,
                                             grid_id, "type")
        var powerupTarget = getPowerupProperty(powerupArray, slot_id,
                                               grid_id, "target")
        var _powerupAmount = getPowerupProperty(powerupArray, slot_id,
                                                grid_id, "amount")
        var powerupAmount = 0
        var powerupEnergy = getPowerupProperty(powerupArray, slot_id,
                                               grid_id, "energy")
        var target_grid_id = powerupTarget
        console.log(powerupType, powerupTarget, _powerupAmount, powerupEnergy)
        if (powerupTarget == "self") {
            powerupAmount = Math.abs(_powerupAmount)
            target_grid_id = grid_id
        }
        if (powerupTarget == "opponent") {
            powerupAmount = 0 - Math.abs(_powerupAmount)
            if (grid_id == 0) {
                target_grid_id = 1
            } else {
                target_grid_id = 0
            }
        }
        if (powerupType == "blocks") {
            var powerupGrid = getPowerupProperty(powerupArray, slot_id,
                                                 grid_id, "grid")
            for (var a = 0; a < 6; a++) {

                for (var b = 0; b < 6; b++) {
                    var idx = (a * 6) + b
                    if (powerupGrid[idx] == true) {

                        if (powerupTarget == "self")
                            console.log("Modify blockhealth", target_grid_id,
                                        a, b, powerupAmount)
                        AppActions.modifyBlockHealth(a, b, target_grid_id,
                                                     powerupAmount)
                    }
                }
            }
        }
        if (powerupType == "heros") {

        }
        if (powerupType == "health") {

        }
    }
    function getPowerupProperty(powerupArray, slot_id, grid_id, powerupProperty) {
        for (var i = 0; i < powerupArray.length; ++i) {
            var powerupObject = powerupArray[i]
            if (i == slot_id) {
                return powerupObject[powerupProperty]
            }
        }
        return null
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
    function cascadeSettled(grid_id) {
        var params = ({"grid_id" : grid_id })
        AppDispatcher.dispatch(ActionTypes.cascadeSettled, params)
    }
    function endTurn(grid_id) {
        var params = ({ "grid_id": grid_id })
        AppDispatcher.dispatch(ActionTypes.endTurn, params)
    }
}
