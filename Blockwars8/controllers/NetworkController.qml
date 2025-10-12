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
import "../components" 1.0
import QuickFlux 1.1
import "../zones" 1.0
import QtQuick.LocalStorage 2.15
import com.blockwars 1.0

Item {
    id: networkController
    property var waiting_for_network_callback: false
    property var waiting_for_local_callback: false
    IRC {
        id: irc
    }
    function sendMove(row1, col1, row2, col2) {
        var moveArr = [row1, col1, row2, col2]
        var moveStr = moveArr.join(" ")
        if ((waiting_for_local_callback) || (waiting_for_network_callback)) {
            createOneShotTimer(networkController, 100, function (params) {
                sendMove(params.row1, params.col2, params.row2, params.col2)
            }, {
                "row1": row1,
                "col1": col1,
                "row2": row1,
                "col2": col2
            })
            console.log("Waiting for callback - delaying sending move")
            return
        }
        irc.sendToGame("MOVE " + moveStr)
        AppActions.sendNetworkEvent("SWAP", moveStr)
        waiting_for_network_callback = true
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
}
