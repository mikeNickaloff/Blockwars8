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
import QuickFlux 1.1
import "../zones" 1.0
import QtQuick.LocalStorage 2.15
import com.blockwars 1.0

Item {
    id: gameController
    property var game_active_grid
    property var game_moves_remaining
    property var game_health: {
        "0": 2000,
        "1": 2000
    }
    property var game_waiting_for_local_callback: false
    property var game_waiting_for_network_callback: false

    function startGame() {
        game_active_grid = 1
        game_moves_remaining = 3
        AppActions.enableBlocks(1, true)
        AppActions.enableBlocks(0, false)
        AppActions.setActiveGrid(1)
    }

    property int switchesThisTurn: 0
    property int maxSwitches: 3

    // Handle block damage calculation
    function calculateDamage(launchBlockHealth, enemyBlocks) {
        var remainingHealth = launchBlockHealth;
        for (let i = 0; i < enemyBlocks.length; i++) {
            if (remainingHealth <= 0) break;
            let enemyBlock = enemyBlocks[i];
            if (remainingHealth >= enemyBlock.health) {
                remainingHealth -= enemyBlock.health;
                enemyBlocks[i] = null; // Block destroyed
            } else {
                enemyBlock.health -= remainingHealth;
                remainingHealth = 0;
            }
        }
        if (remainingHealth > 0) {
            applyPlayerDamage(remainingHealth);
        }
    }

    // Handle block switching logic
    function switchBlock() {
        if (switchesThisTurn >= maxSwitches) {
            console.log("Switch limit reached, end turn.");
            endTurn();
            return;
        }
        performBlockSwitch();
        switchesThisTurn++;
    }

    // End turn logic
    function endTurn() {
        switchesThisTurn = 0;
        disableSwitching();
        proceedToNextPlayer();
    }
}
