import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQml.Models 2.15
import "../models"
import QtMultimedia 5.5
import QtQuick.Controls 2.0
import "../constants" 1.0
import "../actions" 1.0
import "../stores" 1.0
import com.blockwars 1.0
import QuickFlux 1.1
import "../zones" 1.0
import QtQuick.LocalStorage 2.15

Rectangle {
    function closeDialog() {
        powerupEditorDialog.closeDialog()
    }
    PowerupEditorDialog {
        id: powerupEditorDialog
        onSignal_powerups_saved: {
            MainStore.my_powerup_data = powerup_data
            AppActions.enterZoneMainMenu()
        }
        onSignalPowerupsLoaded: {
            powerupEditor.powerupsLoaded(0)
        }
    }
    signal powerupsLoaded(var grid_id)
    id: powerupEditor
    width: 500
    height: 400
    Component.onCompleted: {

    }

    function compressPowerupData(data) {
        return {
            "s": data.slot,
            "t": data.target,
            "a": data.amount,
            "h": data.hero_targets,
            "g": data.grid_targets.filter(function (item) {
                return item.selected
            }).map(function (item) {
                return [item.row, item.col]
            })
        }
    }

    function decompressPowerupData(data) {
        return {
            "slot": data.s,
            "target": data.t,
            "amount": data.a,
            "hero_targets": data.h,
            "grid_targets": data.g.map(function (item) {
                return {
                    "row": item[0],
                    "col": item[1],
                    "selected": true
                }
            })
        }
    }
}
