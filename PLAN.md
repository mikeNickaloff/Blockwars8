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
