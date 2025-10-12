import QtQuick 2.0
import QtQml.Models 2.15

Instantiator {
    model: 36
    delegate: QtObject{
        property var selected: false
        property var row: Math.floor(index / 6)
        property var col: index % 6
    }
}
