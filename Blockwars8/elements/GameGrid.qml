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
import "../controllers" 1.0
import "../elements" 1.0
import "../components" 1.0
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
    property int animationCount: 0
    property var grid_blocks: []
    property int launchCount: 0
    property var matchList: []
    property var incomingBlocks: []
    property string gridState: "idle"
    property bool initialFill: true
    property bool activeTurn: true
    property int turns: 3
    property int verticalDirection: 1

    signal gridSettled(var info)

    Component.onCompleted: {
        var normalizedRotation = gridRoot.rotation
        normalizedRotation = ((normalizedRotation % 360) + 360) % 360
        verticalDirection = normalizedRotation === 180 ? -1 : 1
        grid_blocks = new Array(maxIndex)
        for (var i = 0; i < maxIndex; ++i) {
            grid_blocks[i] = null
        }
    }

    Timer {
        id: fillTimer
        interval: 60
        repeat: true
        running: false
        triggeredOnStart: false
        onTriggered: processFillStep()
    }

    Timer {
        id: compactTimer
        interval: 45
        repeat: true
        running: false
        triggeredOnStart: false
        onTriggered: processCompactStep()
    }

    Timer {
        id: matchTimer
        interval: 70
        repeat: true
        running: false
        triggeredOnStart: false
        onTriggered: processMatchStep()
    }

    Timer {
        id: launchTimer
        interval: 55
        repeat: true
        running: false
        triggeredOnStart: false
        onTriggered: processLaunchStep()
    }

    function resetStateTimers() {
        fillTimer.stop()
        compactTimer.stop()
        matchTimer.stop()
        launchTimer.stop()
    }

    function logStateChange(nextState, reason) {
        if (gridState === nextState) {
            return
        }
        console.debug("Grid", grid_id, "state", gridState, "->", nextState,
                      reason ? ("reason:" + reason) : "")
        gridState = nextState
    }

    function setGridState(nextState, reason) {
        var previous = gridState
        if (previous === nextState) {
            return
        }
        resetStateTimers()
        logStateChange(nextState, reason)
        switch (gridState) {
        case "fill":
            fillTimer.start()
            Qt.callLater(processFillStep)
            break
        case "compact":
            compactTimer.start()
            Qt.callLater(processCompactStep)
            break
        case "match":
            matchTimer.start()
            Qt.callLater(processMatchStep)
            break
        case "launch":
            launchTimer.start()
            Qt.callLater(processLaunchStep)
            break
        default:
            break
        }
    }

    function frontRowIndex() {
        return verticalDirection === 1 ? 0 : maxRow - 1
    }

    function spawnRowIndex() {
        return frontRowIndex() - verticalDirection
    }

    function nextRowIndex(row) {
        return row + verticalDirection
    }

    function rowWithinBounds(row) {
        return row >= 0 && row < maxRow
    }

    function getBlock(row, column) {
        if (!rowWithinBounds(row) || column < 0 || column >= maxColumn) {
            return null
        }
        return grid_blocks[index(row, column)] || null
    }

    function setBlockAt(row, column, blk) {
        if (!rowWithinBounds(row) || column < 0 || column >= maxColumn) {
            return
        }
        grid_blocks[index(row, column)] = blk
    }

    function clearBlockAt(row, column) {
        if (!rowWithinBounds(row) || column < 0 || column >= maxColumn) {
            return
        }
        grid_blocks[index(row, column)] = null
    }

    function hasAnimatingBlocks() {
        for (var i = 0; i < grid_blocks.length; ++i) {
            var blk = grid_blocks[i]
            if (!blk) {
                continue
            }
            if (blk.inAnimation) {
                return true
            }
        }
        for (var j = 0; j < incomingBlocks.length; ++j) {
            var pending = incomingBlocks[j]
            if (pending && pending.block && pending.block.inAnimation) {
                return true
            }
        }
        return false
    }

    function requestColumnFill(column) {
        AppActions.createOneBlock(grid_id, spawnRowIndex(), column)
    }

    function promoteIncomingBlocks() {
        if (incomingBlocks.length === 0) {
            return
        }
        var targetRow = frontRowIndex()
        var blkW = Math.floor(gridRoot.width / maxColumn)
        var blkH = Math.floor(gridRoot.height / maxRow)
        for (var i = 0; i < incomingBlocks.length; ++i) {
            var entry = incomingBlocks[i]
            if (!entry || !entry.block) {
                continue
            }
            var blk = entry.block
            var column = entry.column
            blk.column = column
            blk.row = targetRow
            blk.y = blkH * targetRow
            setBlockAt(targetRow, column, blk)
        }
        incomingBlocks = []
    }

    function processFillStep() {
        if (gridState !== "fill") {
            return
        }
        if (incomingBlocks.length > 0 && !hasAnimatingBlocks()) {
            promoteIncomingBlocks()
        }
        if (hasAnimatingBlocks()) {
            return
        }
        var targetRow = frontRowIndex()
        var columnsToFill = []
        for (var c = 0; c < maxColumn; ++c) {
            if (!getBlock(targetRow, c)) {
                columnsToFill.push(c)
            }
        }
        if (columnsToFill.length === 0) {
            if (hasEmptyCells()) {
                setGridState("compact", "fillNeedsCompact")
            } else {
                setGridState("match", "fillComplete")
            }
            return
        }
        for (var i = 0; i < columnsToFill.length; ++i) {
            requestColumnFill(columnsToFill[i])
        }
    }

    function processCompactStep() {
        if (gridState !== "compact") {
            return
        }
        if (hasAnimatingBlocks()) {
            return
        }
        var moved = false
        var cellHeight = Math.floor(gridRoot.height / maxRow)
        for (var col = 0; col < maxColumn; ++col) {
            var entries = []
            for (var row = 0; row < maxRow; ++row) {
                var blk = getBlock(row, col)
                if (blk) {
                    entries.push({
                                      "row": row,
                                      "block": blk
                                  })
                }
                clearBlockAt(row, col)
            }
            if (entries.length === 0) {
                continue
            }
            if (verticalDirection === 1) {
                var target = maxRow - 1
                for (var i = entries.length - 1; i >= 0; --i) {
                    var downBlk = entries[i].block
                    if (downBlk.row !== target) {
                        moved = true
                    }
                    downBlk.row = target
                    downBlk.y = cellHeight * target
                    setBlockAt(target, col, downBlk)
                    target -= 1
                }
            } else {
                var upTarget = 0
                for (var j = 0; j < entries.length; ++j) {
                    var upBlk = entries[j].block
                    if (upBlk.row !== upTarget) {
                        moved = true
                    }
                    upBlk.row = upTarget
                    upBlk.y = cellHeight * upTarget
                    setBlockAt(upTarget, col, upBlk)
                    upTarget += 1
                }
            }
        }

        if (!moved) {
            setGridState("fill", "compactComplete")
        }
    }

    function notifyCascadeEnded(reason) {
        AppActions.cascadeEnded({
                                     "grid_id": grid_id,
                                     "reason": reason
                                 })
    }

    function emitGridSettled(reason) {
        var info = {
            "grid_id": grid_id,
            "state": gridState,
            "reason": reason,
            "has_empty": hasEmptyCells(),
            "initial_fill": initialFill
        }
        AppActions.gridSettled(info)
        gridSettled(info)
    }

    function beginFillCycle(reason) {
        matchList = []
        launchCount = 0
        incomingBlocks = []
        setGridState("compact", reason || "beginFill")
    }

    function processMatchStep() {
        if (gridState !== "match") {
            return
        }
        if (hasAnimatingBlocks()) {
            return
        }
        if (hasEmptyCells()) {
            setGridState("compact", "matchFoundEmpty")
            return
        }
        matchList = collectMatches().map(function (entry) {
            entry.block = getBlock(entry.row, entry.column)
            return entry
        }).filter(function (entry) {
            return entry.block !== null
        })
        if (matchList.length === 0) {
            setGridState("idle", "noMatches")
            if (initialFill) {
                initialFill = false
            }
            emitGridSettled("noMatches")
            notifyCascadeEnded("noMatches")
            return
        }
        launchCount = 0
        setGridState("launch", "matchesFound")
    }

    function processLaunchStep() {
        if (gridState !== "launch") {
            return
        }
        if (matchList.length === 0) {
            if (launchCount <= 0) {
                setGridState("compact", "launchesFinished")
            }
            return
        }
        var pending = matchList.shift()
        if (!pending) {
            Qt.callLater(processLaunchStep)
            return
        }
        var blk = getBlock(pending.row, pending.column)
        if (!blk) {
            Qt.callLater(processLaunchStep)
            return
        }
        clearBlockAt(pending.row, pending.column)
        blk.launch()
        launchCount += 1
    }

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

    function resolveBlockColor(value) {
        if (value === undefined || value === null) {
            return "red"
        }
        if (typeof value === "string") {
            return value
        }
        var palette = ["red", "blue", "yellow", "green"]
        var idx = Math.abs(value) % palette.length
        switch (value) {
        case 0:
            return "red"
        case 1:
            return "blue"
        case 2:
            return "yellow"
        case 3:
            return "green"
        default:
            return palette[idx]
        }
    }

    function isCellEmpty(row, column) {
        if (row < 0 || column < 0 || row >= maxRow || column >= maxColumn) {
            return false
        }
        var idx = index(row, column)
        var blk = grid_blocks[idx]
        if (!blk) {
            return true
        }
        if (!Qt.isQtObject(blk)) {
            grid_blocks[idx] = null
            return true
        }
        if (blk.objectName !== "Block") {
            return true
        }
        return false
    }

    function firstAvailableRow(column, preferredRow) {
        if (preferredRow !== undefined && preferredRow !== null) {
            if (preferredRow >= 0 && preferredRow < maxRow && isCellEmpty(preferredRow, column)) {
                return preferredRow
            }
        }
        for (var r = 0; r < maxRow; ++r) {
            if (isCellEmpty(r, column)) {
                return r
            }
        }
        return -1
    }

    function instantiateBlock(row, column, colorValue, options) {
        var register = !options || options.register !== false
        if (column < 0 || column >= maxColumn) {
            return null
        }
        if (register) {
            if (!rowWithinBounds(row)) {
                return null
            }
            if (!isCellEmpty(row, column)) {
                return null
            }
        }

        var blkW = Math.floor(gridRoot.width / maxColumn)
        var blkH = Math.floor(gridRoot.height / maxRow)
        var startY = blkH * row
        var colorName = resolveBlockColor(colorValue)

        var blk = blockComponent.createObject(gridRoot, {
                                                  "x": blkW * column,
                                                  "y": startY,
                                                  "row": row,
                                                  "column": column,
                                                  "width": blkW,
                                                  "height": blkH,
                                                  "block_color": colorName,
                                                  "grid_id": grid_id
                                              })
        if (!blk) {
            return null
        }

        blk.row = row
        blk.column = column

        blk.animationStart.connect(handleBlockAnimationStartEvent)
        blk.animationDone.connect(handleBlockAnimationDoneEvent)
        blk.rowUpdated.connect(updateBlocks)
        blk.rowUpdated.connect(repositionGridBlocks)

        if (register) {
            setBlockAt(row, column, blk)
        }
        blk.y = blkH * row
        return blk
    }

    function recordMatch(matches, seen, row, column) {
        var key = row + ":" + column
        if (seen[key]) {
            return
        }
        seen[key] = true
        matches.push({
                         "row": row,
                         "column": column
                     })
    }

    function collectMatches() {
        var matches = []
        var seen = ({})

        for (var r = 0; r < maxRow; ++r) {
            var runColor = null
            var runStart = -1
            var runLength = 0
            for (var c = 0; c <= maxColumn; ++c) {
                var blk = c < maxColumn ? grid_blocks[index(r, c)] : null
                var color = blk ? blk.block_color : null
                if (color && color === runColor) {
                    runLength++
                } else {
                    if (runColor && runLength >= 3) {
                        for (var cc = runStart; cc < runStart + runLength; ++cc) {
                            recordMatch(matches, seen, r, cc)
                        }
                    }
                    if (color) {
                        runColor = color
                        runStart = c
                        runLength = 1
                    } else {
                        runColor = null
                        runStart = -1
                        runLength = 0
                    }
                }
            }
        }

        for (var c = 0; c < maxColumn; ++c) {
            var runColorCol = null
            var runStartRow = -1
            var runLen = 0
            for (var r = 0; r <= maxRow; ++r) {
                var blkCol = r < maxRow ? grid_blocks[index(r, c)] : null
                var colorCol = blkCol ? blkCol.block_color : null
                if (colorCol && colorCol === runColorCol) {
                    runLen++
                } else {
                    if (runColorCol && runLen >= 3) {
                        for (var rr = runStartRow; rr < runStartRow + runLen; ++rr) {
                            recordMatch(matches, seen, rr, c)
                        }
                    }
                    if (colorCol) {
                        runColorCol = colorCol
                        runStartRow = r
                        runLen = 1
                    } else {
                        runColorCol = null
                        runStartRow = -1
                        runLen = 0
                    }
                }
            }
        }

        return matches
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
                    var row = ddata.row
                    var column = ddata.column
                    clearBlockAt(row, column)
                    cleanupBlocks()
                    if (launchCount > 0) {
                        launchCount--
                    }
                    if (launchCount <= 0 && gridState === "launch" && matchList.length === 0) {
                        launchCount = 0
                        setGridState("compact", "launchCompleteAck")
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
            current_event = event
            var event_type = event.event_type
            switch (event_type) {
            case "beginFillCycle":
                beginFillCycle(event.source_event || "queue")
                AppActions.gridEventDone(current_event)
                break
            case "shuffleDown":
                setGridState("compact", event.source_event || "queue")
                AppActions.gridEventDone(current_event)
                break
            case "createBlocks":
                createBlocks(event)
                break
            case "checkMatches":
                checkMatches(event)
                break
            case "launchBlock":
                launchBlock(event)
                break
            case "createOneBlock":
                createOneBlock(event)
                break
            case "disableInitialFill":
                initialFill = false
                AppActions.gridEventDone(current_event)
                break
            case "setActive":
                AppActions.setActiveGrid(grid_id)
                AppActions.gridEventDone(current_event)
                break
            case "prepareFill":
                beginFillCycle(event.source_event || "prepareFill")
                AppActions.gridEventDone(current_event)
                break
            case "finalizeTurn":
                AppActions.swapLaunchingAnimationsDone({
                                                           "grid_id": grid_id,
                                                           "source_event": event.source_event !== undefined ? event.source_event : "finalizeTurn",
                                                           "initial_fill": event.initial_fill === true
                                                       })
                emitGridSettled(event.source_event || "finalizeTurn")
                AppActions.gridEventDone(current_event)
                break
            case "swapBlocks":
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

                    AppActions.gridEventDone(current_event)
                    setGridState("match", "swap")
                    AppActions.enableBlocks(grid_id, false)

                }
                break
            default:
                AppActions.gridEventDone(current_event)
                break
            }
        }


        /*
     *
     *    grid event functions area
    */
        function hasEmptyCells() {
        for (var i = 0; i < grid_blocks.length; ++i) {
            if (!grid_blocks[i]) {
                return true
            }
        }
        return false
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
            if (animationCount < 0) {
                animationCount = 0
            }
            // no-op: state timers poll hasAnimatingBlocks()
        }
        function handleBlockAnimationStartEvent() {
            animationCount++
        }
        function createOneBlock(event) {
            current_event = event
            var column = event.column !== undefined ? event.column : event.col
            if (column === undefined || column === null) {
                console.warn("createOneBlock: missing column", grid_id, JSON.stringify(event))
                AppActions.gridEventDone(current_event)
                return
            }
            var requestedRow = event.row
            var spawnRow = requestedRow
            if (spawnRow === undefined || spawnRow === null) {
                spawnRow = firstAvailableRow(column, requestedRow)
            }

            var register = rowWithinBounds(spawnRow)
            if (register && !isCellEmpty(spawnRow, column)) {
                console.warn("createOneBlock: no empty cell available", grid_id, column)
                AppActions.gridEventDone(current_event)
                return
            }

            var blk = instantiateBlock(spawnRow, column, event.color, {
                                           "register": register
                                       })
            if (blk && !register) {
                incomingBlocks.push({
                                        "block": blk,
                                        "column": column
                                    })
            }
            cleanupBlocks()
            AppActions.gridEventDone(current_event)
        }
        function createBlocks(event) {
            current_event = event
            var counts = event.create_counts || {}

        for (var column = 0; column < maxColumn; column++) {
            var columnInfo = counts[String(column)]
            if (!columnInfo) {
                continue
            }

            var newColors = columnInfo.new_colors ? columnInfo.new_colors.slice() : []
            if (newColors.length === 0) {
                continue
            }
            var missing = columnInfo.missing !== undefined ? columnInfo.missing : newColors.length
            var limit = Math.min(newColors.length, missing)
            for (var idx = 0; idx < limit; idx++) {
                var spawn = spawnRowIndex()
                var blk = instantiateBlock(spawn, column, newColors[idx], {
                                              "register": rowWithinBounds(spawn)
                                          })
                if (blk && !rowWithinBounds(spawn)) {
                    incomingBlocks.push({
                                            "block": blk,
                                            "column": column
                                        })
                }
            }
        }

        cleanupBlocks()
        AppActions.gridEventDone(current_event)
        if (gridState !== "fill") {
            setGridState("fill", "createBlocksEvent")
        } else {
            Qt.callLater(processFillStep)
        }
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
            current_event = event
            setGridState("match", event.source_event || "checkMatchesEvent")
            AppActions.gridEventDone(current_event)
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
            current_event = event
            AppActions.gridEventDone(current_event)
        }
        function cleanupBlocks() {
            for (var idx = 0; idx < grid_blocks.length; idx++) {
                var blk = grid_blocks[idx]
                if (!blk) {
                    grid_blocks[idx] = null
                    continue
                }
                if (!Qt.isQtObject(blk) || blk.objectName !== "Block") {
                    grid_blocks[idx] = null
                }
            }

            for (var i = gridRoot.children.length - 1; i >= 0; --i) {
                var child = gridRoot.children[i]
                if (!child || child.objectName !== "Block") {
                    continue
                }
                if (child.hasBeenLaunched) {
                    continue
                }
                var keepDueToIncoming = false
                for (var t = 0; t < incomingBlocks.length; ++t) {
                    var pending = incomingBlocks[t]
                    if (pending && pending.block === child) {
                        keepDueToIncoming = true
                        break
                    }
                }
                if (keepDueToIncoming) {
                    continue
                }
                if (grid_blocks.indexOf(child) === -1) {
                    child.destroy()
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
