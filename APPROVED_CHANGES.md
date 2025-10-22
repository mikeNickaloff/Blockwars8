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
