# main.qml
## File details
Root `ApplicationWindow` that initializes stores, registers zone components, and routes navigation via a `StackView`.

## Functions
### None

## Properties
### None (uses standard `ApplicationWindow` sizing and a `StackView`)

## signals
### None


# Blockwars8.qrc
## File details
Qt Resource Collection bundling QML files, controller/element/components, and image assets used by the application.

## Functions
### None

## Properties
### None

## signals
### None


# Blockwars8/constants/Constants.qml
## File details
Singleton `KeyTable` for global constants (currently empty, reserved for future constant keys).

## Functions
### None

## Properties
### None

## signals
### None


# Blockwars8/actions/ActionTypes.qml
## File details
Singleton `KeyTable` of action type keys for QuickFlux dispatch/observe across the app.

## Functions
### None

## Properties
### startApp -- action key used to signal app start
### enterZoneMainMenu -- action key to enter the main menu zone
### quitApp -- action key to quit the app
### executeGridEvent -- action key for grid to execute a queued event
### enqueueGridEvent -- action key to queue a grid event
### gridEventDone -- action key indicating a grid event completed
### blockLaunchCompleted -- action key indicating a launched block finished
### blockFireAtTarget -- action key for firing a block at a target
### blockKilledFromFrontEnd -- action key when a block kill is reported by UI
### particleBlockKilledExplodeAtGlobal -- action key for death particle at global position
### particleBlockLaunchedGlobal -- action key for launch particle at global position
### fillGrid -- action key to fill a grid
### createOneBlock -- action key to create a single block
### swapBlocks -- action key to request a swap
### enableBlocks -- action key to enable/disable input on a grid
### sendNetworkEvent -- action key to emit a network event (abstracted)
### receiveNetworkEvent -- action key for receiving a network event
### sendNetworkEventDone -- action key indicating local network send completed
### receiveNetworkEventDone -- action key indicating remote handled event
### sendGameStateEvent -- action key to broadcast a summarized game state
### setBlockProperty -- action key to set a block property at a cell
### activatePowerup -- action key to activate a powerup slot
### modifyBlockHealth -- action key to adjust health at a cell
### setActiveGrid -- action key to mark which grid is active (attacker)
### powerupEditorNamespace -- namespace prefix for powerup editor lifecycle actions
### powerupEditorCreateSlot -- action key to request a new slot payload be created
### powerupEditorEditSlot -- action key to request a slot payload update
### powerupEditorDeleteSlot -- action key to request slot removal from the editor state
### powerupEditorOpenCard -- action key to announce that a slot card should be opened in the editor UI

## signals
### None


# quickflux/PowerupEditorAction.qml
## File details
Singleton `ActionCreator` façade that normalizes legacy slot payload structures and dispatches powerup editor lifecycle actions through QuickFlux.

## Functions
### createSlot(slotId, slotState, metadata) -- merges slot arrays with derived metadata, dispatching the create lifecycle event
### editSlot(slotId, slotState, metadata) -- emits an edit lifecycle event with normalized slot payload data
### deleteSlot(slotId, metadata) -- dispatches a delete lifecycle event scoped to the provided slot id
### openCard(slotId, metadata) -- announces that a slot card should become active without mutating slot payload arrays
### showEditor(metadata) -- toggles editor visibility through a QuickFlux directive action payload
### hideEditor(metadata) -- hides the editor pane by dispatching a namespaced directive without slot payloads
### persistSlot(slotId, slotState, metadata) -- queues a persistence lifecycle request mirroring the canonical slot payload contract

## Properties
### structuralCloner -- helper object that deeply clones JSON-compatible data structures prior to dispatching
### actionRegistry -- central registry exposing namespaced action keys and lifecycle helpers
### directiveComposer -- metadata composer that derives lifecycle descriptors for payload annotations
### payloadComposer -- normalizes slot payload arrays and merges directive metadata for dispatcher consumption
### dispatchCoordinator -- consolidates slot lifecycle and directive dispatch helpers routed through the QuickFlux dispatcher
### dispatchRelay -- abstraction over `AppDispatcher.dispatch()` that emits QuickFlux actions

## signals
### None


# quickflux/PowerupEditorStore.qml
## File details
Singleton QuickFlux store that hydrates powerup editor slot data from persistence, normalizes legacy payloads, and exposes observable arrays for QML workflows.

## Functions
### commitVisibility() -- synchronizes exported visibility properties from the visibility coordinator.
### commitPersistence() -- propagates persistence queue snapshots and pending metadata to observers.
### commitState() -- refreshes exported store properties after coordinated state changes or focus updates.

## Properties
### isHydrated -- indicates whether the persistence bootstrap completed successfully.
### isLoading -- flags when the store is currently reading from persistence.
### isEditorVisible -- true when the editor should be rendered for consumers listening to the store.
### visibilityDirective -- most recent directive metadata describing how visibility was toggled.
### persistenceQueue -- queued persistence requests awaiting downstream handling.
### lastPersistenceRequest -- latest persistence payload emitted by the coordinator.
### hasPendingPersistence -- convenience flag indicating whether persistenceQueue is non-empty.
### slotRecords -- canonical map of slot records keyed by slot id.
### slotArrays -- aggregated object containing `slot_grids`, `slot_targets`, `slot_types`, `slot_amounts`, `slot_colors`, and `slot_energy` arrays aligned by slot id.
### slotAssignments -- array of assignment lists derived from persistence metadata per slot.
### slotNames -- resolved display names for each slot index.
### slotOrder -- ordered list of available slot identifiers maintained by the state coordinator.
### activeSlotId -- currently focused slot id managed by the selection coordinator.
### tokens -- registry exposing the QuickFlux action keys for create/edit/delete/open/show/hide/persist lifecycles.
### dispatcherMetadata -- helper utilities to derive lifecycle directives from action keys and payloads.
### cloning -- structural cloning helper shared by translators and aggregators.
### schema -- canonical definitions for slot keys, defaults, and normalization helpers.
### blueprint -- record constructor that composes canonical snapshots from arbitrary payloads.
### persistenceBridge -- wrapper around `SQLDataStorage` providing row retrieval and decoding helpers.
### translator -- converts persistence/action payloads or legacy maps into canonical records.
### persistenceCoordinator -- aggregates canonical persistence requests for downstream storage integration.
### selectionCoordinator -- maintains focused slot state and ensures focus stability as slots change.
### stateCoordinator -- orchestrates record storage, aggregated arrays, and export snapshots for observers.
### hydrationLifecycle -- controls initial bootstrap and hydration status flags.
### mutationCoordinator -- routes QuickFlux lifecycle events into state mutations and focus updates.
### visibilityCoordinator -- manages editor visibility state and directive metadata extracted from actions.
### initializationCoordinator -- bootstraps store hydration and establishes initial visibility/persistence snapshots.

## signals
### None


# Blockwars8/actions/AppActions.qml
## File details
Singleton `ActionCreator` wrapper that provides ergonomic functions to dispatch all app actions through QuickFlux.

## Functions
### executeGridEvent(grid_event) -- dispatches a specific grid event payload for execution
### gridEventDone(grid_event) -- signals completion of a grid event
### blockFireAtTarget(i_data) -- dispatches an attack aimed at a target
### blockKilledFromFrontEnd(i_data) -- reports a block was destroyed
### particleBlockKilledExplodeAtGlobal(i_data) -- requests death explosion particle
### particleBlockLaunchedGlobal(i_data) -- requests launch particle
### blockLaunchCompleted(i_data) -- reports a completed block launch
### enqueueGridEvent(eventType, grid_id, eventParams) -- queues a typed grid event with params
### createOneShotTimer(element, duration, action, params) -- helper to create and run a one-shot timer
### fillGrid(grid_id, end_move_after) -- triggers a fill sequence for a grid
### createOneBlock(grid_id, row, column) -- requests creating a block at a cell
### swapBlocks(row, column, grid_id, direction) -- requests a swap in a direction from a cell
### enableBlocks(grid_id, blocks_enabled) -- toggles input on a grid
### sendNetworkEvent(eventType, eventParams) -- wraps and dispatches a network event
### receiveNetworkEvent(params) -- dispatches a received network event for handling
### sendNetworkEventDone(eventParams) -- signals that a send completed
### receiveNetworkEventDone(eventParams) -- signals receive completion
### sendGameStateEvent(gameState, eventParams) -- broadcasts a summarized game state event
### setBlockProperty(row, col, grid_id, propName, propValue) -- sets a property on a specific block
### activatePowerup(slot_id, grid_id) -- resolves config and applies powerup effect to target cells
### getPowerupProperty(powerupArray, slot_id, grid_id, powerupProperty) -- utility to fetch a property from powerup data
### modifyBlockHealth(row, column, grid_id, amount) -- modifies health at a specific grid cell
### setActiveGrid(grid_id) -- informs listeners which grid is active

## Properties
### None

## signals
### startApp -- signal style alias exposed by ActionCreator
### enterZoneMainMenu -- signal style alias to navigate to main menu
### quitApp -- signal style alias to request quitting


# Blockwars8/stores/MainStore.qml
## File details
QuickFlux `RootStore` binding that wires `AppDispatcher` to the root store for state updates.

## Functions
### None

## Properties
### bindSource -- dispatcher binding source (set to `AppDispatcher`)

## signals
### None


# Blockwars8/stores/RootStore.qml
## File details
Application store holding powerup data for both players and SQLite-backed persistence helpers.

## Functions
### loadDatabase() -- placeholder for database bootstrap (currently no-op)
### loadPowerupData() -- loads persisted entries from `localPowerupDataStorage`, decoding assignments and JSON payloads into `my_powerup_data`
### savePowerupData() -- normalizes the current slot map and writes it back using `localPowerupDataStorage.replaceAll()`
### ingestPowerupData(rawData) -- accepts raw editor payloads, normalizes them through `powerupPersistence`, updates `my_powerup_data`, and persists changes
### powerupPersistence.normalize(rawData) -- helper that unwraps lists/maps, assigns slot indices, and injects default names for storage
### powerupPersistence.encode(powerupData) -- converts normalized powerups into database rows with hex-encoded assignments/data
### powerupPersistence.decode(rows) -- rebuilds the slot-indexed map from stored rows while respecting assignment targets

## Properties
### text -- sample string value used by templates/UI
### my_powerup_data -- object mapping slot→powerup config (including display name) for the local player
### enemy_powerup_data -- array of powerup configurations for the opponent
### localPowerupDataStorage -- `SQLDataStorage` instance configured for the `localPowerupData` table
### powerupPersistence -- helper object encapsulating normalization/encoding utilities for powerup persistence

## signals
### None


# Blockwars8/models/GridModel.qml
## File details
Simple model of 36 cells using `Instantiator`, exposing row/col and selection per cell.

## Functions
### None

## Properties
### delegate.selected -- whether the cell is selected
### delegate.row -- row index computed from model index
### delegate.col -- column index computed from model index

## signals
### None


# Blockwars8/models/SQLDataStorage.qml
## File details
Reusable QtObject wrapper around Qt Quick LocalStorage that manages table creation, CRUD helpers, and hex-encoded JSON utilities.

## Functions
### database() -- opens (or creates) the configured LocalStorage database synchronously
### withTransaction(operation) -- runs a callback within a transaction, ensuring the table exists when `autoCreateTable` is true
### ensureTable(tx) -- creates the configured table using `columnDefinitions` when missing
### execute(tx, statement, values) -- executes SQL with error handling and returns row metadata
### rowsFromResultSet(resultSet) -- converts a `SqlResult` into an array of row objects
### insert(row) -- inserts or replaces a row based on key/value pairs
### update(values, criteria) -- updates rows matching the criteria map with new values
### select(criteria, columns) -- fetches rows filtered by criteria, optionally selecting specific columns
### selectAll(columns) -- convenience wrapper returning every row (optionally limited to given columns)
### remove(criteria) -- deletes rows matching the provided criteria map
### deleteAll() -- deletes every row in the current table
### replaceAll(rows) -- clears the table and bulk inserts the provided rows within one transaction
### toHex(value) -- JSON serializes and encodes a value as uppercase hexadecimal text
### fromHex(hex) -- decodes a hexadecimal payload and parses the resulting JSON back into its original value

## Properties
### databaseName -- LocalStorage database name (default "block.wars")
### version -- schema version string passed to LocalStorage
### description -- human-readable description of the database
### estimatedSize -- storage quota hint for the database
### table -- table name targeted by helper operations
### columnDefinitions -- object mapping column names to SQL definitions for `ensureTable`
### autoCreateTable -- flag indicating whether `ensureTable` runs automatically for each transaction

## signals
### None


# Blockwars8/controllers/GameController.qml
## File details
High-level game controller: tracks active grid, move counts, and basic switch/damage flow.

## Functions
### startGame() -- initializes attacker/defender and enables the correct grid
### calculateDamage(launchBlockHealth, enemyBlocks) -- applies damage to a column and overflows to player
### switchBlock() -- performs a switch if under limit and increments switch counter
### endTurn() -- resets turn counters, disables switching, and advances player

## Properties
### game_active_grid -- id of the currently active grid
### game_moves_remaining -- number of moves left for the active player
### game_health -- per-player health mapping
### game_waiting_for_local_callback -- flag indicating local event wait
### game_waiting_for_network_callback -- flag indicating network event wait
### switchesThisTurn -- number of swaps made in the current turn
### maxSwitches -- maximum swaps allowed per turn

## signals
### None


# Blockwars8/controllers/GridController.qml
## File details
Grid event orchestrator: maintains event queue, generates blocks from color pools, and drives fill/match execution.

## Functions
### index(row, column) -- computes linear index into 6x6 array
### executeNextGridEvent() -- dequeues and dispatches the next grid event
### getPool(column) -- returns the `Pool` instance for a given column
### getPoolIndex(column) -- returns the current index into the column’s random pool
### increasePoolIndex(column) -- increments and stores pool index for a column
### fill() -- scans columns, generates counts/colors to create, then queues check/match
### autoFillGrid(player) -- fills empty cells for a player with staggered timing
### startPlayerTurn(player) -- disables switching and initiates autofill
### fillBlockAtCell(cell) -- creates a block in a cell and re-enables switching when full

## Properties
### grid_id -- id of the associated grid view
### grid_event_queue -- FIFO list of pending grid events
### grid_block_data -- 6x6 logical grid storing block handles/nulls
### waitingForCallback -- true while awaiting callback before next event
### pool_0..pool_5 -- six `Pool` instances (one per column)
### pool_0_index..pool_5_index -- current indices for each column’s pool

## signals
### None


# Blockwars8/controllers/TurnController.qml
## File details
Turn-cycle manager: enforces attacker/defender roles, move limits, settlement/fill phases, and CPU move requests.

## Functions
### otherGrid(gridId) -- returns the opposite grid id given an id
### ensureState(gridId) -- retrieves or initializes per-grid turn state
### resetAllState() -- clears controller and per-grid state
### beginTurn(gridId, options) -- starts a turn for `gridId`, sets phases, and configures fills/launches
### handleSwapStarted(data) -- transitions to resolving phase and decrements moves
### handleAnimationsCompleted(info) -- transitions back to settling after animations
### handleGridSettled(info) -- drives auto-fill or enables input/next-turn based on empties/moves
### finishTurn(gridId) -- flips attacker/defender and begins the next turn
### maybeRequestCpuMove() -- requests a CPU move when CPU grid is awaiting input

## Properties
### gridOrder -- order of grids used to rotate turns
### cpuGridId -- grid id for the CPU
### playerGridId -- grid id for the player
### movesPerTurn -- number of allowed swaps per turn
### activeGrid -- currently active attacker grid id
### attackerGridId -- current attacker id
### defenderGridId -- current defender id
### stateByGrid -- internal map of per-grid turn state

## signals
### None


# Blockwars8/controllers/CpuController.qml
## File details
CPU controller: requests grid snapshots and computes simple swaps that create matches.

## Functions
### resetPendingRequest() -- clears any outstanding snapshot request id
### generateRequestId() -- creates a unique id for matching snapshots
### buildEmptyMatrix() -- creates an empty rows×columns matrix
### matrixFromCells(cells) -- builds a color matrix from cell snapshot data
### countDirection(matrix,row,column,dr,dc,color) -- counts consecutive cells of color in a direction
### formsMatch(matrix,row,column) -- checks if a cell contributes to a ≥3 run
### swapCreatesMatch(matrix,r1,c1,r2,c2) -- tests a swap for match creation
### findMove(matrix) -- finds the next legal swap that creates a match

## Properties
### gridId -- CPU-controlled grid id
### grid -- reference to grid element (for dimension introspection)
### rows -- computed row count from grid (default 6)
### columns -- computed column count from grid (default 6)
### pendingRequestId -- id of the outstanding grid snapshot request

## signals
### None


# Blockwars8/controllers/NetworkController.qml
## File details
Network shim for turn events using an IRC transport; queues outbound moves and defers when callbacks are pending.

## Functions
### sendMove(row1, col1, row2, col2) -- sends a MOVE message over IRC and dispatches a SWAP network event
### createOneShotTimer(element, duration, action, params) -- helper to delay actions using a one-shot timer

## Properties
### waiting_for_network_callback -- true while waiting for remote ack
### waiting_for_local_callback -- true while waiting for local grid to be ready

## signals
### None


# Blockwars8/zones/MainMenu.qml
## File details
Main menu view with four buttons that emits `changeZone` to switch zones.

## Functions
### None

## Properties
### None

## signals
### changeZone(var new_zone) -- emitted when user selects a new zone to enter


# Blockwars8/zones/SinglePlayer.qml
## File details
Single-player scene wiring two `GameGrid`s with their `GridController`s and matching `PowerupHud`s.

## Functions
### None

## Properties
### None

## signals
### None


# Blockwars8/zones/PowerupEditor.qml
## File details
Wrapper for `PowerupEditorDialog` that routes saved/loaded events to the store and closes when complete.

## Functions
### closeDialog() -- closes the embedded `PowerupEditorDialog`
### compressPowerupData(data) -- returns a compact representation of a powerup entry
### decompressPowerupData(data) -- expands a compact entry back to structured fields

## Properties
### None

## signals
### powerupsLoaded(var grid_id) -- emitted when dialog reports powerups loaded


# Blockwars8/zones/Options.qml
## File details
Simple placeholder options view that links back to main menu.

## Functions
### None

## Properties
### None

## signals
### None


# Blockwars8/zones/FindMatch.qml
## File details
Placeholder scene for matchmaking (to be implemented).

## Functions
### None

## Properties
### None

## signals
### None


# Blockwars8/components/SingleShotTimer.qml
## File details
Utility `Timer` that executes a provided function once and self-destroys after firing.

## Functions
### None

## Properties
### action -- callback function to invoke on trigger
### element -- host element owning the timer instance
### params -- argument object passed to `action`

## signals
### None


# Blockwars8/components/components.js
## File details
Helper JS for dynamically creating a one-shot timer component.

## Functions
### createOneShotTimer(element, duration, action) -- instantiates a `SingleShotTimer` bound to `element`

## Properties
### None

## signals
### None


# Blockwars8/components/DragZone.qml
## File details
Draggable tile source used by the powerup HUD to drag a slot onto the grid (enforces one-time deploy).

## Functions
### None

## Properties
### color -- visual color of the draggable tile
### grid_id -- grid id used in `Drag.keys` for acceptance
### slot_id -- source powerup slot id
### deployed -- true after a successful drop (disables further dragging)

## signals
### None


# Blockwars8/components/DropZone.qml
## File details
Drop target for accepting drags from `DragZone` limited by `grid_id` keys.

## Functions
### None

## Properties
### dropProxy -- alias to the `DropArea` (exposes drop API)
### grid_id -- grid id key required to accept drags

## signals
### None (uses built-in `DropArea` signals)


# Blockwars8/elements/GameGrid.qml
## File details
Primary grid view and state machine: manages block instances, launch/fill/shuffle flows, and match detection.

## Functions
### index(row, column) -- maps row/column to linear index
### handleGridEventExecute(event) -- dispatches to specific grid event handlers
### shuffleDownStep(event) -- iteratively collapses blocks downward and requests new block creation
### shuffleDown(event) -- starts the shuffle timer to collapse blocks
### countDrops(gridObj) -- computes how many rows each cell would drop after collapse
### handleBlockAnimationDoneEvent() -- decrements animation counter when a block finishes moving
### handleBlockAnimationStartEvent() -- increments animation counter when a block starts moving
### createOneBlock(event) -- creates an individual block at a target column and first empty row
### createBlocks(event) -- bulk-creates blocks per-column using provided color lists
### repositionGridBlocks(row) -- reapplies y-positions for all blocks based on their row
### updateBlocks(row) -- placeholder (kept for possible future direct reindexing)
### checkMatches(event) -- scans grid for 3+ runs, enqueues launches, and disables input while resolving
### createOneShotTimer(element, duration, action, params) -- local helper to delay actions
### updateAnimationCounts() -- recalculates how many blocks are mid-animation
### launchBlock(event) -- triggers a block launch, clears cell, and queues next steps
### cleanupBlocks() -- destroys any orphaned block items not tracked in `grid_blocks`
### fillBlocks(blocksToFill) -- staggers adding blocks then re-enables switching

## Properties
### maxColumn -- number of columns (default 6)
### maxRow -- number of rows (default 6)
### maxIndex -- linear grid size (rows×cols)
### board -- linear array backing store (legacy placeholder)
### grid_id -- id of this grid (0/1)
### current_event -- currently-processing grid event payload
### animationCount -- number of active animations
### grid_blocks -- 2D logical map of live `Block` instances (flattened)
### launchCount -- number of pending launches
### launchList -- list of linear indices already launched (de-dup)
### initialFill -- true until after first swap to gate health updates
### activeTurn -- whether this grid is currently the attacker
### turns -- remaining turns for this grid (local tracking)

## signals
### None (relies on `AppActions` and child `Block` signals)


# Blockwars8/elements/Block.qml
## File details
Visual block item with color/health, swap input handling, and animated launch/death sequences with particles.

## Functions
### launch() -- switches to launch animation, emits particles, then reports `blockLaunchCompleted`

## Properties
### uuid -- opaque identifier for the block (string-ish)
### column -- current column index
### row -- current row index
### grid_id -- grid id this block belongs to
### block_color -- color name used for art/logic
### isAttacking -- whether this block is actively launching
### isMoving -- whether this block is mid-move
### hasBeenLaunched -- toggled after launching or death
### block_health -- current health value for damage resolution

## signals
### animationStart -- emitted at the start of a movement animation
### animationDone -- emitted at the end of a movement animation
### rowUpdated(var row) -- emitted when `row` changes for dependent logic


# Blockwars8/elements/BlockLaunchParticle.qml
## File details
Particle system for launch “flash/tracer” effects with enable/disable and burst helpers.

## Functions
### burstAt(xpos, ypos) -- emits a burst at screen coordinates
### enableEmitter() -- turns on the emitter
### disableEmitter() -- turns off the emitter

## Properties
### None

## signals
### None


# Blockwars8/elements/BlockExplodeParticle.qml
## File details
Particle system for block explosion effects with multiple emitters and a single `burstAt` entry point.

## Functions
### burstAt(xpos, ypos) -- triggers a combined explosion/smoke/ember burst at coordinates

## Properties
### system -- particle system instance reference for chaining

## signals
### None


# Blockwars8/elements/PowerupHud.qml
## File details
Side HUD with four draggable powerup slots (`DragZone`) parameterized per grid.

## Functions
### None

## Properties
### grid_id -- id of the grid this HUD controls

## signals
### None


# Blockwars8/elements/GameBoardDashboard.qml
## File details
Dashboard for powerup runtime state, energy bars, drag-to-deploy proxies, and activation click targets.

## Functions
### extractEntry(index) -- returns the configured powerup entry for a slot index
### refreshFromStore() -- synchronizes dashboard with `MainStore.single_player_dashboard_data`
### setSeed(seedValue) -- sets and acknowledges a pool seed, emitting a command when changed
### setSwitchingEnabled(value) -- records whether swapping is enabled for this grid
### setFillingEnabled(value) -- records whether filling is enabled
### beginFilling(payload) -- records a begin-fill payload
### turnEnded(payload) -- records a turn-end payload and disables switching
### beginTurn(payload) -- records a begin-turn payload
### setLaunchOnMatchEnabled(value) -- records whether matches auto-launch
### activatePowerup(payload) -- records the last activated powerup payload
### runtimeSlot(slotIndex) -- returns stored runtime slot state for a position
### countSelected(entry) -- counts selected grid targets for an entry
### colorForName(name) -- maps color names to themed colors

## Properties
### gridId -- grid id this dashboard represents
### role -- role label (cpu/player)
### powerupEntries -- list of current powerup definitions
### readyNotified -- internal ready state throttle
### powerDataNotified -- internal power data notification flag
### seedAcknowledged -- whether a seed was acknowledged
### poolSeed -- last seed value used for pools
### switchingEnabled -- whether grid swapping is enabled
### fillingEnabled -- whether fill cycles are enabled
### launchOnMatchEnabled -- whether match-3 results launch blocks
### lastBeginTurnPayload -- last payload for a turn start
### lastTurnEndedPayload -- last payload for a turn end
### lastBeginFillPayload -- last payload for a fill begin
### lastActivatedPowerup -- last powerup activation payload
### topOrientation -- derived orientation (top/bottom) from grid id
### runtimeSlots -- per-slot runtime state map
### dragPermissions -- per-slot drag permission map
### activationPermissions -- per-slot activation permission map

## signals
### readyStateMod(int gridId, bool ready, string role) -- emitted on ready state changes
### dashboardCommand(int gridId, string command, var payload) -- emitted when commands should be sent


# Blockwars8/elements/PowerupTile.qml
## File details
Non-matchable tile representing a deployed powerup with color, health, and grid position.

## Functions
### None

## Properties
### colorName -- display color of the tile
### gridId -- id of the grid containing the tile
### slotId -- originating powerup slot
### displayName -- user-facing label for the tile
### matchable -- whether it participates in matches (false for powerups)
### row -- current row
### column -- current column
### rightColumn -- convenience for mirrored column position
### maxHealth -- maximum health of the powerup
### health -- current health of the powerup

## signals
### None


# Blockwars8/controllers/qmldir
## File details
QML module index for the controllers package.

## Functions
### None

## Properties
### None

## signals
### None


# Blockwars8/zones/qmldir
## File details
QML module index for the zones package.

## Functions
### None

## Properties
### None

## signals
### None


# Blockwars8/stores/qmldir
## File details
QML module index for the stores package.

## Functions
### None

## Properties
### None

## signals
### None


# Blockwars8/actions/qmldir
## File details
QML module index for the actions package.

## Functions
### None

## Properties
### None

## signals
### None


# Blockwars8/components/qmldir
## File details
QML module index for the components package.

## Functions
### None

## Properties
### None

## signals
### None


# Blockwars8/elements/qmldir
## File details
QML module index for the elements package.

## Functions
### None

## Properties
### None

## signals
### None


# pool.h / pool.cpp
## File details
Qt `QObject` exposing a seeded pseudo-random color source backed by a pre-generated resource file.

## Functions
### Pool::loadNumbers() -- loads digit stream from `:/random_numbers.txt` into a position→value map
### Pool::randomNumber(current_index=-1) -- returns the next color number, optionally starting at `current_index`

## Properties
### m_numbers -- map of index→color digit parsed from resource
### pool_index -- current index pointer into the pool sequence

## signals
### None


# appview.h / appview.cpp
## File details
Bridges C++ application startup with QML; loads `main.qml` and forwards QuickFlux dispatches.

## Functions
### AppView::start() -- loads QML engine, connects dispatcher, and dispatches `startApp`
### AppView::onDispatched(type, message) -- slot for observing dispatched messages (currently unused)

## Properties
### None

## signals
### None


# database.h / database.cpp
## File details
In-memory object database for `DataNode` instances with simple JSON import/export and IRC bootstrap.

## Functions
### Database::generateUuid() -- returns a short random alphanumeric id
### Database::connectToIRC() -- constructs `IRCSocket` and connects to server with a random nick
### Database::getDataNodeJsonValue(uuid, jsonKey) -- retrieves a JSON value from a node
### Database::createDataNode(node_type, uuid) -- creates (or reuses) a `DataNode` and returns its uuid
### Database::setDataNodeJsonValue(uuid, jsonKey, jsonValue) -- sets a JSON value on a node
### Database::getDataNode(uuid) -- returns a pointer to a stored node
### Database::importDataNode(obj) -- imports a serialized node into the store
### Database::listDataNodes(matchingProperties, invert=false) -- returns uuids matching (or not) a property set
### Database::startMultiplayer(abilities) -- joins a randomized IRC channel for multiplayer
### Database::ircMyNickname() -- returns current nickname
### Database::ircOpponentNickname() -- derives opponent nickname from current channel
### Database::createBlockNode(blockData) -- creates a `DataNode` for a block and emits `blockNodeCreated`
### Database::handleDataNodeJsonDataChange(uuid, key, value) -- slot relaying json-data change signals

## Properties
### m_dataNodes -- map of uuid→`DataNode*` entries
### new_node -- transient pointer for creation paths
### m_irc -- IRC socket handle

## signals
### blockNodeCreated(QJsonObject blockData) -- emitted when a block node is created
### dataNodeJsonDataUpdate(QString uuid, QString key, QVariant value) -- emitted on json data updates


# datanode.h / datanode.cpp
## File details
Hierarchical data node with JSON state, cached QVariant map, and child-node relationships.

## Functions
### DataNode::getUuid() -- returns the node uuid
### DataNode::setUuid(uuid) -- sets uuid (and mirrors into json)
### DataNode::getJsonDataObject() -- returns full JSON object
### DataNode::setJsonDataObject(obj) -- replaces full JSON object
### DataNode::getCachedData() -- returns cached QVariant map
### DataNode::setCachedData(map) -- replaces cache
### DataNode::getChildNodes() -- returns map of child nodes
### DataNode::setChildNodes(map) -- replaces child-node map
### DataNode::getDataType() -- returns type label
### DataNode::setDataType(type) -- sets and mirrors type label
### DataNode::setJsonData(key, value) -- sets a single json value and updates cache
### DataNode::cacheJsonData() -- rebuilds `m_cachedData` from `m_jsonData`
### DataNode::getJsonData(key) -- returns a value (ensures key exists)
### DataNode::import(json) -- populates state/children from serialized JSON
### DataNode::exportData(encodeObject=false) -- exports a serializable object of node state
### DataNode::findDataNode(uuid) -- searches subtree for a matching uuid
### DataNode::findAll(typeName) -- returns uuids for all nodes of a type (not fully implemented here)
### DataNode::encodeJson(..) / decodeJson(..) -- converts between raw and hex-encoded JSON values
### DataNode::addChildNode(child) -- adds a child node to the map
### DataNode::containsChild(uuid) -- checks if uuid exists in subtree
### DataNode::createTemplateString(templateStr) -- replaces %key% placeholders with json values
### DataNode::createQMLComponent(templateStr) -- renders a QML `Item` source string from template

## Properties
### uuid -- Q_PROPERTY for node uuid
### jsonData -- Q_PROPERTY for underlying JSON object
### cachedData -- Q_PROPERTY for cached QVariant map of json items
### childNodes -- Q_PROPERTY for child node map
### dataType -- Q_PROPERTY for type label stored on node

## signals
### uuidChanged() -- emitted when uuid changes
### jsonDataChanged() -- emitted when json data object changes
### cachedDataChanged() -- emitted when cache is rebuilt
### childNodesChanged() -- emitted when child map changes
### dataTypeChanged() -- emitted when data type changes
### jsonDataValueAssigned(QString uuid, QString key, QVariant value) -- emitted for json key assignment


# ircsocket.h / ircsocket.cpp
## File details
Minimal IRC client for messaging and ad-hoc game-channel communication with multipart support.

## Functions
### IRCSocket::connectToServer(address, port, nick) -- connects and initiates handshake with server
### IRCSocket::sendData(data) -- sends raw protocol data
### IRCSocket::sendPrivateMessage(channel, msg) -- sends PRIVMSG to a channel/user
### IRCSocket::joinChannel(channel, password="") -- joins an IRC channel
### IRCSocket::leave(channel, message="") -- parts an IRC channel
### IRCSocket::quit(message="") -- quits and closes socket
### IRCSocket::whoQuery(queryString) -- issues a WHO query, returns id
### IRCSocket::nickname() -- returns current nickname
### IRCSocket::compress(str) / uncompress(str) -- stubs for (de)compression of message payloads
### IRCSocket::getNicknameFromUserHost(userhost) -- extracts nickname from userhost
### IRCSocket::getOpponentNickname() -- resolves opponent nick from game channel name
### IRCSocket::sendMessageToCurrentChannel(message) -- queues/sends channel messages with multipart framing
### IRCSocket::gameCommandMessage(cmd, message) -- formats a game command/message pair
### IRCSocket::makeJSONDocument(doc) -- parses JSON into a QVariant
### IRCSocket::hash(string) -- returns an MD5 base64 hash string
### IRCSocket::sendChannelMessage(message) -- sends a namespaced channel message
### IRCSocket::socketConnected() -- slot: updates state and emits `connected`
### IRCSocket::readyRead() -- slot: reads, splits, and handles incoming data
### IRCSocket::socketError(err) -- slot: forwards socket error

## Properties
### currentChannel -- Q_PROPERTY name for the active channel (get/set)
### sentBytes -- running count of bytes sent
### my_nickname -- nickname used by this client
### opponent_nickname -- last-resolved opponent nickname

## signals
### error(QAbstractSocket::SocketError) -- emitted on socket error
### connected() -- emitted on TCP connect
### handshakeComplete() -- emitted when IRC handshake completes
### privateMessage(QString,QString,QString) -- emitted on PRIVMSG
### channelMode(QString,QString,QString,QString) -- emitted on MODE changes
### userMode(QString,QString) -- emitted on user mode changes
### userJoin(QString,QString) -- emitted on JOIN
### userQuit(QString,QString) -- emitted on QUIT
### userLeave(QString,QString,QString) -- emitted on PART
### whoQueryResult(int, QStringList) -- emitted with WHO results
### gameMessageReceived(QString, QString) -- emitted when a game message is received
### localGameMessageReceived(QString, QString, QString) -- emitted for local game messages
### channelMessageReceived(QString) -- emitted when a channel message is received


# irc.h
## File details
Lightweight IRC wrapper exposed to QML for simple connect and send operations (demo/testing helper).

## Functions
### IRC::connectToServer(server, port) -- connects to the given IRC server
### IRC::sendMessage(message) -- writes a raw message to the IRC socket
### IRC::onConnected() -- slot: performs NICK/USER registration
### IRC::onReadyRead() -- slot: reads server data and responds to PING
### IRC::sendToGame(message) -- stub for future game-channel messaging

## Properties
### game_channel -- string name of the game channel (unused placeholder)

## signals
### None (uses qDebug for tracing)


# promiselatch.h / promiselatch.cpp
## File details
Generic “countdown latch” for QML/JS flows; tracks multiple async requirements and emits when all are done.

## Functions
### PromiseLatch::require(fn) -- adds a requirement; if callable, passes resolve/reject closures
### PromiseLatch::requireNamed(key) -- adds a requirement tracked by a key
### PromiseLatch::resolve(id) / reject(id) -- resolves or rejects a requirement by id
### PromiseLatch::resolveNamed(key) / rejectNamed(key) -- resolves or rejects a requirement by key
### PromiseLatch::dispose() -- schedules the latch object for deletion
### PromiseUtils::create(parent) -- convenience to construct a `PromiseLatch` from QML
### PromiseLatchCallbackProxy::resolve() / reject() -- helper methods used by JS closures

## Properties
### total -- number of total requirements added
### remaining -- number of outstanding requirements
### done -- true when all requirements are resolved/rejected
### failed -- true if any requirement was rejected

## signals
### all() -- emitted when all requirements are resolved (no failures)
### failed(QString key) -- emitted when a requirement is rejected
### progress(int remaining, int total) -- emitted on progress changes
### doneChanged(bool done) -- emitted when overall done state flips
### failedChanged(bool failedState) -- emitted when failure state flips


# ClickableLabel.h
## File details
Simple QObject event filter that invokes a provided callback when the parent receives a mouse press.

## Functions
### eventFilter(obj, event) -- intercepts mouse presses to call the stored onClick callback

## Properties
### None

## signals
### None


# powerupeditordialog.h / powerupeditordialog.cpp
## File details
Qt Widgets dialog that lets users configure four powerup slots (target/type/color/amount/energy/grid targets).

## Functions
### PowerupEditorDialog::showDialog() -- constructs and opens the dialog UI
### PowerupEditorDialog::collectFormData(slot_num) -- returns a JSON array representing a slot’s config
### PowerupEditorDialog::loadPowerupsFromJSON() -- loads powerup data from `powerups.json` in app dir
### PowerupEditorDialog::updateWidgetsFromJSONArray(array) -- syncs UI widgets/selection from JSON
### PowerupEditorDialog::updateEnergy(slot_num=-1) -- recalculates and updates energy fields
### PowerupEditorDialog::updateAllEnergy() -- recomputes energy for all slots
### PowerupEditorDialog::closeDialog() -- closes the dialog (invokable from QML)

## Properties
### slot_grids / slot_targets / slot_types / slot_amounts / slot_colors / slot_energy -- per-slot settings caches
### slot_*_combos / slot_*_spins -- widget pointers for each slot’s controls
### slot_grids_widgets -- container widgets for grid selection UIs
### dialog -- pointer to the owning QDialog

## signals
### toggleGridSelection(int slot, int row, int col) -- emitted to toggle a cell in the grid UI
### signal_powerups_saved(QJsonArray powerup_data) -- emitted when user saves powerups
### signalPowerupsLoaded() -- emitted after loading initial powerups


# Blockwars8/components/DragZone.qml (relisted)
## File details
See above; used by `PowerupHud` to deploy powerups onto the grid via drag-and-drop.

## Functions
### None

## Properties
### See above

## signals
### None


# Blockwars8/images/*
## File details
Raster assets and sprite sheets for blocks and particles used by `Block` and particle components.

## Functions
### None

## Properties
### None

## signals
### None


# random_numbers.txt
## File details
Digit stream used by `Pool` to generate deterministic color sequences for column pools.

## Functions
### None

## Properties
### None

## signals
### None


# main.cpp
## File details
Application entry point: registers QML types, starts the QML engine, and enters the event loop.

## Functions
### main(argc, argv) -- sets env, registers `Pool`, `IRC`, `PowerupEditorDialog`, and runs the app

## Properties
### None

## signals
### None


# README.md
## File details
Project overview and usage guide (if present).

## Functions
### None

## Properties
### None

## signals
### None


# Blockwars8.pro / deployment.pri / qpm.pri / qpm.json
## File details
Qt project and packaging metadata used to build and deploy the application and dependencies.

## Functions
### None

## Properties
### None

## signals
### None


# Blockwars8/elements/PowerupCatalogList.qml
## File details
Pane-based catalog list that renders powerup slot summaries and dispatches selection requests through a provided coordinator.

## Functions
### resolver.indexFor(list, slotId) -- resolves the index for a slot id within the current entry list.
### resolver.title(entry) -- produces a display name for the provided catalog entry.
### resolver.subtitle(entry) -- generates a localized assignment summary for the entry.

## Properties
### provider -- external coordinator exposing `entries()` and `openSlot()` for catalog data.
### selectionProvider -- object exposing `activeSlotId` used to highlight the focused entry.
### entries -- evaluated array of catalog entry descriptors generated from the provider.
### activeSlotId -- derived slot identifier matching the current focus from the selection provider.
### highlightedIndex -- computed index aligned to the focused slot for `ListView` highlighting.
### resolver -- helper object encapsulating formatting utilities for delegate content.

## signals
### None

# Blockwars8/elements/PowerupCardView.qml
## File details
Pane that visualizes the currently selected powerup slot details, including metadata, assignments, and state summaries.

## Functions
### refresh() -- requests a new snapshot from the injected behavior coordinator for the active slot id.
### presenter.valueText(value, placeholder) -- formats primitive values with placeholders for display labels.
### presenter.assignmentsText(snapshot) -- renders assignment arrays into a comma-separated string.
### presenter.gridSummary(snapshot) -- outputs a human-readable summary of grid selections for the slot.
### presenter.metadataSummary(snapshot) -- serializes metadata into a multi-line string for read-only viewing.

## Properties
### behavior -- coordinator object exposing `snapshot(slotId)` and metadata helpers for card rendering.
### slotId -- currently active slot identifier to request details for.
### snapshot -- cached slot snapshot returned by the coordinator.
### fallbackText -- descriptive text displayed when no slot is selected.
### presenter -- helper object containing text-formatting utilities used by the view.

## signals
### None

# Blockwars8/elements/PowerupEditorView.qml
## File details
High-level editor container that composes the catalog list and card view around the QuickFlux store façade for powerup slots.

## Functions
### storeFacade.openSlot(slotId, metadata) -- routes a slot focus request through the QuickFlux action façade.
### catalogCoordinator.entries() -- projects store state into catalog entry descriptors.
### catalogCoordinator.openSlot(slotId) -- forwards slot focus requests to the store façade.
### cardCoordinator.snapshot(slotId) -- assembles a detailed snapshot for the requested slot id.
### cardCoordinator.fallbackText() -- supplies the fallback messaging for empty card state.

## Properties
### storeFacade -- façade exposing store state, canonical extractors, and dispatch helpers.
### catalogCoordinator -- helper object binding catalog state to `PowerupCatalogList`.
### cardCoordinator -- helper object binding slot state to `PowerupCardView`.
### visible -- bound to the QuickFlux store’s `isEditorVisible` flag so actions can toggle the pane.

## signals
### None
