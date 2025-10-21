# ADDITIONAL AGENT INSTRUCTIONS

## WHEEL.MD
- Always read the file WHEEL.md  to see what other things have already been invented in this project
- WHEEL.md is to be updated with a list of every file and every function/property available in each file in the project along with a quick one sentence explainer as to what it does.
- WHEEL.md should use this format
```
  # PowerupLibraryView.qml 
  ## File details
  This file provides the viewing container class which transforms a PowerupRepository.qml Component into a formatted listView with information about each item from the PowerupRepository. 
  
  ## Functions
  ###  _formatCells(cells) -- formats an array of cells into a more easily viewed format
  
  ## Properties
  ### repository -- reference pointer to PowerupRepository.qml instance
  
  ## signals
  ### editRequested(var entry) -- signal is emitted whenever the edit button is clicked for a specific item form the ListView in this component.
```
- Always reference WHEEL.md when writing code and utilize existing types or helpers when possible instead of creating new ones. Try to use base classes to decrease the amount of overall code paths in the application be reusing existing ones.


## RULES.md 
- This file is to have the list of game rules which will govern the rules players must be constrained by and are forced to follow by the game itself
- In this file there should be 27 separate rules, for each one a brief but accurate list of functions, properties, and signals which when combined together result in the implementation of the rule
- Do not combine rules and do update RULES.md whenever you make new functions or modify existing ones to incorporate any of the 27 rules.
- The official rules are found at the very end of AGENTS.md
- Use this format for RULES.md
```
# 1. Both players start off with 2 complete grids of blocks which have no instances of 3 matching blocks of the same color either horizontally or vertically (adjacently) anywhere on their Game Grid 
- SinglePlayer/SinglePlayerMatchScene.qml: _assignSeeds() → dashboard.setBlockSeed()
- SinglePlayer/components/MatchDashboard.qml: setBlockSeed(seed, confirmationPromise)
- SinglePlayer/grid/GameGridElement.qml: _initialize(), beginFilling(), _generateBlockSpec(), _avoidColors()
- src/gamegridorchestrator.h: resetPool(), spawnSpecFor(), detectMatches()
...
```

## TODO.md
- Maintain a file TODO.md which contains the active list of to do items, which from time to time may have to be modified when the user requests a change in some feature or code practice.
- This TODO list is internal list for agents to utilize to keep the current state of the project organized and on task.
- Read the TODO file and implement the items one at a time and only start the next item after one is 100% completed.
- TODO items are generated based on the content found in UX.md, which contains a play by play description of how each game scene and interaction should be both in design and in behavior

## DEV_NOTES.md
- This file captures engineering rationale and guardrails for non-obvious behaviors (e.g., seeding without launches, launch timing/stagger, swap UX thresholds, defender fill gating, role‑swap stabilization, duplicate spawn prevention, and powerup occupancy/visuals).
- Consult DEV_NOTES.md before changing core flows or timings so that future work stays consistent with intended gameplay feel and avoids reintroducing previously fixed issues.

# CODING STYLE EXAMPLE

SelectPowerupscene.qml

    GameScene {
        id: selectPowerupSceneRootItem
        
        PowerupDataStore { 
            id: singlePlayerPowerupSelectedDataStore
            table:  "singlePlayerSelectedPowerupsForPlayer"

       }

        SelectPowerupSlotView {
            id: selectPowerupSlotViewer
            
            selectedPowerupDataStore: singlePlayerPowerupSelectedDataStore
            
            onOpenSelectionModal: function (slotIdx) {
            
                // call function from Powercatalog.qml
                powerupCatalog.openCatalogForSlot(slotIdx)
               
                // connect to function in PowerupCatalog.qml
               powerupCatalog.powerupChosen.connect(singlePlayerPowerupSelectedDataStore.updateSelectedPowerupData) 
            }
            
        }
        
        PowerupCatalog {
           id: powerupCatalog
          
       }
     }

The example code is more or less how things should look. Clean, neat, with very little messy code all over the place.
No cramming or functional hellscapes. 
C++ style abstraction OOP only when coding with QML or C++.

# CODING GUIDELINES

- Use UX.md descriptions as inspiration for how each scene in the game will look and behave.
- Use RULES.md as references as to how to enforce the overall flow of the game and limitations on what can be done and when.
- Use TODO.md list to determine what needs to be done still
- Use WHEEL.md to document all functions, signals, and properties for each .qml and .cpp/.h  file in the project
- Set yourself up for success. Write code so that it will be compatible and portable even when other components change 
- Break down large problems into multiple QML files, and use OOP style integration to keep them from being overly dependent
- Encapsulate code to manipulate and control other QML files as functions and properties with generic purposes - avoid being too specific and instead use relative values (parent.implicitWidth * 0.60) instead of 650
- Leave room everywhere to be able to tie in additional bells and whistles by connecting animations to events and then connecting events to their destinations so i can make things have little animated experiences as they transition through states
- Use states to control what interactive types are allowed to do and what role they play.
- GameGrid should have many many states
- Blocks should have many states
- Powerups should have a number of states from dead to onboard, to fully charged, to charging, to (possibly more so leave room) and make it all clean and easy to follow by a human who is lazy


 

## Rules
1. Both players start off with 2 complete grids of blocks which have no instances of 3 matching blocks of the same color either horizontally or vertically (adjacently) anywhere on their Game Grid 
2. One player is attacking, the other defending.  
3. The attacking player's GameGrid is allowed to switch any block with another block that is directly adjacent to it as long as making that switch will result in 3 blocks all of the same color being adjacent to each other either horizontally or vertically
4. after the switch is made, the Game Grid does not accept input or switches temporarily, but will clear any matches, launch those blocks, and after launching all blocks, will fill in the empty spaces by dropping blocks down to fill in (or raiing blocks up depending on orientation) and continue to infinitely cascade and launch any matches that occur, followed by a fill in until no matches exist. This is where the "switch move ends" and if a player has more than 0 switches remaining, the board will now unlock and let them switch again as long as all cells have a block in them and no match-3 matches are pressent and no block launch animations are in progress. 
5. All blocks that are 3 or more in a row or column and next to each other without any other blocks of different color in between will begin the launch animation which ultimately causes the blocks to be launched at the opponent's GameGrid
6. All matches will be launched and all animations (explosion on the opponent's game grid will fully complete, and at which point all remaining blocks on the attacker's GameGrid will fill by dropping down (or rising up) depending on the orientation of the GameGrid so that there are no floating blocks (blocks with spaces beneath them where blocks have launched after matching)
7. Once all blocks have fully filled in all spaces beneath them, then blocks will be pulled from a predetermined poool of blocks in order and drop in from the above the grid simultanously (or in rapid succession) until all of the GameGrid rows and columns (cells) have one block in them.
8. Once the GameGrid is full, then the process of checking for matches and launching any matches occurs again, followed by the waiting for launch animations and then filling in and finally refilling of blocks. 
9. The whole process will repeat and continuously launch blocks at the enemy until there are no 3-in-a-line matches anywhere on the attacker's GameGrid and the game grid has no blocks in every cell with no active animations (no launches) happening.
10. once there are no further matches, animations, or empty cells, then the game move is complete. The attacker's gamegrid will accept input again and then the attacker can make another switch which will kick off the whole process again from steps 4 thru 9.
11. Each player gets 3 moves, then after the moves and animations are fully completed, and the attacker's board is filled in, the attacker becomes the defender. 
12. When defending, the defender's GameGrid does not fill in blocks.  Blocks just stay in position and are destroyed by the attacker's launched blocks. After the attacker completes all 3 moves and all animations etc have completed, and their grid is completely filled in with no matches or launches happening, then the defender's board will fill in and launch any matches, followed by the fill in / check matches / launch matches / fill in loop
13. Once the defender's board is fully filled in with no more animatons or matches, then now the defender becoems the attacker and attacker becomes defender, repeating the entire process forever until one player's life reaches 0.
14. Life is taken from a player when all of their blocks in a column  are destroyed (which is controlled by the amount of power the blocks have when launched versus the amount of power each block has when hit by the launch).  When all blocks on a defender's grid are destroyed, any additional blocks in that column launched will damage the player directly. 
15. Blocks can be damaged and powered up by Powerups. Powerups can be customed to damage enemy blocks or players,  or can be setup to grant power to blocks either by color or by pre-selecting specific cell locations to power up or damage on either their own grid or the enemy grid. Powerups each have a color that matches one of the game colors which can be chosen as well. 
16. Depending on how much power the powerup is calling on (more blocks affected * more power amount = more required energy), each player will have to match blocks of the same color as that powerup in order to charge up its temporary magic energy before the Powerups can be used.  
17. The amount of damage done to an opponent's blocks or directly to the player is converted directly into energy of the color of the block that was launched.  
18. Launching a yellow block with 10 power that destroys 2 green blocks with 5 points each would result in 10 yellow energy being added to all yellow Powerups
19. Once a powerup reaches the amount of required energy, it can be activated by dragging it onto the gamegrid from the powerup hud and placed on the board (only for the first activation). 
20. Once on the board, it can be damaged by enemy blocks or enemy powerups just like any other block with its health being equivalent to its max energy to start. Powerups are not counted towards match-3 matches, and always are considered not matching color despite them possibly havig the same colors as other blocks or powerups. 
21. Powerups can move one square in any direction but it costs one move to do so. 
22. When powerups are activated, their magic energy is set to 0 and must be refilled before they can activate again.  
23. once killed, Powerups cannot be revived and will disappear from the board like any other block. 
24. Powerups should not drop down with the other blocks that fill in.  Their position should remain static and blocks should merely skip over them and consider cells with powerups to be occupied and blocks should continue on past them or stop if there are no empty spaces beneath the powerups.
25. Hitting a defender's powerup with a launched block or  other powerup attack will cause the powerup to be moved from its static position down to the lowest empty space on the defender's GameGrid. This is to allow for powerups to be pulled out of defensive positions behind many blocks to break up defensive positions. 
26. Activating a powerup does not use a move.
27. Powerups can only be activated or moved when attacking, never while defending. 
