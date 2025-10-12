import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: mainWindow
    signal changeZone(var new_zone)

    width: parent ? parent.width : 480
    height: parent ? parent.height : 640

    ColumnLayout {
        id: mainMenu
        anchors.fill: parent
        anchors.margins: mainWindow.width * 0.05
        spacing: mainWindow.height * 0.03

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: mainWindow.height * 0.2

            Text {
                id: titleText
                text: "Block Wars"
                anchors.centerIn: parent
                font.pixelSize: Math.round(parent.height * 0.5)
                font.bold: true
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: mainMenu.height * 0.02

                Button {
                    id: singlePlayerButton
                    text: "Single Player"
                    Layout.fillWidth: true
                    Layout.preferredHeight: mainMenu.height * 0.12
                    onClicked: {
                        changeZone("single_player")
                    }
                }

                Button {
                    id: multiplayerButton
                    text: "Multiplayer"
                    Layout.fillWidth: true
                    Layout.preferredHeight: mainMenu.height * 0.12
                    onClicked: {
                        changeZone("find_match")
                    }
                }

                Button {
                    id: powerupEditorButton
                    text: "Powerup Editor"
                    Layout.fillWidth: true
                    Layout.preferredHeight: mainMenu.height * 0.12
                    onClicked: {
                        changeZone("powerup_editor")
                    }
                }

                Button {
                    id: optionsButton
                    text: "Options"
                    Layout.fillWidth: true
                    Layout.preferredHeight: mainMenu.height * 0.12
                    onClicked: {
                        changeZone("options")
                    }
                }

                Button {
                    id: exitButton
                    text: "Exit"
                    Layout.fillWidth: true
                    Layout.preferredHeight: mainMenu.height * 0.12
                }
            }
        }
    }
}
