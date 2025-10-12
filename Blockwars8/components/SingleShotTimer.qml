import QtQuick 2.15
import QuickFlux 1.1

Timer {
    property var action
    property var element
    property var params
    // Assing a function to this, that will be executed
    running: true
    triggeredOnStart: false
    onTriggered: {
        action(params)
        this.destroy(
                 ) // If this timer is dynamically instantitated it will be destroyed when triggered
    }
}
