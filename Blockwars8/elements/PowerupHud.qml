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
    id: powerupHud
    width: 100
    height: 300
    required property var grid_id
    Column {
        anchors.fill: parent
        DragZone {
            id: powerupSlot0
            width: powerupHud.width
            height: powerupHud.height * 0.25
            color: "blue"
            grid_id: powerupHud.grid_id
            slot_id: 0
        }
        DragZone {
            id: powerupSlot1
            width: powerupHud.width
            height: powerupHud.height * 0.25
            color: "yellow"
            grid_id: powerupHud.grid_id
            slot_id: 1
        }
        DragZone {
            id: powerupSlot2
            width: powerupHud.width
            height: powerupHud.height * 0.25
            color: "green"
            grid_id: powerupHud.grid_id
            slot_id: 2
        }
        DragZone {
            id: powerupSlot3
            width: powerupHud.width
            height: powerupHud.height * 0.25
            color: "red"
            grid_id: powerupHud.grid_id
            slot_id: 3
        }
    }
}
