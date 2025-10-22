import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

Pane {
    id: cardView

    property QtObject behavior
    property int slotId: -1

    property var snapshot: null
    property string fallbackText: behavior && behavior.fallbackText ? behavior.fallbackText() : qsTr("Select a powerup slot to review its configuration.")

    padding: 24
    implicitWidth: 640
    implicitHeight: 480

    readonly property QtObject presenter: QtObject {
        function valueText(value, placeholder) {
            if (value === null || value === undefined) {
                return placeholder
            }
            var text = "" + value
            return text.length === 0 ? placeholder : text
        }

        function assignmentsText(snapshot) {
            if (!snapshot || !snapshot.assignments || snapshot.assignments.length === 0) {
                return qsTr("No assignments configured.")
            }
            return snapshot.assignments.join(", ")
        }

        function gridSummary(snapshot) {
            if (!snapshot) {
                return qsTr("No grid selections.")
            }
            var count = snapshot.gridSelectionCount || 0
            if (count === 0) {
                return qsTr("No grid selections.")
            }
            if (count === 1) {
                return qsTr("1 grid cell selected.")
            }
            return qsTr("%1 grid cells selected.").arg(count)
        }

        function metadataSummary(snapshot) {
            if (!snapshot || !snapshot.metadata) {
                return qsTr("No metadata available.")
            }
            var keys = Object.keys(snapshot.metadata)
            if (keys.length === 0) {
                return qsTr("No metadata available.")
            }
            var lines = []
            for (var i = 0; i < keys.length; ++i) {
                var key = keys[i]
                var value = snapshot.metadata[key]
                lines.push(key + ": " + JSON.stringify(value))
            }
            return lines.join("\n")
        }
    }

    function refresh() {
        snapshot = behavior && behavior.snapshot ? behavior.snapshot(slotId) : null
    }

    Component.onCompleted: refresh()
    onSlotIdChanged: refresh()
    onBehaviorChanged: refresh()

    Connections {
        target: behavior && behavior.bridge ? behavior.bridge.store : null
        ignoreUnknownSignals: true
        onSlotArraysChanged: cardView.refresh()
        onSlotAssignmentsChanged: cardView.refresh()
        onSlotNamesChanged: cardView.refresh()
        onSlotRecordsChanged: cardView.refresh()
        onActiveSlotIdChanged: cardView.refresh()
    }

    background: Rectangle {
        radius: 16
        color: "#1a1f2b"
        border.color: "#2a3245"
        border.width: 1
    }

    contentItem: StackLayout {
        anchors.fill: parent
        currentIndex: snapshot ? 0 : 1

        ColumnLayout {
            spacing: 18

            Label {
                Layout.fillWidth: true
                text: snapshot ? presenter.valueText(snapshot.name, qsTr("Powerup")) : cardView.fallbackText
                font.pixelSize: 26
                font.bold: true
                color: "#f4f6fb"
                wrapMode: Text.WordWrap
            }

            GridLayout {
                columns: 2
                Layout.fillWidth: true
                visible: snapshot !== null

                Label { text: qsTr("Target") }
                Label {
                    text: presenter.valueText(snapshot ? snapshot.target : null, qsTr("None"))
                    color: "#d0d6e8"
                    wrapMode: Text.WordWrap
                }

                Label { text: qsTr("Type") }
                Label {
                    text: presenter.valueText(snapshot ? snapshot.type : null, qsTr("None"))
                    color: "#d0d6e8"
                    wrapMode: Text.WordWrap
                }

                Label { text: qsTr("Color") }
                Label {
                    text: presenter.valueText(snapshot ? snapshot.color : null, qsTr("None"))
                    color: "#d0d6e8"
                    wrapMode: Text.WordWrap
                }

                Label { text: qsTr("Amount") }
                Label {
                    text: presenter.valueText(snapshot ? snapshot.amount : null, qsTr("0"))
                    color: "#d0d6e8"
                }

                Label { text: qsTr("Energy") }
                Label {
                    text: presenter.valueText(snapshot ? snapshot.energy : null, qsTr("0"))
                    color: "#d0d6e8"
                }

                Label { text: qsTr("Grid") }
                Label {
                    text: presenter.gridSummary(snapshot)
                    color: "#d0d6e8"
                    wrapMode: Text.WordWrap
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: qsTr("Assignments")
                visible: snapshot !== null

                Label {
                    anchors.fill: parent
                    anchors.margins: 12
                    text: presenter.assignmentsText(snapshot)
                    color: "#c9d3ee"
                    wrapMode: Text.WordWrap
                }
            }

            GroupBox {
                Layout.fillWidth: true
                title: qsTr("Metadata")
                visible: snapshot !== null

                TextArea {
                    anchors.fill: parent
                    readOnly: true
                    wrapMode: TextEdit.WordWrap
                    text: presenter.metadataSummary(snapshot)
                    color: "#c9d3ee"
                    font.pixelSize: 12
                    background: Rectangle {
                        radius: 8
                        color: "#141925"
                    }
                }
            }
        }

        Item {
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 12

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Powerup Editor")
                    font.pixelSize: 24
                    font.bold: true
                    color: "#f4f6fb"
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: cardView.fallbackText
                    font.pixelSize: 14
                    color: "#8f9bb3"
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    width: cardView.width * 0.7
                }
            }
        }
    }
}
