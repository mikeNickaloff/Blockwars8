function createOneShotTimer(element, duration, action) {
    var comp = Qt.createComponent(
                'qrc:///Blockwars8/components/SingleShotTimer.qml')
    comp.createObject(element, {
                          "action": action,
                          "interval": duration,
                          "element": element
                      })
}
