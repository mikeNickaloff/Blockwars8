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
    implicitWidth: 64
    implicitHeight: 64
    z: 200

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
    }
}
