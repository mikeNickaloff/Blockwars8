# Change 1 - Pure QML Powerup Editor QuickFlux Action
## Status
- Completed

## Context
- Recent AGENTS.md updates reaffirm the requirement to drive new work through PLAN.md with tightly scoped implementation steps.
- The current powerup editor lives in `powerupeditordialog.cpp` with imperative widget code that conflicts with the QML-first direction and lacks QuickFlux integration.
- Designers requested a refreshed editor that keeps the existing powerup data schema but exposes each powerup in a dedicated card view navigated from a custom powerup list.

## Implementation Steps
- Scaffold a `quickflux/PowerupEditorAction.qml` namespace that encapsulates create, edit, delete, and open-card dispatchers while mirroring the existing slot payload structure (`slot_grids`, `slot_targets`, and related arrays).
- Build a companion `quickflux/PowerupEditorStore.qml` to adapt the legacy dialog data into observable QML state, bridging to existing persistence helpers for loading and saving powerup metadata.
- [x] Compose a pure-QML editor flow with high-level components such as `PowerupEditorView.qml`, `PowerupCardView.qml`, and `PowerupCatalogList.qml`, ensuring each card interaction delegates to abstract helper types instead of inline logic.
- [x] Wire QuickFlux actions to drive dialog visibility, card selection, and persistence operations so the runtime data contract remains compatible with the current JSON structures consumed elsewhere.
- [x] Persist created and edited entries to a `localPowerupData` LocalStorage table via the forthcoming `SQLDataStorage.qml`, encoding `assignments` and `data` payloads with shared `toHex()`/`fromHex()` utilities while maintaining slot assignment arrays (`SinglePlayerSlot1`…`MultiplayerSlot4`).
- [x] Update supporting documentation (PLAN.md status changes, APPROVED_CHANGES.md status, TODO.md tasks, WHEEL.md summaries) as milestones are reached during implementation.

## Status History
- Approved (Change 1) — awaiting implementation kickoff.
- WIP (Change 1) — QuickFlux action namespace scaffolded for slot lifecycle events.
- WIP (Change 1) — QML editor view composed with catalog and card abstractions.
- WIP (Change 1) — QuickFlux action wiring now governs editor visibility and persistence queues.

# Change 3 - Turn Cycle Coordination Overhaul
## Status
- Completed

## Context
- Swaps, launches, and settlement acknowledgements are tracked through scattered booleans in `TurnController`, letting turns end before all work completes.
- `GameGrid` immediately re-enables input for the newly active player when `setActiveGrid` fires, even if the turn handoff should stay locked until settlement finishes.
- UI elements lack clear signals differentiating resolving vs. ready states, so turn counters and prompts desync from the actual playable window.

## Implementation Steps
- [x] Introduce a coordinator QtObject inside `TurnController` that encapsulates per-grid counters (swap quota, launch debt, settlement flags) and exposes helpers for `beginTurn()`, swap events, and settlement notifications.
- [x] Update `handleSwapStarted`, `handleAnimationsCompleted`, and `handleGridSettled` to defer to the coordinator, enforce a three-swap quota per turn, and call `finishTurn()` only after quota and launch debt clear.
- [x] Adjust `finishTurn()` to wait for the defender grid’s `gridSettled` handshake before enabling that grid’s input and dispatching `setActiveGrid`.
- [x] Rework `GameGrid`’s `setActiveGrid` listener to stop toggling block input directly, responding instead to `enableBlocks` and new resolving/ready actions.
- [x] Emit/listen for new QuickFlux actions representing resolving vs. ready states so UI controls and turn counters react when the controller unlocks input.

## Status History
- Approved (Change 3) — Turn coordination overhaul ready for implementation.
- WIP (Change 3) — Implementation in progress per coordinator design.
- Completed (Change 3) — Coordinator-driven turn gating deployed with resolving/ready signaling.
# Change 4 - Rescan and Update WHEEL.md
## Status
- Completed
## Context
- WHEEL.md must reflect the current repository structure and expose functions/properties/signals for quick navigation.
- The file contains at least one duplicate entry and may be missing newer files.

## Proposed Changes
- Enumerate repo files (exclude build artifacts/tests/examples) and detect QML/JS/C++ signatures.
- Regenerate sections per file with functions/properties/signals discovered; normalize formatting; remove duplicates.
- Keep concise, auto-generated file summaries when no explicit documentation exists.
- Validate coverage against the repo file list and add any missing entries.

# Change 5 - GameGrid.refill() with Downward Compaction
## Status
- Completed

## Context
- Need a GameGrid-side refill that mirrors GridController.fill() but operates on `grid_blocks` and queues events through the controller’s queue.
- Before spawning new blocks, empty cells should be filled by moving existing blocks downward within each column while preserving order (standard gravity toward row 5).
- Event sequencing must respect ongoing animations; only enqueue `createBlocks` once movements have settled.

## Implementation Steps
- Add `refill()` to `Blockwars8/elements/GameGrid.qml` that:
  - Scans `grid_blocks` column-by-column, compacts non-null blocks downward (toward row 5), updating each block’s `row` and `y` to animate.
  - Calls `updateAnimationCounts()` and, if `animationCount > 0`, defers the spawn phase using `createOneShotTimer` to reattempt after animations settle.
  - When settled, constructs a `creationCounts` map like `GridController.fill()` by detecting `null` cells in `grid_blocks` and generating colors using `controller.getPool(i)`, `controller.getPoolIndex(i)`, and `controller.increasePoolIndex(i)`.
  - Pushes a `createBlocks` grid event with `create_counts` onto `controller.grid_event_queue`, then a `checkMatches` event, and triggers `controller.executeNextGridEvent()` if not waiting.
- Do not alter existing `GridController.fill()` or `GameGrid.createBlocks()`; `refill()` only orchestrates movement + event enqueue.
- Update `WHEEL.md` to document `GameGrid.refill()` once implemented.

## Status History
- Approved — ready for implementation.
- Completed — refill() implemented and WHEEL.md updated.
# Change 6 - Stepwise Refill Compaction (One Cell At A Time)
## Status
- Completed

## Context
- `GameGrid.refill()` should not clear columns or recreate existing blocks; it must move blocks down by one cell per iteration until fully compacted, then spawn new blocks only into empty cells.
- Animations tied to `y` changes require waiting for previous movements to finish before attempting further compaction steps.

## Implementation Steps
- Added helpers to `Blockwars8/elements/GameGrid.qml`:
  - `canMoveDown(row, col)` checks if a block exists at `(row,col)` and the cell below is empty.
  - `stepCompactDown()` scans columns bottom-up and moves eligible blocks down exactly one row, updating `grid_blocks`, the block’s `row`, and `y` to animate.
- Refactored `refill()` to:
  - Execute `stepCompactDown()` once; if any moved or animations are active, schedule a one-shot timer to rerun `refill()` after animation duration and return.
  - When settled, compute per-column missing counts and colors via controller pools and enqueue a single `createBlocks` event (with `missing` and `new_colors` for each column), followed by `checkMatches`, invoking `controller.executeNextGridEvent()` if idle.
  - `createBlocks(event)` now instantiates blocks only for empty rows using the provided `new_colors`, allowing partial-column refills (e.g., three blocks).

## Status History
- Approved — ready for implementation.
- Completed — helpers added and refill() refactored; refills emit a `createBlocks` event with per-column counts/colors to spawn only into empty rows.

# Change 7 - Cross-Platform Build & Install Docs in README
## Status
- Completed

## Context
- README.md lacks comprehensive, copy/paste-ready steps to build and run the app across Linux, macOS, and Windows.
- The project uses qmake with Qt 5.15.x and requires modules: `qml`, `quick`, `quickcontrols2`, `websockets`, `widgets`, `gui`, and `network`.
- QuickFlux is vendored in `quickflux/` and included via `quickflux.pri`; no external dependency fetch is required.

## Implementation Steps
- Add a unified Qt Creator section covering all platforms: open `Blockwars8.pro`, select a Qt 5.15.x kit, configure, build, run.
- Add CLI sections per platform:
  - Linux (Debian/Ubuntu, Fedora, Arch): install Qt dev packages (qtbase, declarative, quickcontrols2, websockets, tools), then `mkdir build && cd build && qmake .. && make -j$(nproc)`.
  - macOS: install Qt 5.15.x via Homebrew or Qt Online Installer; `mkdir build && cd build && qmake .. && make -j$(sysctl -n hw.ncpu)`; run the produced `.app`.
  - Windows (MSVC and MinGW): use the appropriate Qt command prompt; `mkdir build && cd build && qmake .. && nmake` (MSVC) or `mingw32-make` (MinGW); run the built `.exe`.
- Highlight selecting the correct `qmake` for Qt 5.15.2+ to avoid mismatched kits.
- Add optional packaging notes: `make install` on Unix, `windeployqt` on Windows, and `macdeployqt` on macOS.
- Add troubleshooting notes for missing Qt modules and QML imports, and for accidentally using Qt 6 `qmake`.

## Status History
- Approved — ready to implement in README.md.
- Completed — README.md updated with cross-platform build and install instructions.

# Change 8 - README Build Docs Formatting
## Status
- Completed

## Context
- The build/install section of README.md relies on nested bullet lists, making it harder to scan.
- The project owner requested markdown sections and fenced command blocks instead of bullets.

## Implementation Steps
- Restructure README.md build documentation to use headings per platform and task:
  - Linux (Ubuntu/Debian, Fedora/RHEL, Arch), macOS, Windows (MSVC, MinGW).
  - Subsections: Install dependencies, Clone repository, Build and run.
- Add a dedicated Qt Creator section (all platforms) with steps in a fenced block.
- Convert packaging and troubleshooting notes into sectioned paragraphs with code blocks.

## Status History
- Approved — ready to implement in README.md.
- Completed — README.md reformatted to use headers and fenced code blocks without bullet lists in build sections.

# Change 9 - Grid State Machine and Control Flow
## Status
- Approved

## Context
- Grid flow is event-driven but lacks an explicit state machine to coordinate compact/fill/match/launch/idle transitions per grid.
- Need a queued grid event `controlGridStateChange` and a handler inside `GameGrid` to evaluate readiness and advance states deterministically.
- Turn flow requires an `endTurn` action and corresponding `GameGrid` listener to begin the next grid’s turn when appropriate.
- Introduce `currentGridState` and `gridLocked` to gate interactions and ensure consistent enable/disable of swaps and powerups.

## Implementation Steps
- Add `currentGridState` property to `GameGrid.qml` with allowed values: "idle", "locked", "compact", "fill", "match", "launch", "init".
- Add `gridLocked` boolean that disables all event handling except minimal state control paths when true.
- Add handler for `controlGridStateChange` in `GameGrid`’s `AppListener` (`executeGridEvent`) to call `checkGridStateRequirements()`.
- Implement `checkGridStateRequirements()` to read `currentGridState` and decide transitions using `setGridState(new_state)`.
- Implement `setGridState(new_state)` to:
  - Update state, toggle `gridLocked`, and run state-linked `AppActions`.
  - States behavior:
    - "idle": `enableBlocks(true)` and `enablePowerups(true)` if `turns > 0` and `activeTurn`; else `enableBlocks(false)`, `enablePowerups(false)`, and dispatch `AppActions.endTurn(grid_id)`.
    - "locked": set `gridLocked = true`; early-return any non-state events.
    - "compact": disable swaps/powerups, run a compaction pass per column using the new pass (scan from row 5 downwards; when `(row,col)` empty, shift higher rows up one), then `controlGridState()`.
    - "fill": compute `createBlocks` parameters (modeled after `refill()`), enqueue `createBlocks`, and periodically check for all cells filled and animations settled before switching to "match".
    - "match": enqueue `checkMatches`; at end of detection, queue `controlGridStateChange`.
    - "launch": poll until `launchCount == 0 && animationCount == 0` then transition back to "compact".
- Add `ActionTypes.endTurn` and `AppActions.endTurn(grid_id)`; in `GameGrid`, add a listener for `endTurn` that starts this grid’s turn if the payload grid_id is the other grid.
- Stub `ActionTypes.enablePowerups` and `AppActions.enablePowerups(grid_id, enabled)` for future wiring.
- Ensure grid-event execution returns early when `gridLocked` is true (except for the control event), calling `gridEventDone` to keep the queue flowing.
- Update WHEEL.md for new GameGrid functions/properties and new AppActions/ActionTypes entries.

## Status History
- Approved — ready to implement.
# Change 10 - Powerup Editor Feature Parity
## Status
- Completed

## Context
- README promises customizable powerup damage, targets, colors, and automatic energy scaling tied to card life.
- The QML editor previously exposed read-only summaries without any editing controls.
- Legacy energy calculations ignored card life, diverging from the documented gameplay loop.

## Implementation Steps
- [x] Extend `PowerupEditorStore` with `slot_life`, a balanced energy calculator, and compatibility handling for existing data.
- [x] Replace the static catalog view with `PowerupEditorForm`, enabling live edits to targets, damage, color, life, and persistence.
- [x] Ship a reusable `PowerupGridSelector` component and mirror the lifecycle/energy updates inside the legacy `PowerupEditorDialog` widgets.
- [x] Surface the new life stat inside `PowerupCardView` and refresh WHEEL documentation plus the SQLite mirror.

## Status History
- Approved — Awaiting implementation kickoff.
- WIP — Store schema, editor form, grid selector, and dialog updates in progress.
- Completed — Powerup editor UX now matches README feature promises with updated documentation.
