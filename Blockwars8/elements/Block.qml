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
import "../components" 1.0
import "." 1.0

Item {

    id: block
    objectName: "Block"
    property var uuid: 0
    property var column
    property var row
    property var grid_id: 0
    property var block_color: "blue"
    property var isAttacking: false
    property var isMoving: true
    property var hasBeenLaunched: false
    property var block_health: 5
    Rectangle {
        anchors.fill: parent
        color: block_color
        border.color: "black"
        border.width: 2
    }
    signal animationStart
    signal animationDone
    signal rowUpdated(var row)
    onRowChanged: {
        //   console.log("Updating row for", block.row, block.column)
        debugText.text = block.row + "," + block.column + "," + block.block_health
        rowUpdated(row)
    }
    Behavior on y {
        SequentialAnimation {
            ScriptAction {
                script: {
                    block.animationStart()
                    AppActions.enableBlocks(grid_id, false)
                }
            }
            NumberAnimation {
                duration: 100 + ((6 - row) * 75)
                //duration: 100
            }
//            NumberAnimation {
//                duration: 100 + ((6 - row) * 105)
//                 duration: 50 * (6 - row) + 150
//            }
            ScriptAction {
                script: {
                    block.animationDone()
                }
            }
        }
    }

    /* functions */
    function launch() {
        loader.sourceComponent = blockLaunchComponent
        isAttacking = true
        block.hasBeenLaunched = true
        launchCompleteReportTimer.start()
    }
    Timer {
        id: launchCompleteReportTimer
        interval: 150 + (block.row * (15 * 6)) + (block.column * 15)
        triggeredOnStart: false
        onTriggered: {
            AppActions.blockLaunchCompleted({
                                                "row": block.row,
                                                "column": block.column,
                                                "grid_id": grid_id
                                            })
        }
        repeat: false
        running: false
    }

    /* components */
    Component {
        id: blockIdleComponent
        Rectangle {
            color: "black"
            border.color: "black"
            anchors.fill: parent

            Image {
                source: "qrc:///images/block_" + block_color + ".png"
                height: {
                    return block.height * 0.90
                }
                width: {
                    return block.width * 0.90
                }

                id: blockImage
                asynchronous: true

                sourceSize.height: blockImage.height
                sourceSize.width: blockImage.width
                anchors.centerIn: parent
                visible: true
            }
            Text {
                id: debugPosText
                text: block.uuid
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 22
                anchors.centerIn: parent
                anchors.fill: parent
                visible: false
            }
        }
    }

    Component {
        id: blockLaunchComponent

        AnimatedSprite {

            id: sprite
            anchors.centerIn: parent
            height: {
                return block.height * 0.90
            }
            width: {
                return block.width * 0.90
            }
            z: 9999
            source: "qrc:///images/block_" + block_color + "_ss.png"
            frameCount: 5
            currentFrame: 0
            reverse: false
            frameSync: false
            frameWidth: 64
            frameHeight: 64
            loops: 1
            running: true
            frameDuration: 100
            interpolate: true

            smooth: false
            property var colorName: block_color

            onColorNameChanged: {
                sprite.source = "qrc:///images/block_" + colorName + "_ss.png"
            }

            onFinished: {


                /*  ActionsController.armyBlocksRequestLaunchTargetDataFromOpponent(
                            {
                                "orientation": block.orientation,
                                "column": block.col,
                                "health": block.health,
                                "attackModifier": block.attackModifier,
                                "healthModifier": block.healthModifier,
                                "uuid": block.uuid
                            }) */
                var globPos = block.mapToGlobal(block.height / 2,
                                                block.width / 2)

                AppActions.particleBlockLaunchedGlobal({
                                                           "grid_id": block.grid_id,
                                                           "x": globPos.x,
                                                           "y": globPos.y
                                                       })
                AppActions.blockLaunchCompleted({
                                                    "row": block.row,
                                                    "column": block.column,
                                                    "grid_id": grid_id,
                                                    "damage": block.block_health,
                                                })

                block.y = 12 * (block.height)
                block.z = 999
                loader.sourceComponent = blockExplodeComponent

                // explode()
            }
        }
    }

    Component {
        id: blockHealthGainComponent

        AnimatedSprite {

            id: sprite
            anchors.centerIn: parent
            height: {
                return block.height * 0.90
            }
            width: {
                return block.width * 0.90
            }
            z: 9999
            source: "qrc:///images/block_" + block_color + "_ss.png"
            frameCount: 5
            currentFrame: 0
            reverse: false
            frameSync: false
            frameWidth: 64
            frameHeight: 64
            loops: 1
            running: true
            frameDuration: 100
            interpolate: true

            smooth: false
            property var colorName: block_color

            onColorNameChanged: {
                sprite.source = "qrc:///images/block_" + colorName + "_ss.png"
            }

            onFinished: {


                /*  ActionsController.armyBlocksRequestLaunchTargetDataFromOpponent(
                            {
                                "orientation": block.orientation,
                                "column": block.col,
                                "health": block.health,
                                "attackModifier": block.attackModifier,
                                "healthModifier": block.healthModifier,
                                "uuid": block.uuid
                            }) */
                var globPos = block.mapToGlobal(block.height / 2,
                                                block.width / 2)

                AppActions.particleBlockLaunchedGlobal({
                                                           "grid_id": block.grid_id,
                                                           "x": globPos.x,
                                                           "y": globPos.y
                                                       })

                loader.sourceComponent = blockIdleComponent

                // explode()
            }
        }
    }

    Component {
        id: blockExplodeComponent

        AnimatedSprite {
            id: sprite
            width: block.width * 4.5
            height: block.height * 4.5

            anchors.centerIn: parent
            z: 7000


            /*source: "qrc:///images/" + block_color + "_killed_ss.png"
            frameCount: 20
            frameWidth: 128
        frameHeight: 70 */
            source: "qrc:///images/block_die_ss.png"
            frameCount: 5
            frameWidth: 178
            frameHeight: 178
            //            source: "qrc:///images/explode_ss.png"
            //            frameCount: 20
            //            frameWidth: 64
            //            frameHeight: 64
            reverse: false
            frameSync: true

            loops: 3
            running: true
            frameDuration: 50
            interpolate: true

            smooth: true

            onFinished: {

                //console.log("Block destroyed", block.uuid)
                if (block.isAttacking == true) {
                    block.hasBeenLaunched = true
                    var globPos = block.mapToGlobal(block.height / 2,
                                                    block.width / 2)
                    AppActions.particleBlockKilledExplodeAtGlobal({
                                                                      "grid_id": grid_id,
                                                                      "x": globPos.x,
                                                                      "y": globPos.y
                                                                  })

                       block.opacity = 0
                    //   updatePositions()

                    // block.row = -20
                    loader.sourceComponent = blockDebrisComponent
                    // block.destroy()
                } else {
                    hasBeenLaunched = true
                    var globPos = block.mapToGlobal(block.height / 2,
                                                    block.width / 2)

                    AppActions.particleBlockKilledExplodeAtGlobal({
                                                                      "grid_id": grid_id,
                                                                      "x": globPos.x,
                                                                      "y": globPos.y
                                                                  })

                    //  block.opacity = 0
                    // block.row = -20
                    loader.sourceComponent = blockDebrisComponent

                    //updatePositions()
                }

                block.opacity = 0
                //block.isBeingAttacked = false
                //block_color = armyBlocks.getNextColor(block.col)

                // updatePositions()
                //block.removed(block.row, block.col)
                // block.destroy()
            }
        }
    }

    BlockLaunchParticle {
        id: launchParticleController
        z: 5001
        anchors.centerIn: block
        width: 20
        height: 20
    }

    Component {
        id: blockDebrisComponent

        AnimatedSprite {
            id: sprite
            width: block.width * 4.5
            height: block.height * 4.5

            anchors.centerIn: parent
            z: 7000

            source: "qrc:///images/" + block_color + "_killed_ss.png"
            frameCount: 20
            frameWidth: 128
            frameHeight: 70


            /*source: "qrc:///images/block_die_ss.png"
            frameCount: 5
            frameWidth: 178
            frameHeight: 178 */
            //            source: "qrc:///images/explode_ss.png"
            //            frameCount: 20
            //            frameWidth: 64
            //            frameHeight: 64
            reverse: false
            frameSync: true

            loops: 1
            running: true
            frameDuration: 50
            interpolate: true

            smooth: true

            onFinished: {
                launchParticleController.disableEmitter()

                particleController.burstAt(block.x, block.y)
                //console.log("Block destroyed", block.uuid)
                block.isMoving = false
                if (block.isBeingAttacked == false) {

                    var globPos = block.mapToGlobal(block.height / 2,
                                                    block.width / 2)
                    block.destroy()


                    /* AppActions.blockLaunchCompleted({
                                                        "uuid": block.uuid,
                                                        "row": block.row,
                                                        "column": block.col,
                                                        "grid_id": grid_id
                                                    })

                    block.destroy() */
                } else {
                    AppActions.blockKilledFromFrontEnd({
                                                           "grid_id": grid_id,
                                                           "uuid": block.uuid,
                                                           "row": block.row,
                                                           "column": block.column
                                                       })

                    //block.opacity = 0
                    //block.row = 0
                    block.hasBeenLaunched = true
                    //loader.sourceComponent = blockIdleComponent
                    // updatePositions()
                    block.destroy()
                }

                //block.opacity = 0
                //block.isBeingAttacked = false
                //block_color = armyBlocks.getNextColor(block.col)

                // updatePositions()
                //block.removed(block.row, block.col)
                // block.destroy()
            }
        }
    }

    Item {
        width: block.width
        height: block.height
        Loader {
            id: loader
            width: block.width
            height: block.height
            sourceComponent: blockIdleComponent

            onLoaded: {

            }
        }
        Text {
            id: debugText
            color: "white"
            text: block.row + "," + block.column
        }
        AppListener {
            filter: ActionTypes.enableBlocks
            onDispatched: function (a, b) {
                if (b.grid_id == grid_id) {
                    blockMouseArea.enabled = b.blocks_enabled
                }
            }
        }
        MouseArea {
            property var mouse_start_x: 0
            property var mouse_start_y: 0
            property var direction: "none"
            id: blockMouseArea
            anchors.fill: parent
            onPressed: {
                if (enabled) {
                    mouse_start_x = blockMouseArea.mouseX
                    mouse_start_y = blockMouseArea.mouseY
                }
            }
            onMouseXChanged: {
                if (enabled) {
                    var dx = mouse_start_x - blockMouseArea.mouseX
                    var dy = mouse_start_y - blockMouseArea.mouseY
                    if (Math.abs(dx) > Math.abs(dy)) {
                        if (Math.abs(dx) > (block.width * 0.7)) {
                            if (dx > 0) {
                                console.log("move left")
                                if (block.column > 0) {
                                    direction = "left"
                                } else {
                                    direction = "none"
                                }
                            }
                            if (dx < 0) {
                                if (block.column < 5) {
                                    direction = "right"
                                } else {
                                    direction = "none"
                                }
                            }
                        } else {
                            direction = "none"
                            /* no movement */
                        }
                    } else {

                    }
                }
            }
            onMouseYChanged: {
                if (enabled) {
                    var dx = mouse_start_x - blockMouseArea.mouseX
                    var dy = mouse_start_y - blockMouseArea.mouseY
                    if (Math.abs(dx) < Math.abs(dy)) {
                        if (Math.abs(dx) < (block.height * 0.7)) {
                            if (dy > 0) {
                                if (block.row > 0) {
                                    direction = "up"
                                } else {
                                    direction = "none"
                                }
                            }
                            if (dy < 0) {

                                if (block.row < 5) {
                                    direction = "down"
                                } else {
                                    direction = "none"
                                }
                            }
                        } else {
                            direction = "none"
                            /* no movement */
                        }
                    } else {

                    }
                }
            }
            onReleased: {
                if (enabled) {
                    console.log("Moved", direction)
                    if (direction != "none") {

                        AppActions.swapBlocks(block.row, block.column, grid_id,
                                              direction)
                    }
                }
            }
        }

        DropZone {
            property alias row: block.row
            property alias column: block.column
            grid_id: block.grid_id
            id: powerupDropArea
            anchors.fill: parent
            onEntered: {
                console.log("Draggable object entered drop area",
                            Drag.source.x, Drag.source.y)
                drag.source.x = parent.x
                drag.source.y = parent.y
                drag.source.width = parent.width
                drag.source.height = parent.height


                /*drag.source.anchors.left = parent.left
                drag.source.anchors.right = parent.right
                drag.source.anchors.top = parent.top
                drag.source.anchors.bottom = parent.bottom */
            }
            onDropped: {
                // Calculate nearest grid block position
                var closestX = parent.x
                var closestY = parent.y

                // Position the rectangle to overlay the nearest block
                drag.source.x = closestX
                drag.source.y = closestY
                drag.source.width = parent.width
                drag.source.height = parent.height
                drag.source.parent = parent
            }
        }
        AppListener {
            filter: ActionTypes.setBlockProperty
            onDispatched: function (evt, a) {
                if (a.grid_id == block.grid_id) {
                    if (a.row == block.row) {
                        if (a.col == block.column) {
                            switch (a.propName) {
                            case "block_color":
                                if (a.propValue == -1) {
                                    block.block_color = "orange"
                                }
                                if (a.propValue == -2) {
                                    block.block_color = "purple"
                                }
                                if (a.propValue == -3) {
                                    block.block_color = "pink"
                                }
                                if (a.propValue == -4) {
                                    block.block_color = "cyan"
                                }
                                if (a.propValue >= 0) {
                                    block.block_color = a.propValue
                                }
                                return
                            default:
                                return
                            }
                        }
                    }
                }
            }
        }
        AppListener {
            filter: ActionTypes.modifyBlockHealth
            onDispatched: function (atype, a) {
                console.log("Block received modifyBlockHealth Dispatch",JSON.stringify(a));
                if (a.grid_id == block.grid_id) {
                    if (a.row == block.row) {
                        if (a.column == block.column) {
                            block.block_health = a.amount

                                if (block.block_health < 1) {
                                    block.isAttacking = false
                                    block.opacity = 0;
                                    block.block_health = 0;
                                    loader.sourceComponent = blockExplodeComponent
                                    block.destroy();
                                }

                        }
                    }
                }
            }
        }
    }
}
