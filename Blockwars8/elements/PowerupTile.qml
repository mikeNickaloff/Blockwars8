import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: powerupTile
    objectName: "PowerupTile"
    property string colorName: "red"
    property int gridId: 0
    property int slotId: -1
    property string displayName: "Powerup"
    property bool matchable: false
    property int row: -1
    property int column: -1
    property int rightColumn: -1
    implicitWidth: 64
    implicitHeight: 64
    z: 200
    property int maxHealth: 100
    property int health: 100

    Rectangle {
        anchors.fill: parent
        radius: width * 0.15
        color: colorName
        border.width: 2
        border.color: Qt.darker(colorName, 1.4)
        Text {
            anchors.centerIn: parent
            text: "★"
            color: "white"
            font.pixelSize: Math.round(parent.width * 0.5)
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            text: maxHealth > 0 ? Math.max(0, health) + "/" + maxHealth : ""
            color: "#f0f0ff"
            font.pixelSize: Math.round(parent.width * 0.22)
        }
    }
}
