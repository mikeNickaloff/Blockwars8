pragma Singleton

import QtQuick 2.15
import QuickFlux 1.1
import "../Blockwars8/actions" as Actions

ActionCreator {
    id: actionFacade

    readonly property QtObject structuralCloner: QtObject {
        function cloneValue(value) {
            if (value === null || value === undefined) {
                return value
            }
            if (Array.isArray(value)) {
                var clone = []
                for (var index = 0; index < value.length; ++index) {
                    clone[index] = cloneValue(value[index])
                }
                return clone
            }
            if (typeof value === "object") {
                var result = {}
                for (var key in value) {
                    if (value.hasOwnProperty(key)) {
                        result[key] = cloneValue(value[key])
                    }
                }
                return result
            }
            return value
        }
    }

    readonly property QtObject actionRegistry: QtObject {
        property string namespace: Actions.ActionTypes.powerupEditorNamespace
        property string create: Actions.ActionTypes.powerupEditorCreateSlot
        property string edit: Actions.ActionTypes.powerupEditorEditSlot
        property string remove: Actions.ActionTypes.powerupEditorDeleteSlot
        property string open: Actions.ActionTypes.powerupEditorOpenCard

        function lifecycleFrom(key) {
            var tokens = key.split(".")
            return tokens.length > 0 ? tokens[tokens.length - 1] : key
        }
    }

    readonly property QtObject directiveComposer: QtObject {
        function compose(actionKey, customMeta) {
            var directive = {
                namespace: actionRegistry.namespace,
                lifecycle: actionRegistry.lifecycleFrom(actionKey)
            }
            var extras = customMeta || {}
            for (var key in extras) {
                if (extras.hasOwnProperty(key) && extras[key] !== undefined) {
                    directive[key] = structuralCloner.cloneValue(extras[key])
                }
            }
            return directive
        }
    }

    readonly property QtObject payloadComposer: QtObject {
        property var canonicalSlotKeys: [
            "slot_grids",
            "slot_targets",
            "slot_types",
            "slot_amounts",
            "slot_colors",
            "slot_energy"
        ]

        function normalized(slotState) {
            var state = slotState || {}
            var normalizedState = {}
            for (var i = 0; i < canonicalSlotKeys.length; ++i) {
                var key = canonicalSlotKeys[i]
                if (state.hasOwnProperty(key)) {
                    normalizedState[key] = structuralCloner.cloneValue(state[key])
                } else {
                    normalizedState[key] = []
                }
            }
            if (state.hasOwnProperty("slot_assignments")) {
                normalizedState.slot_assignments = structuralCloner.cloneValue(state.slot_assignments)
            }
            if (state.hasOwnProperty("data")) {
                normalizedState.data = structuralCloner.cloneValue(state.data)
            }
            return normalizedState
        }

        function compose(slotId, slotState, metadata) {
            var directive = normalized(slotState)
            directive.slot_id = slotId
            var meta = metadata || {}
            for (var key in meta) {
                if (meta.hasOwnProperty(key) && meta[key] !== undefined) {
                    directive[key] = structuralCloner.cloneValue(meta[key])
                }
            }
            return directive
        }
    }

    readonly property QtObject dispatchRelay: QtObject {
        function emit(actionKey, payload) {
            AppDispatcher.dispatch(actionKey, payload)
        }
    }

    function createSlot(slotId, slotState, metadata) {
        dispatchRelay.emit(
                    actionRegistry.create,
                    payloadComposer.compose(
                        slotId,
                        slotState,
                        directiveComposer.compose(actionRegistry.create, metadata)))
    }

    function editSlot(slotId, slotState, metadata) {
        dispatchRelay.emit(
                    actionRegistry.edit,
                    payloadComposer.compose(
                        slotId,
                        slotState,
                        directiveComposer.compose(actionRegistry.edit, metadata)))
    }

    function deleteSlot(slotId, metadata) {
        dispatchRelay.emit(
                    actionRegistry.remove,
                    payloadComposer.compose(
                        slotId,
                        {},
                        directiveComposer.compose(actionRegistry.remove, metadata)))
    }

    function openCard(slotId, metadata) {
        dispatchRelay.emit(
                    actionRegistry.open,
                    payloadComposer.compose(
                        slotId,
                        {},
                        directiveComposer.compose(actionRegistry.open, metadata)))
    }
}
