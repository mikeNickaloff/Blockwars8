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
import com.blockwars 1.0
import "../elements" 1.0
import "../controllers" 1.0
import "../../quickflux" 1.0 as Editor

Rectangle {
    id: gameRoot
    visible: hydrationCoordinator.isSceneVisible
    color: "black"
    readonly property QtObject editorStore: Editor.PowerupEditorStore

    QtObject {
        id: hydrationCoordinator
        property QtObject store: gameRoot.editorStore
        property bool isSceneVisible: false

        function evaluate() {
            if (!store) {
                return
            }
            if (store.isHydrated && !store.isLoading) {
                if (!isSceneVisible) {
                    isSceneVisible = true
                }
            }
        }

        function resetIfLoading() {
            if (!store) {
                return
            }
            if (store.isLoading && isSceneVisible) {
                isSceneVisible = false
            }
        }
    }

    Connections {
        target: hydrationCoordinator.store
        function onIsHydratedChanged() {
            hydrationCoordinator.evaluate()
        }
        function onIsLoadingChanged() {
            hydrationCoordinator.resetIfLoading()
            hydrationCoordinator.evaluate()
        }
    }

    Component.onCompleted: hydrationCoordinator.evaluate()
    GameGrid {
        id: gameGrid_top
        grid_id: 0
        height: parent.height / 2.15
        width: parent.width * 0.75
    }
    GridController {
        id: gridController_top
        grid_id: 0
        Component.onCompleted: {

        }
    }
    PowerupHud {
        id: powerupHud_top
        height: gameGrid_top.height
        anchors.top: gameGrid_top.top
        anchors.left: gameGrid_top.right
        anchors.right: parent.right
        width: parent.width * 0.20
        grid_id: 0
    }

    GameGrid {
        id: gameGrid_bottom
        grid_id: 1
        height: parent.height / 2.15
        rotation: 180
        anchors.bottom: parent.bottom
        width: parent.width * 0.75
    }
    GridController {
        id: gridController_bottom
        grid_id: 1
        Component.onCompleted: {

        }
    }
    PowerupHud {
        id: powerupHud_bottom
        height: gameGrid_bottom.height
        anchors.top: gameGrid_bottom.top
        anchors.left: gameGrid_bottom.right
        anchors.right: parent.right
        width: parent.width * 0.20
        grid_id: 1
    }
    Component.onCompleted: {
        gridController_top.fill()
        gridController_bottom.fill()
    }
}
