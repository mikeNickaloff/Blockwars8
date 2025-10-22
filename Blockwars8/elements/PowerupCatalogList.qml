import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

Pane {
    id: catalogList

    property QtObject provider
    property QtObject selectionProvider

    property var entries: provider ? provider.entries() : []
    property int activeSlotId: selectionProvider ? selectionProvider.activeSlotId : (provider ? provider.activeSlotId : -1)
    property int highlightedIndex: resolver.indexFor(entries, activeSlotId)

    padding: 16
    implicitWidth: 300
    implicitHeight: 480

    readonly property QtObject resolver: QtObject {
        function indexFor(list, slotId) {
            if (!list || list.length === undefined) {
                return -1
            }
            for (var i = 0; i < list.length; ++i) {
                var entry = list[i]
                if (entry && entry.slotId === slotId) {
                    return i
                }
            }
            return -1
        }

        function title(entry) {
            if (!entry) {
                return qsTr("Powerup")
            }
            var provided = entry.slotName !== undefined && entry.slotName !== null
                    ? ("" + entry.slotName).trim()
                    : ""
            return provided.length > 0 ? provided : qsTr("Powerup")
        }

        function subtitle(entry) {
            if (!entry) {
                return qsTr("No assignments")
            }
            var count = entry.assignmentCount || 0
            if (count === 0) {
                return qsTr("No assignments")
            }
            if (count === 1) {
                return qsTr("1 assignment")
            }
            return qsTr("%1 assignments").arg(count)
        }
    }

    background: Rectangle {
        radius: 12
        color: "#1b2230"
        border.color: "#2f3a52"
        border.width: 1
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Label {
            Layout.fillWidth: true
            text: qsTr("Powerup Slots")
            font.pixelSize: 20
            font.bold: true
            color: "#dbe8ff"
        }

        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: 0
            background: Rectangle {
                color: "transparent"
            }

            ListView {
                id: listView
                anchors.fill: parent
                clip: true
                spacing: 4
                model: catalogList.entries
                currentIndex: catalogList.highlightedIndex

                delegate: ItemDelegate {
                    id: control
                    required property var modelData

                    width: ListView.view.width
                    hoverEnabled: true
                    padding: 12
                    background: Rectangle {
                        radius: 8
                        color: (control.hovered || control.highlighted) ? "#2b3954" : "transparent"
                    }

                    contentItem: Column {
                        spacing: 2
                        width: parent.width

                        Label {
                            width: parent.width
                            text: catalogList.resolver.title(modelData)
                            color: "#f2f4f8"
                            font.pixelSize: 16
                            elide: Text.ElideRight
                        }

                        Label {
                            width: parent.width
                            text: catalogList.resolver.subtitle(modelData)
                            color: "#8f9bb3"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                    }

                    onClicked: {
                        if (!catalogList.provider || !catalogList.provider.openSlot) {
                            return
                        }
                        catalogList.provider.openSlot(modelData.slotId)
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                text: qsTr("No powerup slots available.")
                color: "#77839c"
                visible: catalogList.entries.length === 0
            }
        }
    }
}
