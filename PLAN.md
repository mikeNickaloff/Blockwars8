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

# Change 1 - Pure QML Powerup Editor QuickFlux Action
## Status
- Pending
## Context
- Recent AGENTS.md updates reaffirm the requirement to drive new work through PLAN.md with tightly scoped implementation steps.
- The current powerup editor lives in `powerupeditordialog.cpp` with imperative widget code that conflicts with the QML-first direction and lacks QuickFlux integration.
- Designers requested a refreshed editor that keeps the existing powerup data schema but exposes each powerup in a dedicated card view navigated from a custom powerup list.

## Proposed Changes
- Prototype a `quickflux/PowerupEditorAction.qml` (or equivalent) action namespace that encapsulates create/edit/delete triggers plus a request to open an individual powerup card, ensuring the payload mirrors the existing slot data (`slot_grids`, `slot_targets`, etc.).
- Define a companion QuickFlux store (e.g., `quickflux/PowerupEditorStore.qml`) that adapts the legacy dialog data model into QML-friendly observables while persisting to the existing storage utilities in `powerupeditordialog.cpp` or their refactored equivalents.
- Implement a pure-QML powerup editor scene composed of high-level components (e.g., `PowerupEditorView.qml`, `PowerupCardView.qml`, `PowerupCatalogList.qml`) that leverage the store to render a selectable list of user-defined powerups and display one card at a time with full detail controls.
- Ensure card interactions (grid toggles, metadata fields, energy calculations) delegate to reusable helper objects or abstract QML types instead of inline handlers, aligning with the architectural guidance in AGENTS.md.
- Provide navigation and lifecycle hooks so QuickFlux actions drive dialog visibility, card selection, and persistence, keeping the data contract identical to the existing JSON structure for compatibility with other systems.
- Persist created/edited `PowerupData` entries into a `localPowerupData` LocalStorage table through the forthcoming `SQLDataStorage.qml`, encoding `assignments` and `data` JSON payloads via the helper's `toHex()`/`fromHex()` utilities and maintaining slot assignment arrays (`SinglePlayerSlot1`…`MultiplayerSlot4`).
- Update supporting documentation files (PLAN.md status changes, APPROVED_CHANGES.md entries, TODO.md tasks, WHEEL.md summaries) once the implementation proceeds beyond planning.

## Questions / Comments
- Should legacy C++ dialog utilities be fully retired once the QML flow ships, or kept temporarily for fallback/testing during migration?
