import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import "../../quickflux" 1.0 as Editor

Pane {
    id: editorView

    visible: storeFacade.store ? storeFacade.store.isEditorVisible : true
    padding: 24
    implicitWidth: 960
    implicitHeight: 540

    readonly property QtObject storeFacade: QtObject {
        id: facade
        property var store: Editor.PowerupEditorStore
        property var actions: Editor.PowerupEditorAction

        readonly property QtObject keyset: QtObject {
            readonly property var canonical: [
                "slot_targets",
                "slot_types",
                "slot_colors",
                "slot_amounts",
                "slot_energy",
                "slot_grids"
            ]
            readonly property var textual: ["slot_targets", "slot_types", "slot_colors"]
            readonly property var numeric: ["slot_amounts", "slot_energy"]
        }

        readonly property QtObject extractor: QtObject {
            function arrays() {
                return facade.store.slotArrays || ({})
            }

            function names() {
                return facade.store.slotNames || []
            }

            function assignments() {
                return facade.store.slotAssignments || []
            }

            function records() {
                return facade.store.slotRecords || ({})
            }

            function order() {
                var candidate = facade.store.slotOrder || []
                if (candidate.length > 0) {
                    return candidate
                }
                var result = []
                var map = records()
                for (var key in map) {
                    if (!map.hasOwnProperty(key)) {
                        continue
                    }
                    var numeric = parseInt(key, 10)
                    if (!isNaN(numeric)) {
                        result.push(numeric)
                    }
                }
                result.sort(function (a, b) { return a - b })
                return result
            }

            function activeSlotId() {
                return facade.store.activeSlotId
            }

            function arrayFor(key) {
                var collection = arrays()[key]
                return Array.isArray(collection) ? collection : []
            }

            function valueFor(key, slotId) {
                var collection = arrayFor(key)
                if (slotId < 0 || slotId >= collection.length) {
                    return null
                }
                return collection[slotId]
            }

            function numericFor(key, slotId) {
                var raw = valueFor(key, slotId)
                if (typeof raw === "number") {
                    return raw
                }
                if (raw === null || raw === undefined) {
                    return 0
                }
                var parsed = parseInt(raw, 10)
                return isNaN(parsed) ? 0 : parsed
            }

            function textFor(key, slotId) {
                var raw = valueFor(key, slotId)
                if (raw === null || raw === undefined) {
                    return ""
                }
                var text = "" + raw
                return text.trim()
            }

            function gridFor(slotId) {
                var raw = valueFor("slot_grids", slotId)
                if (!raw) {
                    return {}
                }
                if (Array.isArray(raw)) {
                    var gridFromArray = {}
                    for (var i = 0; i < raw.length; ++i) {
                        var entry = raw[i]
                        gridFromArray[entry] = true
                    }
                    return gridFromArray
                }
                if (typeof raw === "object") {
                    var normalized = {}
                    for (var key in raw) {
                        if (!raw.hasOwnProperty(key)) {
                            continue
                        }
                        normalized[key] = !!raw[key]
                    }
                    return normalized
                }
                return {}
            }

            function assignmentList(slotId) {
                var list = assignments()
                if (slotId < 0 || slotId >= list.length) {
                    return []
                }
                var entries = list[slotId] || []
                var normalized = []
                for (var i = 0; i < entries.length; ++i) {
                    var value = entries[i]
                    if (value === undefined || value === null) {
                        continue
                    }
                    normalized.push(("" + value).trim())
                }
                return normalized
            }

            function record(slotId) {
                var map = records()
                if (map.hasOwnProperty(slotId)) {
                    return map[slotId]
                }
                var textKey = "" + slotId
                if (map.hasOwnProperty(textKey)) {
                    return map[textKey]
                }
                return null
            }

            function displayName(slotId) {
                var namesList = names()
                if (slotId >= 0 && slotId < namesList.length) {
                    var provided = namesList[slotId]
                    if (provided !== undefined && provided !== null) {
                        var trimmed = ("" + provided).trim()
                        if (trimmed.length > 0) {
                            return trimmed
                        }
                    }
                }
                return qsTr("Powerup Slot %1").arg(slotId + 1)
            }
        }

        property var slotOrder: store.slotOrder || []
        property var slotNames: store.slotNames || []
        property var slotAssignments: store.slotAssignments || []
        property var slotArrays: store.slotArrays || ({})
        property var slotRecords: store.slotRecords || ({})
        property int activeSlotId: store.activeSlotId

        function openSlot(slotId, metadata) {
            actions.openCard(slotId, metadata || { origin: "catalog" })
        }
    }

    readonly property QtObject catalogCoordinator: QtObject {
        id: catalog
        property QtObject bridge: storeFacade
        property int activeSlotId: bridge.activeSlotId

        function entries() {
            var order = bridge.extractor.order()
            var results = []
            for (var i = 0; i < order.length; ++i) {
                var slotId = order[i]
                results.push({
                    slotId: slotId,
                    slotName: bridge.extractor.displayName(slotId),
                    assignmentCount: bridge.extractor.assignmentList(slotId).length
                })
            }
            return results
        }

        function openSlot(slotId) {
            bridge.openSlot(slotId, { origin: "catalog" })
        }
    }

    readonly property QtObject cardCoordinator: QtObject {
        id: card
        property QtObject bridge: storeFacade

        function snapshot(slotId) {
            var resolved = slotId
            if (resolved === undefined || resolved === null || resolved < 0) {
                resolved = bridge.extractor.activeSlotId()
            }
            if (resolved === undefined || resolved === null || resolved < 0) {
                return null
            }
            var assignments = bridge.extractor.assignmentList(resolved)
            var metadata = bridge.extractor.record(resolved)
            var metaPayload = metadata && metadata.data ? metadata.data : {}
            var gridMap = bridge.extractor.gridFor(resolved)
            var gridCount = 0
            for (var key in gridMap) {
                if (!gridMap.hasOwnProperty(key)) {
                    continue
                }
                if (gridMap[key]) {
                    gridCount++
                }
            }
            return {
                slotId: resolved,
                name: bridge.extractor.displayName(resolved),
                target: bridge.extractor.textFor("slot_targets", resolved),
                type: bridge.extractor.textFor("slot_types", resolved),
                color: bridge.extractor.textFor("slot_colors", resolved),
                amount: bridge.extractor.numericFor("slot_amounts", resolved),
                energy: bridge.extractor.numericFor("slot_energy", resolved),
                assignments: assignments,
                gridSelectionCount: gridCount,
                metadata: metaPayload
            }
        }

        function fallbackText() {
            return qsTr("Select a powerup slot to review its configuration.")
        }
    }

    background: Rectangle {
        radius: 20
        color: "#101522"
        border.color: "#1f2738"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 24

        Label {
            Layout.fillWidth: true
            text: qsTr("Powerup Editor")
            font.pixelSize: 28
            font.bold: true
            color: "#f4f6fb"
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 24

            PowerupCatalogList {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                provider: catalogCoordinator
                selectionProvider: storeFacade
            }

            PowerupCardView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                behavior: cardCoordinator
                slotId: storeFacade.activeSlotId
            }
        }
    }
}
