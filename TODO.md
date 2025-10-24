# Active TODO Items
Change 9 - Grid State Machine and Control Flow
- Add ActionTypes.endTurn and ActionTypes.enablePowerups; add AppActions.endTurn() and AppActions.enablePowerups().
- GameGrid.qml: add properties currentGridState (init) and gridLocked (false).
- GameGrid.qml: add executeGridEvent case for controlGridStateChange that calls checkGridStateRequirements().
- GameGrid.qml: implement setGridState(new_state) with behaviors for idle, locked, compact, fill, match, launch.
- GameGrid.qml: implement checkGridStateRequirements() and controlGridState() helpers with 100ms timer rechecks.
- GameGrid.qml: guard handleGridEventExecute with gridLocked early return, except controlGridStateChange.
- GameGrid.qml: add AppListener for ActionTypes.endTurn to start this grid’s turn when other grid ends (set swaps=3, activeTurn=true, setGridState("compact")).
- GameGrid.qml: at end of checkMatches(), enqueue controlGridStateChange for this grid.
- Update WHEEL.md entries for new properties/functions and for AppActions/ActionTypes additions.
