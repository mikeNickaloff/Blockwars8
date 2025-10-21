import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: mainWindow
    signal changeZone(var new_zone)

    ColumnLayout {
        id: mainMenu
        width: mainWindow.width * 0.75
        height: mainWindow.height * 0.75
        anchors.centerIn: parent

        Button {
            id: soloPlayButton
            text: "Solo Play"
            Layout.fillWidth: true
            Layout.preferredHeight: mainMenu.height / 4
            onClicked: {
                changeZone("single_player")
            }
        }

        Button {
            id: multiplayerButton
            text: "Multiplayer"
            Layout.fillWidth: true
            Layout.preferredHeight: mainMenu.height / 4
            onClicked: {
                changeZone("find_match")
            }
        }

        Button {
            id: powerupEditorButton
            text: "Powerup Editor"
            Layout.fillWidth: true
            Layout.preferredHeight: mainMenu.height / 4
            onClicked: {
                changeZone("powerup_editor")
            }
        }

        Button {
            id: exitButton
            text: "Exit"
            Layout.fillWidth: true
            Layout.preferredHeight: mainMenu.height / 4
        }
    }
}
