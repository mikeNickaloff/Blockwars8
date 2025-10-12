import QtQuick 2.3
import QtQuick.Window 2.2
import QtMultimedia 5.5
import QtQuick.Controls 2.0
import "Blockwars8/constants" 1.0
import "Blockwars8/actions" 1.0
import "Blockwars8/stores" 1.0

import QuickFlux 1.1
import "Blockwars8/zones" 1.0

import "Blockwars8/controllers" 1.0
import "Blockwars8/elements" 1.0

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 480

    height: 640
    Component.onCompleted: {
        MainStore.loadPowerupData()
    }
    StackView {
        id: stackView
        width: parent.width
        height: parent.height
        onCurrentItemChanged: {

        }
        initialItem: zoneMainMenuComponent
    }

    Text {
        text: qsTr(MainStore.text)
        anchors.centerIn: parent
    }
    AppListener {
        filter: ActionTypes.enterZoneMainMenu
        onDispatched: {
            stackView.replace(zoneMainMenuComponent)
        }
    }
    Component {
        id: zoneMainMenuComponent
        MainMenu {
            onChangeZone: {
                switch (new_zone) {
                case "single_player":
                    stackView.replace(zoneSinglePlayerComponent)
                    break
                case "multi_player":
                    break
                case "find_match":
                    break
                case "powerup_editor":
                    stackView.replace(zonePowerupEditorComponent)
                    break
                case "options":
                    stackView.replace(zoneOptionsComponent)
                    break
                }
            }
        }
    }
    Component {
        id: zonePowerupEditorComponent
        PowerupEditor {}
    }
    Component {
        id: zoneSinglePlayerComponent
        SinglePlayer {}
    }
    Component {
        id: zoneOptionsComponent
        //Options {}
        Item {}
    }
}
