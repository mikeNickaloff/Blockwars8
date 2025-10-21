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
                console.log("Launch Completed", JSON.stringify(ddata),
                            "launch count is", launchCount)
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
                console.log("detected block launch complete from other grid", JSON.stringify(ddata))
                var current_healths = [];
                var incoming_dmg = ddata.damage;
                var current_col = 5 - ddata.column;
                for (var u=5; u>=0; u--) {
                    if (grid_blocks[index(u, current_col)] != null) { current_healths.push(grid_blocks[index(u, current_col)].block_health); } else { current_healths.push(0); }
                }
                console.log("current block healths on",current_col,current_healths);
                var destroy_list = [];

                for (u=0; u<current_healths.length; u++) {
                if (current_healths[u] > 0) {
                    if (incoming_dmg > 0) {
                        var blk_health = current_healths[u];
                        current_healths[u] -= incoming_dmg;
                        incoming_dmg -= blk_health;


                        if (!initialFill) {
                            console.log("modifying block health", 5 - u,current_col,grid_id, current_healths[u])
                            AppActions.modifyBlockHealth( 5 - u, current_col, grid_id, current_healths[u])
                        } else {
                            console.log("Not modifying health due to initialFill flag");
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
            if (ddata.grid_id == grid_id) {
                activeTurn = true;
                turns = 3;
                AppActions.enableBlocks(grid_id, true)
            } else {
                activeTurn = false;
                turns = 0;
                AppActions.enableBlocks(grid_id, false)
            }
        }
    }

    function handleGridEventExecute(event) {
        var event_type = event.event_type
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

            AppActions.gridEventDone(event)
        }
        if (event_type == "swapBlocks") {
            if (initialFill) {
                AppActions.enqueueGridEvent("disableInitialFill", 0, ({}));
                AppActions.enqueueGridEvent("disableInitialFill", 1, ({}))
            }
            if (activeTurn) {
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
                AppActions.enqueueGridEvent("checkMatches", grid_id, ({}))
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
            AppActions.gridEventDone(event)
            AppActions.fillGrid(grid_id, false)
        } else {
            AppActions.gridEventDone(event)
            AppActions.enqueueGridEvent("checkMatches", grid_id, {})
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
    function createBlocks(event) {
        var counts = event.create_counts
        current_event = event
        for (var i = 0; i < 6; i++) {
            var columnCounts = counts[String(i)].missing
            var new_colors = counts[String(i)].new_colors
            for (var u = 0; u < 6; u++) {
                //console.log("Creating block", u, "for column", i)
                var blkW = Math.floor(gridRoot.width / 6)
                var blkH = Math.floor(gridRoot.height / 6)
                var startY = (blkH * u) - (blkH * 6)
                var blkRow = u
                var blkCol = i

                //console.log("creating block", blkRow, blkCol, blkH, blkW)
                var blk = blockComponent.createObject(gridRoot, {
                                                          "x": blkW * blkCol,
                                                          "y": startY,
                                                          "row": blkRow,
                                                          "column": blkCol,
                                                          "width": blkW,
                                                          "height": blkH,
                                                          "block_color": new_colors.shift(
                                                                             ),
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
    function checkMatches(event) {
        cleanupBlocks()
        updateAnimationCounts()
        if (animationCount > 0) {
            createOneShotTimer(gridRoot, ((25 * 6) + (25 * 6) + 150),
                               function (params) {

                                   AppActions.enqueueGridEvent("checkMatches",
                                                               params.grid_id,
                                                               {})
                               }, {
                                   "event": event,
                                   "grid_id": grid_id
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
                            AppActions.enqueueGridEvent("launchBlock",
                                                        grid_id, {
                                                            "row": i,
                                                            "column": u,
                                                            "damage": grid_blocks[index(u, i)].health
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
                            AppActions.enqueueGridEvent("launchBlock",
                                                        grid_id, {
                                                            "row": u,
                                                            "column": i,
                                                            "damage": grid_blocks[index(u, i)].health
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
            AppActions.enableBlocks(grid_id, true)
        }
        AppActions.gridEventDone(current_event)
        // }
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
                                                    grid_id, ({}))
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
}
