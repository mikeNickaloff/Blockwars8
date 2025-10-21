# Change 1 - Pure QML Powerup Editor QuickFlux Action
## Status
- Approved

## Context
- Recent AGENTS.md updates reaffirm the requirement to drive new work through PLAN.md with tightly scoped implementation steps.
- The current powerup editor lives in `powerupeditordialog.cpp` with imperative widget code that conflicts with the QML-first direction and lacks QuickFlux integration.
- Designers requested a refreshed editor that keeps the existing powerup data schema but exposes each powerup in a dedicated card view navigated from a custom powerup list.

## Implementation Steps
- Scaffold a `quickflux/PowerupEditorAction.qml` namespace that encapsulates create, edit, delete, and open-card dispatchers while mirroring the existing slot payload structure (`slot_grids`, `slot_targets`, and related arrays).
- Build a companion `quickflux/PowerupEditorStore.qml` to adapt the legacy dialog data into observable QML state, bridging to existing persistence helpers for loading and saving powerup metadata.
- Compose a pure-QML editor flow with high-level components such as `PowerupEditorView.qml`, `PowerupCardView.qml`, and `PowerupCatalogList.qml`, ensuring each card interaction delegates to abstract helper types instead of inline logic.
- Wire QuickFlux actions to drive dialog visibility, card selection, and persistence operations so the runtime data contract remains compatible with the current JSON structures consumed elsewhere.
- Persist created and edited entries to a `localPowerupData` LocalStorage table via the forthcoming `SQLDataStorage.qml`, encoding `assignments` and `data` payloads with shared `toHex()`/`fromHex()` utilities while maintaining slot assignment arrays (`SinglePlayerSlot1`…`MultiplayerSlot4`).
- Update supporting documentation (PLAN.md status changes, APPROVED_CHANGES.md status, TODO.md tasks, WHEEL.md summaries) as milestones are reached during implementation.

## Status History
- Approved (Change 1) — awaiting implementation kickoff.
