import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

Pane {
    id: selector

    property var selection: ({})
    property var _internalSelection: ({})
    property bool editable: true
    property int rows: 6
    property int columns: 6
    property int cellMinSize: 20
    property int cellMaxSize: 36
    property real cellSpacing: 4
    property color activeColor: "#3c7dff"
    property color inactiveColor: "#1f2a3d"
    property color borderActiveColor: "#84a9ff"
    property color borderInactiveColor: "#2f3b54"

    signal selectionEdited(var selection)
    signal cellActivated(int index, bool selected)

    padding: 12

    background: Rectangle {
        radius: 10
        color: "#101722"
        border.width: 1
        border.color: "#2b354a"
    }

    function clone(source) {
        var copy = {}
        if (!source) {
            return copy
        }
        for (var key in source) {
            if (source.hasOwnProperty(key) && source[key]) {
                copy[key] = true
            }
        }
        return copy
    }

    function isSelected(index) {
        var key = "" + index
        return _internalSelection && _internalSelection[key] === true
    }

    function setSelected(index, value) {
        if (!editable) {
            return
        }
        var key = "" + index
        var next = clone(_internalSelection)
        if (value) {
            next[key] = true
        } else if (next.hasOwnProperty(key)) {
            delete next[key]
        }
        _internalSelection = next
        selectionEdited(clone(_internalSelection))
        cellActivated(index, value)
    }

    function toggle(index) {
        setSelected(index, !isSelected(index))
    }

    onSelectionChanged: {
        _internalSelection = clone(selection)
    }

    Component.onCompleted: {
        _internalSelection = clone(selection)
    }

    contentItem: GridLayout {
        id: grid
        anchors.fill: parent
        columns: selector.columns
        rowSpacing: selector.cellSpacing
        columnSpacing: selector.cellSpacing

        Repeater {
            model: selector.rows * selector.columns
            delegate: Rectangle {
                readonly property bool selected: selector.isSelected(index)
                width: Math.max(selector.cellMinSize, Math.min(selector.cellMaxSize, selector.availableWidth() / selector.columns - selector.cellSpacing))
                height: width
                radius: 6
                color: selected ? selector.activeColor : selector.inactiveColor
                border.width: 1
                border.color: selected ? selector.borderActiveColor : selector.borderInactiveColor

                MouseArea {
                    anchors.fill: parent
                    enabled: selector.editable
                    onClicked: selector.toggle(index)
                }
            }
        }
    }

    function availableWidth() {
        return Math.max(1, width - (padding * 2))
    }
}
