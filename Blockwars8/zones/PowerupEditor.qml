import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import "../elements" 1.0

Pane {
    id: editorZone
    anchors.fill: parent
    background: Rectangle {
        color: "#0d121d"
    }

    PowerupEditorView {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.9, implicitWidth)
        height: Math.min(parent.height * 0.9, implicitHeight)
    }
}
