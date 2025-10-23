import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
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
import "../controllers" 1.0
import "../elements" 1.0
import "../components" 1.0
import "../components/components.js" as JS
import QtQuick.Particles 2.0
import "." 1.0
import "../lib"

Item {
    id: gridRoot
    width: 300
    height: 300
    property var maxColumn: 6
    property var maxRow: 6
    property var maxIndex: maxColumn * maxRow
    property var board: new Array(maxIndex)
    property var grid_id: 0

    property var current_event
    property var animationCount: 0
    property var grid_blocks: []
    property var launchCount: 0
    property var launchList: []
    property var initialFill: true
    property var activeTurn: true
    property var turns: 3
    property string turnPhase: "idle"
    property var cascadeSettledPromise

    property var controller

    ParticleSystem {
        id: particleSystem
    }
    BlockExplodeParticle {
        id: particleController
        anchors.fill: gridRoot
        z: 5000
        system: particleSystem
    }

    //Index function used instead of a 2D array
    function index(row, column) {
        return column + (row * maxColumn)
    }


    /*
     *
     *    grid event flux listener that receives inbound requests
     *    from GridController
    */
    AppListener {
        filter: ActionTypes.executeGridEvent
        onDispatched: function (type, msg) {

            var event = msg
            var event_grid_id = event.grid_id
            if (event_grid_id == grid_id) {
                console.log("game grid got event request", JSON.stringify(msg))
                handleGridEventExecute(event)
            }
        }
    }

    AppListener {
        filter: ActionTypes.blockLaunchCompleted
        onDispatched: function (dtype, ddata) {
            if (ddata.grid_id == grid_id) {

                animationCount--
                launchCount--
                var row = ddata.row
                var column = ddata.column
                //grid_blocks[index(row, column)] = null
                //board[index(row, column)] = null
                AppActions.gridEventDone(current_event)
                //  launchCount--
           //     console.log("Launch Completed", JSON.stringify(ddata),
//                            "launch count is", launchCount)
                if (launchCount <= 0) {
                    createOneShotTimer(gridRoot, (50 + (25 * 6) + (25 * 6)),
                                       function (params) {
                                           AppActions.enqueueGridEvent(
                                                       "shuffleDown",
                                                       params.grid_id, ({}))
                                       }, {
                                           "grid_id": grid_id
                                       })
                } else {

                }
            } else {
         //       console.log("detected block launch complete from other grid", JSON.stringify(ddata))
                var current_healths = [];
                var incoming_dmg = ddata.damage;
                var current_col = 5 - ddata.column;
                for (var u=5; u>=0; u--) {
                    if (grid_blocks[index(u, current_col)] != null) { current_healths.push(grid_blocks[index(u, current_col)].block_health); } else { current_healths.push(0); }
                }
          //      console.log("current block healths on",current_col,current_healths);
                var destroy_list = [];

                for (u=0; u<current_healths.length; u++) {
                if (current_healths[u] > 0) {
                    if (incoming_dmg > 0) {
                        var blk_health = current_healths[u];
                        current_healths[u] -= incoming_dmg;
                        incoming_dmg -= blk_health;


                        if (!initialFill) {
               //             console.log("modifying block health", 5 - u,current_col,grid_id, current_healths[u])
                            AppActions.modifyBlockHealth( 5 - u, current_col, grid_id, current_healths[u])
                        } else {
      //                      console.log("Not modifying health due to initialFill flag");
                        }
                        if (incoming_dmg < 1) { incoming_dmg = 0; break; }

                    } else {
                     break;
                    }
                } else {
                 continue;
                }
                }


            }
        }
    }
    AppListener {
        filter: ActionTypes.setActiveGrid
        onDispatched: function (dtype, ddata) {
            activeTurn = ddata.grid_id == grid_id;
            if (!activeTurn) {
                turns = 0;
                turnPhase = "waitingOpponent";
            } else {
                turns = 3
                activeTurn = true
                AppActions.setFillingEnabled(grid_id, true);
                turnPhase = "idle"
                cleanupBlocks()
                //AppActions.enqueueGridEvent("shuffleDown", grid_id, ({}));
                 refill()
            }
        }
    }

    AppListener {
        filter: ActionTypes.turnCycleTurnBegan
        onDispatched: function (dtype, ddata) {
            if (ddata.grid_id === grid_id) {
                activeTurn = true;
                if (ddata.moves_remaining !== undefined) {
                    turns = ddata.moves_remaining;
                }
                turnPhase = ddata.phase !== undefined ? ddata.phase : "settling";
            } else if (ddata.defender_grid_id === grid_id) {
                activeTurn = false;
                turns = 0;
                turnPhase = "waitingOpponent";
            }
        }
    }

    AppListener {
        filter: ActionTypes.turnCycleTurnResolving
        onDispatched: function (dtype, ddata) {
            if (ddata.grid_id === grid_id) {
                if (ddata.moves_remaining !== undefined) {
                    turns = ddata.moves_remaining;
                }
                turnPhase = ddata.phase !== undefined ? ddata.phase : "resolving";
            }
        }
    }

    AppListener {
        filter: ActionTypes.turnCycleTurnReady
        onDispatched: function (dtype, ddata) {
            if (ddata.grid_id === grid_id) {
                if (ddata.moves_remaining !== undefined) {
                    turns = ddata.moves_remaining;
                }
                turnPhase = ddata.phase !== undefined ? ddata.phase : "awaitingInput";
            }
        }
    }

    function handleGridEventExecute(event) {
        var event_type = event.event_type
        if (typeof event.startup_function == "function") {
            startup_function(event)
        }
        if (event_type == "shuffleDown") {
            shuffleDown(event)
        }
        if (event_type == "createBlocks") {
            createBlocks(event)
        }
        if (event_type == "checkMatches") {
            checkMatches(event)
        }
        if (event_type == "launchBlock") {
            launchBlock(event)
        }
        if (event_type == "createOneBlock") {
            createOneBlock(event)
        }
        if (event_type == "disableInitialFill") {
            initialFill = false;

             AppActions.gridEventDone(event)
        }
        if (event_type == "setActive") {
            AppActions.setActiveGrid(grid_id);
            shuffleTimer.start();
            activeTurn = true;

            AppActions.gridEventDone(event)
            AppActions.enqueueGridEvent("checkMatches", grid_id, ({}));
        }
        if (event_type == "cascadeSettled") {
            AppActions.cascadeSettled(grid_id)
            AppActions.gridEventDone(event)
            console.log("**** Cascade Settled ****");
        }
        if (event_type == "swapBlocks") {
            if (initialFill) {
                AppActions.enqueueGridEvent("disableInitialFill", 0, ({}));
                AppActions.enqueueGridEvent("disableInitialFill", 1, ({}))
            }
            if (activeTurn) {
                turns--;
                var blk1 = grid_blocks[index(event.row1, event.column1)]
                var blk2 = grid_blocks[index(event.row2, event.column2)]
                var r1 = blk1.row
                var r2 = blk2.row
                var c1 = blk1.column
                var c2 = blk2.column
                blk1.row = r2
                blk1.column = c2
                blk2.row = r1
                blk2.column = c1

                grid_blocks[index(r1, c1)] = blk2
                grid_blocks[index(r2, c2)] = blk1
                blk1.x = blk1.column * blk1.width
                blk1.y = blk1.row * blk1.height
                blk2.x = blk2.column * blk2.width
                blk2.y = blk2.row * blk2.height

                AppActions.gridEventDone(event)
                AppActions.enqueueGridEvent("checkMatches", grid_id, ({cascadePromise: createCascadeSettledPromise(grid_id), callback: function(evtdata) { console.log("**** match checking callback executed ***"); }}))
                AppActions.enableBlocks(grid_id, false)

            }
        }
    }


    /*
     *
     *    grid event functions area
    */
    Timer {
        id: shuffleTimer
        interval: 100 // Delay in milliseconds
        repeat: false
        running: false
        triggeredOnStart: false
        onTriggered: shuffleDownStep()
    }

    function shuffleDownStep(event) {
        let madeChange = false
        for (var i = 5; i >= 0; i--) {
            for (var u = 0; u < 6; u++) {
                if (grid_blocks[index(i, u)] == null) {
                    for (var a = i; a >= 0; a--) {
                        if ((a - 1) >= 0) {

                            grid_blocks[index(a,
                                              u)] = grid_blocks[index(a - 1, u)]
                            grid_blocks[index(a - 1, u)] = null
                            if (grid_blocks[index(a - 1, u)] != null) {
                                madeChange = true
                            }
                            if (grid_blocks[index(a, u)] != null) {

                                grid_blocks[index(a, u)].row = a
                                grid_blocks[index(
                                                a,
                                                u)].y = (a) * grid_blocks[index(
                                                                              a, u)].height
                            }
                        } else {
                            grid_blocks[index(a, u)] = null
                        }
                    }
                }
            }
        }
        if (madeChange) {

        } else {

        }
        var gotEmpty = false
        var grid_array = grid_blocks.map(function (item) {
            if (item != null) {
                return item.row
            } else {
                return -1
            }
        })
        if (grid_array.indexOf(-1) > -1) {
            for (var b = 5; b >= 0; b--) {
                for (var c = 0; c < 6; c++) {
                    if (grid_blocks[index(b, c)] == null) {
                        AppActions.createOneBlock(grid_id, b, c)
                        gotEmpty = true
                    }
                }
            }
            //  shuffleDownStep(event)
        } else {

        }
        updateBlocks(i)
        //console.log()
        if (gotEmpty) {
            shuffleTimer.restart()
            if (typeof event != "undefined") {
                AppActions.fillGrid(grid_id, false, cascadeSettledPromise)
            } else {
                AppActions.fillGrid(grid_id, false)
            }
                AppActions.gridEventDone(event)


        } else {
            AppActions.gridEventDone(event)
            if (typeof event != "undefined") {
                AppActions.enqueueGridEvent("checkMatches", grid_id, {cascadePromise: cascadeSettledPromise})
            } else {
                   AppActions.enqueueGridEvent("checkMatches", grid_id, {})
            }
        }
    }

    function shuffleDown(event) {

        shuffleTimer.start()
    }
    function countDrops(gridObj) {
        // Initialize an object to store the number of rows each cell would drop
        const drops = ({})

        // Loop through each column
        for (var j = 0; j < 6; j++) {
            // Initialize a counter for the next position in the new grid
            let nextPosition = 5

            // Loop through each row from bottom to top
            for (var i = 5; i >= 0; i--) {
                // Calculate the index for the original grid
                const originalIndex = i * 6 + j

                // If the cell exists and is not -1
                if (gridObj[originalIndex]
                        && gridObj[originalIndex].value != -1) {
                    // Calculate the number of rows this cell would drop
                    drops[originalIndex] = nextPosition - i

                    // Move the next position one row up
                    nextPosition--
                }
            }
        }
        //console.log(JSON.stringify(drops))
        return drops
    }
    function handleBlockAnimationDoneEvent() {
        animationCount--
        if (animationCount == 0) {

            //  AppActions.gridEventDone(current_event)
        }
    }
    function handleBlockAnimationStartEvent() {
        animationCount++
    }
    function createOneBlock(event) {
        var i = event.column
        var u = event.row
        //console.log("Creating block", u, "for column", i)
        var blkW = Math.floor(gridRoot.width / 6)
        var blkH = Math.floor(gridRoot.height / 6)
        var startY = (blkH * u) - (blkH * 6)
        var blkRow = u
        var blkCol = i
        var block_color
        switch (event.color) {
        case 0:
            block_color = "red"
            break
        case 1:
            block_color = "blue"
            break
        case 2:
            block_color = "yellow"
            break
        case 3:
            block_color = "green"
            break
        default:
            block_color = "white"
        }
        for (var p = 0; p < 6; p++) {
            if (grid_blocks[index(p, blkCol)] == null) {
                blkRow = p
            } else {
                break
            }
        }

        //console.log("creating block", blkRow, blkCol, blkH, blkW)
        var blk = blockComponent.createObject(gridRoot, {
                                                  "x": blkW * blkCol,
                                                  "y": startY,
                                                  "row": blkRow,
                                                  "column": blkCol,
                                                  "width": blkW,
                                                  "height": blkH,
                                                  "block_color": block_color,
                                                  "grid_id": grid_id
                                              })
        blk.row = blkRow
        blk.column = blkCol

        blk.animationStart.connect(handleBlockAnimationStartEvent)
        blk.animationDone.connect(handleBlockAnimationDoneEvent)
        blk.rowUpdated.connect(updateBlocks)
        blk.rowUpdated.connect(repositionGridBlocks)
        grid_blocks[index(blkRow, blkCol)] = blk
        blk.y = (blkH * blkRow)
        AppActions.gridEventDone(event)
    }

    // called from handleGridEventExecute(event) only - must be queued as a "createBlocks" grid event using enqueueGridEvent
    // creates blocks from event.create_counts object with this format {"<column_num>": {"missing":<num_empty cells in column>", "new_colors": ["red", "green", "yellow", "green"]}, "<column_num>":...}
    function createBlocks(event) {
        var counts = event.create_counts
        current_event = event
        for (var i = 0; i < 6; i++) {
            var columnCounts = counts[String(i)].missing
            var new_colors = counts[String(i)].new_colors
            var colorsRemaining = new_colors.length
            if (colorsRemaining <= 0) {
                continue
            }
            for (var u = 0; u < 6; u++) {
                if (colorsRemaining <= 0) {
                    break
                }
                // Only create blocks for currently empty rows in this column
                if (!isBlockAt(u, i)) {
                    var blkW = Math.floor(gridRoot.width / 6)
                    var blkH = Math.floor(gridRoot.height / 6)
                    var startY = (blkH * u) - (blkH * 6)
                    var blkRow = u
                    var blkCol = i

                    var blk = blockComponent.createObject(gridRoot, {
                                                              "x": blkW * blkCol,
                                                              "y": startY,
                                                              "row": blkRow,
                                                              "column": blkCol,
                                                              "width": blkW,
                                                              "height": blkH,
                                                              "block_color": new_colors.shift(),
                                                              "grid_id": grid_id
                                                          })
                    blk.row = blkRow
                    blk.column = blkCol

                    blk.animationStart.connect(handleBlockAnimationStartEvent)
                    blk.animationDone.connect(handleBlockAnimationDoneEvent)
                    blk.rowUpdated.connect(updateBlocks)
                    blk.rowUpdated.connect(repositionGridBlocks)

                    grid_blocks[index(blkRow, blkCol)] = blk
                    blk.y = (blkH * blkRow)

                    colorsRemaining--
                }
            }
        }

        AppActions.gridEventDone(current_event)
    }
    function repositionGridBlocks(row) {
        for (var i = 0; i < 6; i++) {
            var rowCount = 0
            for (var u = 0; u < 6; u++) {
                if (grid_blocks[index(i, u)] != null) {
                    grid_blocks[index(i,
                                      u)].y = i * grid_blocks[index(i,
                                                                    u)].height
                } else {

                }
            }
        }
    }
    function updateBlocks(row) {
        /*  for (var i = 0; i < 6; i++) {
            var rowCount = 0
            for (var u = 0; u < 6; u++) {

                var blk = grid_blocks[index(u, i)]
                if (blk == null) {
                    continue
                } else {
                    //     console.log("block ", u, i, "is now", rowCount, i)
                    blk.y = (grid_blocks.height / 6) * rowCount
                    grid_blocks[index(rowCount, i)] = blk

                    rowCount++
                }
            }
            for (var c = rowCount; c < 6; c++) {
                grid_blocks[index(c, i)] = null
            }
        } */
    }


    // only called from handleGridEventExecute(event) which executes grid events that have been enqueued using enqueueGridEvent, with type "checkMatches"
    // does not work to call directly due to animation / block launch / drop in delays which all have multiple steps to them and are depedent on completion of previous events
    function checkMatches(event) {
      //  cleanupBlocks()
        updateAnimationCounts()

        if (animationCount > 0) {

            // if animations are happening, then we give them time to complete all the way using a OneShotTimer
            // this will enqueue a totally new grid event so that all of the lauch sequences will complete before this one is called.
            // which we also pass along the cascadePromise that is created when swapping blocks so that when the cascade cascadePromise resolves, it will either unlock board or switch turns


            createOneShotTimer(gridRoot, ((25 * 6) + (25 * 6) + 150),
                               function (params) {

                                   AppActions.enqueueGridEvent("checkMatches",
                                                               params.grid_id,
                                                               {cascadePromise: params.cascadePromise})
                               }, {
                                   "event": event,
                                   "grid_id": grid_id,
                                   "cascadePromise": cascadeSettledPromise,
                               })
            //console.log("Animation count is", animationCount,
            //            "skipping match checking")
            AppActions.gridEventDone(event)
            return
        }
        launchList = []
        current_event = event
        var curGrid = []
        var curDelay = 250
        var color_nums = {
            "red": "0",
            "blue": "1",
            "yellow": "2",
            "green": "3"
        }

        // combined row and column maatching by creating strings of numbers corrosponding to colors
        // so like row 2 would be "020002" and then we check for any sets of repeated numbers inside of the string to identify matches
        for (var i = 0; i < 6; i++) {
            var rowStr = ""
            var colStr = ""


            for (var u = 0; u < 6; u++) {
                if (grid_blocks[index(i, u)] != null) {
                    rowStr += color_nums[grid_blocks[index(i, u)].block_color]

                    curGrid.push(color_nums[grid_blocks[index(i,
                                                              u)].block_color])
                } else {
                    curGrid.push(-1)
                }
                if (grid_blocks[index(u, i)] != null) {
                    colStr += color_nums[grid_blocks[index(u, i)].block_color]
                }
            }
            //console.log(rowStr)

            // not sure exactly how this algorithm works but it does work 100% of the time, so if it aint broke dont fix it
            for (var p = 0; p < 4; p++) {

                for (var q = 6; q >= 3; q--) {
                    var str = ""
                    while (str.length < q) {
                        str += p.toString()
                    }

                    if (rowStr.indexOf(str) > -1) {

                        console.log("found match at", rowStr.indexOf(str),
                                    "that is", str.length, "blocks in a column")
                        for (var u = rowStr.indexOf(
                                 str); u < (rowStr.indexOf(
                                                str) + str.length); u++) {
                            curDelay += 75
                            var params = {
                                "i": i,
                                "u": u,
                                "grid_blocks": grid_blocks
                            }

                            // enqueue grid event to launch one block which will happen after any other already enqueued grid events
                            // attempt to pass the cascadePromise along (which may not always exist here especially when cascading due to things other than not swapping
                            if (typeof grid_blocks[index(u,i)] == "undefined") {
                                continue;
                            }
                            AppActions.enqueueGridEvent("launchBlock",
                                                        grid_id, {
                                                            "row": i,
                                                            "column": u,
                                                            "damage": grid_blocks[index(u, i)].health,
                                                            "cascadePromise": cascadeSettledPromise
                                                        })
                            curGrid[index(i, u)] = -1

                            launchCount++
                        }
                    }
                    if (colStr.indexOf(str) > -1) {

                        console.log("found match at", colStr.indexOf(str),
                                    "that is", str.length, "blocks in a row")

                        for (var u = colStr.indexOf(
                                 str); u < (colStr.indexOf(
                                                str) + str.length); u++) {
                            curDelay += 75
                            var params = {
                                "i": u,
                                "u": i,
                                "grid_blocks": grid_blocks
                            }
                            if (typeof grid_blocks[index(u,i)] == "undefined") {
                                continue;
                            }
                            AppActions.enqueueGridEvent("launchBlock",
                                                        grid_id, {
                                                            "row": u,
                                                            "column": i,
                                                            "damage": grid_blocks[index(u, i)].health,
                                                            "cascadePromise": cascadeSettledPromise
                                                        })
                            curGrid[index(i, u)] = -1
                            launchCount++
                        }
                    }
                }
            }
        }

        //  AppActions.enqueueGridEvent("shuffleDown", grid_id, ({}))
        //        AppActions.enqueueGridEvent("shuffleDown", grid_id, {
        //                                        "grid": curGrid
        //                                    })
        //  if (animationCount == 0) {
        if (launchList.length == 0) {
            if (typeof cascadeSettledPromise != "undefined") {
                cascadeSettledPromise.resolve();
                if (turns <= 0) {
                    activeTurn = false;
                    AppActions.enableBlocks(grid_id, false)
                    AppActions.setActiveGrid(grid_id == 0 ? 1 : 0)
                } else {
                    AppActions.enableBlocks(grid_id, true)
                }
            } else {
                if (turns <= 0) {
                    activeTurn = false;
                    AppActions.enableBlocks(grid_id, false)
                    AppActions.setActiveGrid(grid_id == 0 ? 1 : 0)
                } else {
                    AppActions.enableBlocks(grid_id, true)
                }
            }
        }
        AppActions.gridEventDone(current_event)
        // }
    }
    AppListener {
        filter: ActionTypes.runFunctionOnGrid
        onDispatched: function (dtype, ddata) {
            if (ddata.grid_id === grid_id) {
                if (typeof ddata.input_function == "function") {
                    ddata.inputfunction(ddata.input_data)
                }
            }
        }

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
    function updateAnimationCounts() {
        animationCount = 0
        for (var i = 0; i < 6; i++) {
            var rowCount = 0
            for (var u = 0; u < 6; u++) {
                if (grid_blocks[index(i, u)] == null) {
                    continue
                }
                if (Math.abs(grid_blocks[index(
                                             i,
                                             u)].y - (grid_blocks[index(i,
                                                                        u)].row
                                                      * grid_blocks[index(
                                                                        i,
                                                                        u)].height)) > 10) {
                    animationCount++
                }
            }
        }
    }
    function launchBlock(event) {
        if (event.grid_id == grid_id) {
            current_event = event
            if (grid_blocks[index(event.row, event.column)] == null) {
                AppActions.gridEventDone(current_event)
                launchCount--
                animationCount--
                if (launchCount == 0) {

                    AppActions.enqueueGridEvent("shuffleDown", grid_id, ({}))
                }
                return
            } else {
                if (launchList.indexOf(index(event.row, event.column)) == -1) {
                    var blk = grid_blocks[index(event.row, event.column)]
                    if (blk) {
                        blk.launch()
                        var moveBlocks = 0
                        launchCount++
                        launchList.push(index(event.row, event.column))

                        grid_blocks[index(event.row, event.column)] = null
                    }
                } else {
                    //  AppActions.gridEventDone(current_event)
                    launchCount--
                    if (launchCount <= 0) {
                        AppActions.enqueueGridEvent("checkMatches",
                                                    grid_id, ({cascadePromise: cascadeSettledPromise}))
                    }
                }
                //board[index(event.row, event.column)] = null
                // AppActions.gridEventDone(current_event)
            }
        }
    }
    function cleanupBlocks() {
        for (var i = 0; i < gridRoot.children.length; i++) {
            var child = gridRoot.children[i]

            //console.log(typeof child)
            if (child.objectName == "Block") {
                if (grid_blocks.indexOf(child) == -1) {
                    child.destroy()
                    // Do something with the block instance
                }
            }
        }
    }
    function fillBlocks(blocksToFill) {
          disableSwitching();
          blocksToFill.forEach((block, index) => {
              setTimeout(() => {
                  addBlock(block);
                  if (index === blocksToFill.length - 1) {
                      enableSwitching();
                  }
              }, index * 500);
          });
      }
    Component {
        id: blockComponent
        Block {
            id: blk
        }
    }
    Component {
     id: cascadeSettledPromiseComponent

     Promise {







     }
    }

    function createCascadeSettledPromise(grid_id) {
        var _promise = cascadeSettledPromiseComponent.createObject({
                                                                   onFulfilled: function() { AppActions.enqueueGridEvent("cascadeSettled", grid_id, ({})); console.log("*** enqueued cascade settled promise ***",grid_id);  }
                                                                   })
        cascadeSettledPromise = _promise;
    }

    // Helper: can a block at (row,col) drop one cell down?
    function canMoveDown(row, col) {
        if (row < 0 || row >= 6 || col < 0 || col >= 6) return false
        var b = grid_blocks[index(row, col)]
        if (b == null) return false
        if (row + 1 >= 6) return false
        return grid_blocks[index(row + 1, col)] == null
    }

    // Perform one compaction step: move eligible blocks down by exactly one cell
    function stepCompactDown() {
        var moved = false
        for (var col = 0; col < 6; col++) {
            for (var row = 4; row >= 0; row--) { // bottom-up, skip row 5
                if (canMoveDown(row, col)) {
                    var blk = grid_blocks[index(row, col)]
                    grid_blocks[index(row, col)] = null
                    grid_blocks[index(row + 1, col)] = blk
                    blk.row = row + 1
                    blk.column = col
                    blk.y = blk.row * blk.height
                    // ensure visual positions reflect updated rows
                    repositionGridBlocks(blk.row)
                    moved = true
                }
            }
        }
        return moved
    }
    function isBlockAt(row, col) {
    try {
    const v = grid_blocks[index(row, col)]
    return v && Qt.isQtObject(v) && v.objectName === "Block"
    } catch (e) {
    // Covers "TypeError: Type error" for destroyed/dangling objects
    return false
    }
    }
    // Refill logic: iteratively compact one cell at a time until settled, then spawn new blocks
    function refill() {

        for (var a=0; a<6; a++) {
          for (var b=0; b<6; b++) {
         if (isBlockAt(a,b)) {
                  console.log(grid_blocks[index(a,b)]);
                  var bk = grid_blocks[index(a,b)];
                  if (bk.health <= 0) { bk.destroy(); grid_blocks[index(a,b)] = null; }
              }
          }
        }
        // Attempt a single compaction step
        var moved = stepCompactDown()

        // If any blocks moved, allow animations to complete before the next step
        updateAnimationCounts()
        if (moved || animationCount > 0) {
            // recheck quickly until all movements/animations settle
            createOneShotTimer(gridRoot, 120, function () {
                refill()
            }, {})
            return
        }

        // No more movement and animations are settled; compute per-column missing and colors for createBlocks
        var creationCounts = ({})
        for (var col = 0; col < 6; col++) {
            var colMissingCount = 0
            var pool = controller.getPool(col)
            var pool_index = controller.getPoolIndex(col)
            var new_colors = []
            for (var row = 0; row < 6; row++) {
                console.log("*** refill creation processing",row,col,typeof grid_blocks[index(row, col)])

                if (!isBlockAt(row, col)) {
                    colMissingCount++
                    var rand_color = pool.randomNumber(pool_index)
                    pool_index++
                    controller.increasePoolIndex(col)
                    var block_color
                    switch (rand_color) {
                    case 0:
                        block_color = "red"
                        break
                    case 1:
                        block_color = "blue"
                        break
                    case 2:
                        block_color = "yellow"
                        break
                    case 3:
                        block_color = "green"
                        break
                    default:
                        block_color = "white"
                    }
                    new_colors.push(block_color)
                }
            }
            creationCounts[String(col)] = {
                "missing": colMissingCount,
                "new_colors": new_colors
            }
        }

        var evt = ({})
        evt.event_type = "createBlocks"
        evt.create_counts = creationCounts
        controller.grid_event_queue.push(evt)

        var evt2 = ({})
        evt2.event_type = "checkMatches"
        controller.grid_event_queue.push(evt2)

        if (!controller.waitingForCallback) {
            controller.executeNextGridEvent()
        }
    }


}
