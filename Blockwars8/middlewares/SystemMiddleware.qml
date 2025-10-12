import QtQuick 2.7
import QuickFlux 1.1
import "../actions"
import "../zones"

Middleware {

    property var mainWindow: null

    function dispatch(type, message) {
        next(type, message)
        switch (type) {
        case ActionTypes.startApp:
            mainWindow.visible = true
            next(type, message)
            break
        case ActionTypes.enterZoneMainMenu:

            break
        case ActionTypes.quitApp:
            Qt.quit()
            break
        default:
            next(type, message)
            break
        }
    }
}
