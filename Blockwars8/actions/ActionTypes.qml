pragma Singleton

import QtQuick 2.0
import QuickFlux 1.1

KeyTable {
    // Call it when the initialization is finished.
    // Now, it is able to start and show the application
    property string startApp

    property string enterZoneMainMenu

    // Call it to quit the application
    property string quitApp

    property string executeGridEvent

    property string enqueueGridEvent
    property string gridEventDone
    property string blockLaunchCompleted
    property string blockFireAtTarget: "blockFireAtTarget"
    property string blockKilledFromFrontEnd: "blockKilledFromFrontEnd"
    property string particleBlockKilledExplodeAtGlobal: "particleBlockKilledExplodeAtGlobal"
    property string particleBlockLaunchedGlobal: "particleBlockLaunchedGlobal"
    property string fillGrid: "fillGrid"
    property string beginFillCycle: "beginFillCycle"
    property string createOneBlock: "createOneBlock"
    property string swapBlocks: "swapBlocks"
    property string enableBlocks: "enableBlocks"
    property string sendNetworkEvent: "sendNetworkEvent"
    property string receiveNetworkEvent: "receiveNetworkEvent"
    property string sendNetworkEventDone: "sendNetworkEventDone"
    property string receiveNetworkEventDone: "receiveNetworkEventDone"

    // send this when board has no matches and no empty squares
    // game states:   gameWaitingForMove
    //                gameWaitingForTurn
    //                gameWaitingForNetwork
    //                gameWaitingForGrid
    property string sendGameStateEvent: "sendGameStateEvent"


    property string setBlockProperty: "setBlockProperty"
    property string activatePowerup: "activatePowerup"
    property string initializeTurnCycle: "initializeTurnCycle"
    property string requestNextTurn: "requestNextTurn"
    property string turnCycleTurnBegan: "turnCycleTurnBegan"
    property string swapLaunchingStarted: "swapLaunchingStarted"
    property string swapLaunchingAnimationsDone: "swapLaunchingAnimationsDone"
    property string informGridFillInNeeded: "informGridFillInNeeded"
    property string cpuRequestMove: "cpuRequestMove"
    property string cpuMoveUnavailable: "cpuMoveUnavailable"

    property string modifyBlockHealth: "modifyBlockHealth"

    property string setActiveGrid: "setActiveGrid"

    property string singlePlayerSelectionReset: "singlePlayerSelectionReset"
    property string singlePlayerSelectionSet: "singlePlayerSelectionSet"
    property string singlePlayerSelectionConfirmed: "singlePlayerSelectionConfirmed"
    property string gridSettled: "gridSettled"

    property string gameBoardDashboardsReady: "gameBoardDashboardsReady"
    property string gameBoardSeedRequested: "gameBoardSeedRequested"
    property string gameBoardSeedAcknowledged: "gameBoardSeedAcknowledged"
    property string cascadeEnded: "cascadeEnded"
    property string requestGridSnapshot: "requestGridSnapshot"
    property string gridSnapshotProvided: "gridSnapshotProvided"
}
