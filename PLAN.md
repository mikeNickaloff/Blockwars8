# Change 3 - Turn Cycle Coordination Overhaul
## Status
- Complete
## Context
- Launch/cascade bookkeeping lives across ad-hoc flags in `TurnController`, allowing premature role swap before grids finish resolving.
- Swaps are currently limited only by remaining moves, so players can queue extra swaps before animations settle.
- `GameGrid` enables input immediately on `setActiveGrid`, letting the defender regain control before their grid is stable.
## Proposed Changes
- Add a turn-state coordinator inside `TurnController` that tracks move counts, pending launch/animation work, and settlement acknowledgements per grid with reset helpers for `beginTurn()`.
- Gate swap handling through the coordinator so only three swaps can start per turn, launch counters block completion until all cascades finish, and `finishTurn()` waits for settlement.
- Emit new QuickFlux signals for "turn resolving" and "turn ready" states so UI updates align with coordinator state, and rely on `enableBlocks` toggles instead of `setActiveGrid`.
- Update `GameGrid` listeners to defer enabling input until explicit `enableBlocks` requests and reflect the new resolving/ready actions in grid state.
## Questions / Comments
- Completed per direct user request; no outstanding questions.

# Change 1 - Local Powerup Persistence Completion
## Status
- Complete
## Context
- QuickFlux editor state currently queues persistence requests without writing them into the `localPowerupData` LocalStorage table.
- The SinglePlayer zone still references the deprecated `onPowerupsLoaded` handler, triggering runtime errors during startup.
- Documentation artifacts (PLAN, APPROVED_CHANGES, TODO, WHEEL) must acknowledge the milestone once persistence is wired end-to-end.
## Proposed Changes
- Extend `PowerupEditorStore` with a dedicated persistence lifecycle helper that converts canonical slot records into SQL rows, encoding assignments and payloads via `SQLDataStorage` hex utilities before flushing them with `replaceAll()`.
- Gate persistence writes until hydration completes, ensure processed queue entries clear without losing metadata, and trigger store commits after synchronization.
- Replace the hidden `PowerupEditor` loader in `SinglePlayer.qml` with an abstraction that watches `PowerupEditorStore.isHydrated` to reveal the scene once persistence bootstrap finishes.
- Update APPROVED_CHANGES.md, TODO.md, and WHEEL.md to capture the completed persistence milestone and associated bug fix.
## Questions / Comments
- None.

# Change 1 - QuickFlux Action Wiring for Editor Flow
## Status
- Complete
## Context
- The QuickFlux namespace now exposes action stubs that must orchestrate dialog visibility and card selection consistently with the legacy dialog lifecycle.
- Persisted slot payloads require dispatch pathways that preserve the JSON contract expected by downstream consumers.
- Completing Implementation Step 4 of Change 1 unblocks the subsequent persistence integration task.
## Proposed Changes
- Map `PowerupEditorAction` dispatchers to store mutations that toggle editor visibility, set the active card, and emit persistence requests.
- Introduce intermediary coordinator classes that translate high-level action inputs into concrete store commands, avoiding inline business logic inside QML signals.
- Ensure action payloads mirror existing JSON schema keys (`slot_grids`, `slot_targets`, etc.) so legacy consumers remain functional.
## Questions / Comments
- None at this time; expecting alignment with previously approved payload structure.

# Change 1 - PowerupEditorStore Hydration Layer
## Status
- Complete
## Context
- QuickFlux powerup editor actions need a singleton store that exposes observable slot state derived from the legacy dialog schema.
- Implementation Step 2 of Change 1 mandates translating persisted slot payloads into a QML-first workflow without replacing existing persistence utilities.
## Proposed Changes
- Instantiate a `PowerupEditorStore` QuickFlux singleton that bootstraps from the `localPowerupData` table through the shared `SQLDataStorage` helper.
- Compose nested helper objects (token registry, cloning utilities, translators, state coordinators, selection coordinators) to normalize legacy payloads into canonical slot arrays and metadata snapshots.
- Wire action listeners for create, edit, delete, and open-card lifecycles so downstream QML components can react to slot mutations via observable properties.
## Questions / Comments
- None.

# Change 2 - Reusable SQLDataStorage QML Helper
## Status
- Pending
## Context
- Persisting custom powerup metadata requires a reusable LocalStorage abstraction that aligns with upcoming QML-first flows.
- Future scenes beyond the editor will need convenient insert/update/select helpers without duplicating imperative JavaScript.
- Encoding arbitrary JSON payloads in hexadecimal ensures compatibility with the storage backend's text constraints.

## Proposed Changes
- Design a `SQLDataStorage.qml` type that wraps Qt Quick LocalStorage access with a configurable `table` property and lifecycle hooks to ensure schema creation.
- Expose reusable operations (e.g., insert, update, select, selectAll) that accept structured parameter objects and normalize them into SQL statements with bound values.
- Implement shared encoding utilities `toHex(value)` and `fromHex(value)` to translate JSON-friendly data into hexadecimal strings and back, including arrays and objects.
- Add defensive error handling/logging to capture SQL failures without crashing the UI, returning informative results to callers.
- Document the new helper in WHEEL.md and create TODO entries once approved for implementation.

## Questions / Comments
- Should the helper also expose transaction batching now, or defer until a concrete use case emerges?
<!-- Change 5 moved to APPROVED_CHANGES.md -->
# Change 6 - Stepwise Refill Compaction (One Cell At A Time)
## Status
- Pending
## Context
- Current `GameGrid.refill()` compacts by reassigning final rows per column, briefly nulling column slots which risks disrupting QML block instances.
- Requirement: do not clear column arrays; instead, move blocks down one row at a time, bottom-up, preserving order and re-run until fully compacted.
- Animation behavior on `y` means subsequent drops should wait until prior movements settle before the next step.

## Proposed Changes
- Add helpers inside `GameGrid.qml`:
  - `canMoveDown(row, col)` returns true when a block exists at `(row,col)` and `(row+1,col)` is empty.
  - `stepCompactDown()` scans columns bottom-up, performs at most one-cell drops per block, updates `grid_blocks` references, `row`, and `y`; returns a boolean `moved`.
- Refactor `refill()` to:
  - Call `stepCompactDown()`; if `moved` or `animationCount > 0`, schedule a one-shot timer to call `refill()` again after animation duration, then `return`.
  - When no moves remain and animations have settled, compute `creationCounts` from remaining nulls in `grid_blocks`, using `controller.getPool(col)`, `controller.getPoolIndex(col)`, and `controller.increasePoolIndex(col)`.
  - Enqueue `createBlocks` then `checkMatches` on `controller.grid_event_queue` and trigger `controller.executeNextGridEvent()` if idle.
- Update WHEEL.md to document new helper functions.

## Questions / Comments
- Timing: use the existing drop animation duration heuristic (`(25 * 6) + (25 * 6) + 150`) for the one-shot timer unless you prefer a different cadence.
- Confirm no need to debounce external enqueues while iterative compaction is running (assumed safe since events are queued after settlement only).
<!-- Change 8 moved to APPROVED_CHANGES.md -->
