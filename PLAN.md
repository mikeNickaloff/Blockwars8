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
