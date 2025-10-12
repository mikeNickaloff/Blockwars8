import QtQuick 2.15
import QtQuick.Controls 2.15
import "../actions" 1.0

Item {
    id: optionsRoot

    width: parent ? parent.width : 480
    height: parent ? parent.height : 640

    Column {
        anchors.centerIn: parent
        spacing: 12

        Label {
            text: "Options"
            font.pixelSize: 26
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            width: 320
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            text: "Options menu placeholder. Hook up settings actions here.";
        }

        Button {
            text: "Back"
            onClicked: AppActions.enterZoneMainMenu()
        }
    }
}
