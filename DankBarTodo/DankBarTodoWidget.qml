import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    layerNamespacePlugin: "dankBarTodo"

    property var todos: []
    property var filteredTodos: []
    property bool showCompleted: false

    property bool composing: false
    property string composeTitleText: ""
    property string composeNotesText: ""
    property string composeTint: ""
    property bool composeUrgent: false

    property string editingId: ""
    property string editTitleText: ""
    property string editNotesText: ""

    property string openMenuId: ""

    property bool listExpanded: false
    property int reorderActiveIndex: -1
    property int reorderHoverIndex: -1

    readonly property int statusIncomplete: 0
    readonly property int statusActive: 1
    readonly property int statusComplete: 2

    readonly property int barCountFontPx: Math.max(6, Math.round(barThickness * 0.238))
    readonly property int barCountPillHeight: Math.max(10, Math.round(barThickness * 0.315))

    readonly property real listViewportExpandedCap: {
        const s = parentScreen;
        if (!s || !s.height)
            return 560;
        return Math.max(200, s.height - 260);
    }

    readonly property var todoTintPalette: ["#EF9A9A", "#F48FB1", "#CE93D8", "#B39DDB", "#9FA8DA", "#90CAF9", "#80DEEA", "#A5D6A7", "#E6EE9C", "#FFCC80"]

    Component {
        id: tintUrgentStripComponent

        Item {
            id: strip
            width: parent.width

            property bool composeMode: false
            property string todoId: ""
            property int urgentInt: 0
            property bool swatchDoubleClickExits: false

            readonly property real gap: Theme.spacingXS
            readonly property int stripCount: root.todoTintPalette.length + 2
            readonly property real cellW: stripCount > 0 && width > 0 ? (width - gap * (stripCount - 1)) / stripCount : 0
            readonly property real cellH: Math.max(22, cellW * 0.85)
            height: cellH
            clip: false

            readonly property bool urgentOn: composeMode ? root.composeUrgent : (urgentInt === 1)

            Repeater {
                model: root.todoTintPalette

                delegate: Rectangle {
                    required property string modelData
                    required property int index

                    x: index * (strip.cellW + strip.gap)
                    y: 0
                    width: strip.cellW
                    height: strip.cellH
                    radius: height / 2
                    color: modelData
                    border.width: 1
                    border.color: Theme.withAlpha(Theme.surfaceText, 0.35)

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (strip.composeMode)
                                root.composeTint = modelData;
                            else
                                root.setTodoTint(strip.todoId, modelData);
                        }
                        onDoubleClicked: {
                            if (!strip.swatchDoubleClickExits)
                                return;
                            if (strip.composeMode)
                                root.cancelCompose();
                            else
                                root.cancelEdit();
                        }
                    }
                }
            }

            Rectangle {
                x: root.todoTintPalette.length * (strip.cellW + strip.gap)
                y: 0
                width: strip.cellW
                height: strip.cellH
                radius: height / 2
                color: Theme.surfaceContainer
                border.width: 1
                border.color: Theme.withAlpha(Theme.surfaceText, 0.45)

                Rectangle {
                    anchors.centerIn: parent
                    width: Math.round(parent.width * 0.55)
                    height: 2
                    rotation: 45
                    color: Theme.surfaceVariantText
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (strip.composeMode)
                            root.composeTint = "";
                        else
                            root.setTodoTint(strip.todoId, "");
                    }
                    onDoubleClicked: {
                        if (!strip.swatchDoubleClickExits)
                            return;
                        if (strip.composeMode)
                            root.cancelCompose();
                        else
                            root.cancelEdit();
                    }
                }
            }

            Rectangle {
                x: (root.todoTintPalette.length + 1) * (strip.cellW + strip.gap)
                y: 0
                width: strip.cellW
                height: strip.cellH
                radius: height / 2
                color: strip.urgentOn ? Theme.withAlpha(Theme.error, 0.28) : Theme.surfaceContainer
                border.width: strip.urgentOn ? 2 : 1
                border.color: Theme.error

                DankIcon {
                    anchors.centerIn: parent
                    name: "priority_high"
                    size: Theme.iconSizeSmall
                    color: Theme.error
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (strip.composeMode)
                            root.composeUrgent = !root.composeUrgent;
                        else
                            root.setTodoUrgent(strip.todoId, strip.urgentInt !== 1);
                    }
                }
            }
        }
    }

    popoutWidth: 380

    ListModel {
        id: filteredLm
    }

    function focusComposeTitleField() {
        if (!root.composing)
            return;
        if (composeTitleField && composeTitleField.visible)
            composeTitleField.forceActiveFocus();
    }

    Timer {
        id: composeTitleFocusTimer
        interval: 50
        repeat: false
        onTriggered: root.focusComposeTitleField()
    }

    Timer {
        id: composeTitleFocusTimer2
        interval: 200
        repeat: false
        onTriggered: root.focusComposeTitleField()
    }

    Connections {
        target: root
        function onComposingChanged() {
            if (root.composing) {
                composeTitleFocusTimer.restart();
                composeTitleFocusTimer2.restart();
            }
        }
    }

    onPluginServiceChanged: {
        if (pluginService)
            Qt.callLater(loadAll);
    }

    Component.onCompleted: {
        if (pluginService)
            Qt.callLater(loadAll);
    }

    function loadAll() {
        if (!pluginService)
            return;
        const list = pluginService.loadPluginState("dankBarTodo", "todos");
        todos = Array.isArray(list) ? list : [];
        const sc = pluginService.loadPluginState("dankBarTodo", "showCompleted");
        showCompleted = sc === true;
        syncFiltered();
    }

    function saveTodos() {
        if (pluginService)
            pluginService.savePluginState("dankBarTodo", "todos", todos);
    }

    function saveShowCompletedPref() {
        if (pluginService)
            pluginService.savePluginState("dankBarTodo", "showCompleted", showCompleted);
    }

    function syncFiltered() {
        const out = [];
        for (let i = 0; i < todos.length; i++) {
            const t = todos[i];
            if (!t || typeof t.id !== "string")
                continue;
            if (showCompleted || t.status !== statusComplete)
                out.push(t);
        }
        filteredTodos = out;
        Qt.callLater(rebuildFilteredLm);
    }

    function findFilteredTodosIndicesInFull() {
        const idxs = [];
        for (let i = 0; i < todos.length; i++) {
            const t = todos[i];
            if (!showCompleted && t.status === statusComplete)
                continue;
            idxs.push(i);
        }
        return idxs;
    }

    function rebuildFilteredLm() {
        if (reorderActiveIndex >= 0 || !filteredLm)
            return;
        while (filteredLm.count > 0)
            filteredLm.remove(0);
        for (let i = 0; i < filteredTodos.length; i++) {
            const t = filteredTodos[i];
            filteredLm.append({
                todoId: t.id,
                todoTitle: t.title || "",
                todoNotes: t.notes || "",
                todoStatus: t.status || 0,
                todoTint: typeof t.tint === "string" ? t.tint : "",
                todoUrgent: t.urgent === true ? 1 : 0
            });
        }
    }

    function applyFilteredLmToTodos() {
        const idxs = findFilteredTodosIndicesInFull();
        if (idxs.length !== filteredLm.count)
            return;
        const copy = todos.slice();
        for (let fi = 0; fi < filteredLm.count; fi++) {
            const it = filteredLm.get(fi);
            copy[idxs[fi]] = {
                id: it.todoId,
                title: it.todoTitle,
                notes: it.todoNotes,
                status: it.todoStatus,
                tint: typeof it.todoTint === "string" ? it.todoTint : "",
                urgent: it.todoUrgent === 1
            };
        }
        setTodosCopy(copy);
    }

    function moveFilteredLmItem(from, to) {
        if (from === to || from < 0 || to < 0 || from >= filteredLm.count || to >= filteredLm.count)
            return;
        const items = [];
        for (let i = 0; i < filteredLm.count; i++) {
            const g = filteredLm.get(i);
            items.push({
                todoId: g.todoId,
                todoTitle: g.todoTitle,
                todoNotes: g.todoNotes,
                todoStatus: g.todoStatus,
                todoTint: typeof g.todoTint === "string" ? g.todoTint : "",
                todoUrgent: g.todoUrgent === 1 ? 1 : 0
            });
        }
        const row = items.splice(from, 1)[0];
        items.splice(to, 0, row);
        while (filteredLm.count > 0)
            filteredLm.remove(0);
        for (let j = 0; j < items.length; j++) {
            const it = items[j];
            filteredLm.append({
                todoId: it.todoId,
                todoTitle: it.todoTitle,
                todoNotes: it.todoNotes,
                todoStatus: it.todoStatus,
                todoTint: it.todoTint || "",
                todoUrgent: it.todoUrgent === 1 ? 1 : 0
            });
        }
        applyFilteredLmToTodos();
    }

    function findIndexById(id) {
        for (let i = 0; i < todos.length; i++) {
            if (todos[i].id === id)
                return i;
        }
        return -1;
    }

    function setTodosCopy(next) {
        todos = next;
        saveTodos();
        syncFiltered();
        openMenuId = "";
    }

    function applyTodosPreserveMenu(next) {
        todos = next;
        saveTodos();
        syncFiltered();
    }

    function outstandingCount() {
        let n = 0;
        for (let i = 0; i < todos.length; i++) {
            if (todos[i].status !== statusComplete)
                n++;
        }
        return n;
    }

    function statusIcon(st) {
        if (st === statusActive)
            return "play_circle";
        if (st === statusComplete)
            return "check_circle";
        return "radio_button_unchecked";
    }

    function statusColor(st) {
        if (st === statusActive)
            return Theme.info;
        if (st === statusComplete)
            return Theme.success;
        return Theme.surfaceText;
    }

    function todoRowCardColor(tintHex, status) {
        const base = Theme.surfaceContainerHigh;
        let fill = base;
        if (tintHex && typeof tintHex === "string" && tintHex.trim().length > 0) {
            const c = Qt.color(tintHex.trim());
            const k = 0.42;
            fill = Qt.rgba(
                base.r * (1 - k) + c.r * k,
                base.g * (1 - k) + c.g * k,
                base.b * (1 - k) + c.b * k,
                1
            );
        }
        if (status === statusComplete) {
            const s = Theme.surface;
            const d = 0.50;
            return Qt.rgba(
                fill.r * (1 - d) + s.r * d,
                fill.g * (1 - d) + s.g * d,
                fill.b * (1 - d) + s.b * d,
                1
            );
        }
        return fill;
    }

    function setTodoTint(id, hex) {
        const idx = findIndexById(id);
        if (idx < 0)
            return;
        const copy = todos.slice();
        const t = copy[idx];
        copy[idx] = {
            id: t.id,
            title: t.title,
            notes: t.notes || "",
            status: t.status || 0,
            tint: hex && typeof hex === "string" && hex.length > 0 ? hex : "",
            urgent: t.urgent === true
        };
        applyTodosPreserveMenu(copy);
    }

    function setTodoUrgent(id, urgent) {
        const idx = findIndexById(id);
        if (idx < 0)
            return;
        const copy = todos.slice();
        const t = copy[idx];
        copy[idx] = {
            id: t.id,
            title: t.title,
            notes: t.notes || "",
            status: t.status || 0,
            tint: typeof t.tint === "string" ? t.tint : "",
            urgent: urgent === true
        };
        applyTodosPreserveMenu(copy);
    }

    function cycleStatus(id) {
        const idx = findIndexById(id);
        if (idx < 0)
            return;
        const copy = todos.slice();
        const t = copy[idx];
        copy[idx] = {
            id: t.id,
            title: t.title,
            notes: t.notes || "",
            status: (t.status + 1) % 3,
            tint: typeof t.tint === "string" ? t.tint : "",
            urgent: t.urgent === true
        };
        setTodosCopy(copy);
    }

    function cycleStatusBackward(id) {
        const idx = findIndexById(id);
        if (idx < 0)
            return;
        const copy = todos.slice();
        const t = copy[idx];
        copy[idx] = {
            id: t.id,
            title: t.title,
            notes: t.notes || "",
            status: (t.status + 2) % 3,
            tint: typeof t.tint === "string" ? t.tint : "",
            urgent: t.urgent === true
        };
        setTodosCopy(copy);
    }

    function deleteTodo(id) {
        const idx = findIndexById(id);
        if (idx < 0)
            return;
        const copy = todos.slice();
        copy.splice(idx, 1);
        if (editingId === id)
            cancelEdit();
        setTodosCopy(copy);
    }

    function startCompose() {
        composing = true;
        composeTitleText = "";
        composeNotesText = "";
        composeTint = "";
        composeUrgent = false;
        cancelEdit();
        openMenuId = "";
        composeTitleFocusTimer.restart();
        composeTitleFocusTimer2.restart();
        Qt.callLater(() => root.focusComposeTitleField());
    }

    function cancelCompose() {
        composing = false;
        composeTitleText = "";
        composeNotesText = "";
        composeTint = "";
        composeUrgent = false;
        openMenuId = "";
    }

    function commitCompose() {
        const title = composeTitleText.trim();
        if (!title.length)
            return;
        const id = "t" + Date.now() + "_" + Math.floor(Math.random() * 1e6);
        const next = todos.concat([{
                id: id,
                title: title,
                notes: composeNotesText.trim(),
                status: statusIncomplete,
                tint: typeof composeTint === "string" && composeTint.length > 0 ? composeTint : "",
                urgent: composeUrgent === true
            }]);
        composing = false;
        composeTitleText = "";
        composeNotesText = "";
        composeTint = "";
        composeUrgent = false;
        setTodosCopy(next);
    }

    function startEdit(id) {
        const idx = findIndexById(id);
        if (idx < 0)
            return;
        const t = todos[idx];
        editingId = id;
        editTitleText = t.title || "";
        editNotesText = t.notes || "";
        composing = false;
        openMenuId = "";
    }

    function cancelEdit() {
        editingId = "";
        editTitleText = "";
        editNotesText = "";
        openMenuId = "";
    }

    function commitEdit() {
        const title = editTitleText.trim();
        if (!editingId.length || !title.length)
            return;
        const idx = findIndexById(editingId);
        if (idx < 0)
            return;
        const copy = todos.slice();
        const t = copy[idx];
        copy[idx] = {
            id: t.id,
            title: title,
            notes: editNotesText.trim(),
            status: t.status,
            tint: typeof t.tint === "string" ? t.tint : "",
            urgent: t.urgent === true
        };
        cancelEdit();
        setTodosCopy(copy);
    }

    onTodosChanged: Qt.callLater(syncFiltered)
    onShowCompletedChanged: {
        saveShowCompletedPref();
        Qt.callLater(syncFiltered);
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: "checklist"
                size: Theme.iconSize - 6
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                visible: root.outstandingCount() > 0
                width: hCountLabel.width + Math.max(6, Math.round(root.barCountPillHeight * 0.45))
                height: root.barCountPillHeight
                radius: height / 2
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    id: hCountLabel
                    anchors.centerIn: parent
                    text: String(Math.min(99, root.outstandingCount()))
                    font.pixelSize: root.barCountFontPx
                    font.weight: Font.Bold
                    color: Theme.surface
                }
            }
        }
    }

    verticalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: "checklist"
                size: Theme.iconSize - 6
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                visible: root.outstandingCount() > 0
                width: vCountLabel.width + Math.max(6, Math.round(root.barCountPillHeight * 0.45))
                height: root.barCountPillHeight
                radius: height / 2
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    id: vCountLabel
                    anchors.centerIn: parent
                    text: String(Math.min(99, root.outstandingCount()))
                    font.pixelSize: root.barCountFontPx
                    font.weight: Font.Bold
                    color: Theme.surface
                }
            }
        }
    }

    popoutContent: Component {
        Item {
            id: popoutRoot
            width: parent.width
            implicitHeight: pc.implicitHeight

            property var closePopout: null
            property var parentPopout: null

            Connections {
                target: popoutRoot.parentPopout
                enabled: popoutRoot.parentPopout !== null && popoutRoot.parentPopout !== undefined
                function onShouldBeVisibleChanged() {
                    if (!popoutRoot.parentPopout || popoutRoot.parentPopout.shouldBeVisible)
                        return;
                    root.cancelCompose();
                    root.cancelEdit();
                    root.openMenuId = "";
                }
            }

            PopoutComponent {
                id: pc
                width: parent.width
                headerText: "Todos"
                showCloseButton: true
                closePopout: popoutRoot.closePopout

                headerActions: Component {
                    Row {
                        spacing: Theme.spacingXS

                        StyledRect {
                            width: 36
                            height: 36
                            radius: Theme.cornerRadius
                            color: expandHit.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainer

                            DankIcon {
                                anchors.centerIn: parent
                                name: root.listExpanded ? "fullscreen_exit" : "open_in_full"
                                size: Theme.iconSize - 4
                                color: Theme.surfaceText
                            }

                            MouseArea {
                                id: expandHit
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.listExpanded = !root.listExpanded
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: toggleRow.implicitHeight + Theme.spacingS

                    Row {
                        id: toggleRow
                        z: 1
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: Theme.spacingM

                        StyledText {
                            text: "Show completed"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - completedToggle.width - parent.spacing
                            elide: Text.ElideRight
                        }

                        DankToggle {
                            id: completedToggle
                            anchors.verticalCenter: parent.verticalCenter
                            hideText: true
                            checked: root.showCompleted
                            onToggled: c => {
                                root.showCompleted = c;
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        z: 2
                        visible: root.openMenuId !== ""
                        hoverEnabled: true
                        cursorShape: Qt.ArrowCursor
                        onClicked: root.openMenuId = ""
                    }
                }

                Flickable {
                    id: flick
                    width: parent.width
                    readonly property real todoColH: Math.max(80, todoListColumn.implicitHeight)
                    height: root.listExpanded ? Math.min(todoColH, root.listViewportExpandedCap) : Math.min(320, todoColH)
                    contentWidth: width
                    contentHeight: todoListColumn.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: root.reorderActiveIndex < 0 && contentHeight > height
                    onMovementStarted: root.openMenuId = ""

                    Column {
                        id: todoListColumn
                        width: flick.width
                        spacing: Theme.spacingXS

                        ListView {
                            id: todoListView
                            width: parent.width
                            height: contentHeight
                            spacing: Theme.spacingXS
                            model: filteredLm
                            interactive: false

                            delegate: StyledRect {
                                width: todoListView.width
                                implicitHeight: rowInner.implicitHeight + Theme.spacingM * 2
                                height: implicitHeight
                                radius: Theme.cornerRadius
                                color: root.todoRowCardColor(todoTint, todoStatus)
                                border.width: todoUrgent === 1 ? 2 : (root.reorderActiveIndex >= 0 && index === root.reorderHoverIndex ? 2 : 0)
                                border.color: todoUrgent === 1 ? Theme.error : Theme.primary

                                required property int index
                                required property string todoId
                                required property string todoTitle
                                required property string todoNotes
                                required property int todoStatus
                                required property string todoTint
                                required property int todoUrgent

                                Column {
                                    id: rowInner
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: Theme.spacingM
                                    spacing: Theme.spacingS

                                    Row {
                                        id: viewRow
                                        width: parent.width
                                        spacing: Theme.spacingS
                                        visible: root.editingId !== todoId
                                        readonly property real rowBodyH: Math.max(36, titleNotesCol.implicitHeight)

                                        MouseArea {
                                            id: dragHandle
                                            width: 28
                                            height: viewRow.rowBodyH
                                            cursorShape: Qt.SizeVerCursor
                                            hoverEnabled: true
                                            onPressed: {
                                                root.reorderActiveIndex = index;
                                                root.reorderHoverIndex = index;
                                            }
                                            onPositionChanged: mouse => {
                                                if (!dragHandle.pressed)
                                                    return;
                                                const pt = mapToItem(todoListView, mouse.x, mouse.y);
                                                const hi = todoListView.indexAt(todoListView.width * 0.5, pt.y);
                                                if (hi >= 0 && hi !== root.reorderHoverIndex)
                                                    root.reorderHoverIndex = hi;
                                            }
                                            onReleased: {
                                                if (root.reorderActiveIndex >= 0 && root.reorderHoverIndex >= 0)
                                                    root.moveFilteredLmItem(root.reorderActiveIndex, root.reorderHoverIndex);
                                                root.reorderActiveIndex = -1;
                                                root.reorderHoverIndex = -1;
                                            }
                                            onCanceled: {
                                                root.reorderActiveIndex = -1;
                                                root.reorderHoverIndex = -1;
                                            }

                                            DankIcon {
                                                anchors.centerIn: parent
                                                name: "drag_indicator"
                                                size: Theme.iconSize - 4
                                                color: Theme.surfaceVariantText
                                            }
                                        }

                                        Item {
                                            id: statusColumn
                                            width: Theme.iconSize + 4
                                            height: viewRow.rowBodyH

                                            MouseArea {
                                                id: statusHit
                                                anchors.centerIn: parent
                                                width: statusTap.width
                                                height: statusTap.height
                                                cursorShape: Qt.PointingHandCursor
                                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                                onClicked: mouse => {
                                                    if (root.openMenuId === todoId) {
                                                        root.openMenuId = "";
                                                        return;
                                                    }
                                                    if (mouse.button === Qt.RightButton)
                                                        root.cycleStatusBackward(todoId);
                                                    else
                                                        root.cycleStatus(todoId);
                                                }

                                                DankIcon {
                                                    id: statusTap
                                                    name: root.statusIcon(todoStatus)
                                                    size: Theme.iconSize
                                                    color: root.statusColor(todoStatus)
                                                }
                                            }
                                        }

                                        Item {
                                            id: middleCol
                                            width: parent.width - dragHandle.width - statusColumn.width - menuStrip.width - Theme.spacingS * 3
                                            implicitHeight: titleNotesCol.implicitHeight

                                            Column {
                                                id: titleNotesCol
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                anchors.top: parent.top
                                                spacing: Theme.spacingXS

                                                StyledText {
                                                    width: parent.width
                                                    text: todoTitle || ""
                                                    font.pixelSize: Theme.fontSizeMedium
                                                    font.weight: Font.Medium
                                                    color: Theme.surfaceText
                                                    wrapMode: Text.WordWrap
                                                    maximumLineCount: 4
                                                }

                                                StyledText {
                                                    width: parent.width
                                                    visible: (todoNotes || "").length > 0
                                                    text: todoNotes || ""
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    color: Theme.surfaceVariantText
                                                    wrapMode: Text.WordWrap
                                                    maximumLineCount: 6
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                z: 10
                                                visible: root.openMenuId === todoId
                                                hoverEnabled: true
                                                cursorShape: Qt.ArrowCursor
                                                onClicked: root.openMenuId = ""
                                            }
                                        }

                                        Item {
                                            id: menuStrip
                                            width: root.openMenuId === todoId ? (40 + Theme.spacingXS + 40) : 36
                                            height: viewRow.rowBodyH

                                            MouseArea {
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 36
                                                height: 36
                                                visible: root.openMenuId !== todoId
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    root.openMenuId = root.openMenuId === todoId ? "" : todoId;
                                                }

                                                DankIcon {
                                                    anchors.centerIn: parent
                                                    name: "more_vert"
                                                    size: Theme.iconSize - 4
                                                    color: Theme.surfaceVariantText
                                                }
                                            }

                                            Row {
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: Theme.spacingXS
                                                visible: root.openMenuId === todoId

                                                StyledRect {
                                                    width: 40
                                                    height: 36
                                                    radius: Theme.cornerRadius
                                                    color: Theme.buttonBg

                                                    Rectangle {
                                                        anchors.fill: parent
                                                        radius: parent.radius
                                                        color: {
                                                            if (editIconBtn.pressed)
                                                                return Theme.withAlpha(Theme.buttonText, 0.20);
                                                            if (editIconBtn.containsMouse)
                                                                return Theme.withAlpha(Theme.buttonText, 0.12);
                                                            return "transparent";
                                                        }
                                                    }

                                                    DankIcon {
                                                        anchors.centerIn: parent
                                                        name: "edit"
                                                        size: Theme.iconSizeSmall
                                                        color: Theme.buttonText
                                                    }

                                                    MouseArea {
                                                        id: editIconBtn
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: root.startEdit(todoId)
                                                    }
                                                }

                                                StyledRect {
                                                    width: 40
                                                    height: 36
                                                    radius: Theme.cornerRadius
                                                    color: Theme.error

                                                    Rectangle {
                                                        anchors.fill: parent
                                                        radius: parent.radius
                                                        color: {
                                                            if (delIconBtn.pressed)
                                                                return Theme.withAlpha(Theme.surface, 0.22);
                                                            if (delIconBtn.containsMouse)
                                                                return Theme.withAlpha(Theme.surface, 0.12);
                                                            return "transparent";
                                                        }
                                                    }

                                                    DankIcon {
                                                        anchors.centerIn: parent
                                                        name: "delete"
                                                        size: Theme.iconSizeSmall
                                                        color: Theme.surface
                                                    }

                                                    MouseArea {
                                                        id: delIconBtn
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: root.deleteTodo(todoId)
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Loader {
                                        id: menuTintStripLoader
                                        width: parent.width
                                        active: root.openMenuId === todoId
                                        visible: active
                                        height: item ? item.height : 0
                                        sourceComponent: tintUrgentStripComponent

                                        onLoaded: {
                                            item.composeMode = false;
                                            item.swatchDoubleClickExits = false;
                                            item.todoId = Qt.binding(function () {
                                                return todoId;
                                            });
                                            item.urgentInt = Qt.binding(function () {
                                                return todoUrgent;
                                            });
                                        }
                                    }

                                    Column {
                                        id: editBlock
                                        width: parent.width
                                        spacing: Theme.spacingXS
                                        visible: root.editingId === todoId

                                        DankTextField {
                                            id: editTitleField
                                            width: parent.width
                                            placeholderText: "Title"
                                            text: root.editTitleText
                                            onTextChanged: {
                                                if (root.editingId !== todoId)
                                                    return;
                                                if (text.length > 240)
                                                    root.editTitleText = text.substring(0, 240);
                                                else
                                                    root.editTitleText = text;
                                            }
                                            onAccepted: root.commitEdit()
                                        }

                                        DankTextField {
                                            width: parent.width
                                            placeholderText: "Notes (optional)"
                                            text: root.editNotesText
                                            onTextChanged: {
                                                if (root.editingId !== todoId)
                                                    return;
                                                if (text.length > 2000)
                                                    root.editNotesText = text.substring(0, 2000);
                                                else
                                                    root.editNotesText = text;
                                            }
                                        }

                                        Loader {
                                            id: editTintStripLoader
                                            width: parent.width
                                            active: root.editingId === todoId
                                            visible: active
                                            height: item ? item.height : 0
                                            sourceComponent: tintUrgentStripComponent

                                            onLoaded: {
                                                item.composeMode = false;
                                                item.swatchDoubleClickExits = true;
                                                item.todoId = Qt.binding(function () {
                                                    return todoId;
                                                });
                                                item.urgentInt = Qt.binding(function () {
                                                    return todoUrgent;
                                                });
                                            }
                                        }

                                        Row {
                                            id: editActionRow
                                            width: parent.width
                                            spacing: Theme.spacingM

                                            DankButton {
                                                width: (parent.width - parent.spacing) / 2
                                                text: "Save"
                                                iconName: "check"
                                                buttonHeight: 48
                                                horizontalPadding: Theme.spacingM
                                                backgroundColor: Theme.success
                                                textColor: Theme.surface
                                                onClicked: root.commitEdit()
                                            }

                                            DankButton {
                                                width: (parent.width - parent.spacing) / 2
                                                text: "Cancel"
                                                iconName: "close"
                                                buttonHeight: 48
                                                horizontalPadding: Theme.spacingM
                                                backgroundColor: Theme.error
                                                textColor: Theme.surface
                                                onClicked: root.cancelEdit()
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    z: 50
                                    visible: root.openMenuId !== "" && root.openMenuId !== todoId
                                    hoverEnabled: true
                                    cursorShape: Qt.ArrowCursor
                                    onClicked: root.openMenuId = ""
                                }
                            }
                        }

                        StyledText {
                            visible: root.filteredTodos.length === 0
                            width: parent.width
                            text: root.todos.length === 0 ? "No todos yet. Use Add todo below." : "No todos match this view."
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                            topPadding: Theme.spacingL
                            bottomPadding: Theme.spacingL
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: Theme.spacingL
                }

                StyledRect {
                        width: parent.width
                        height: bottomBlock.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: root.composing && root.composeTint.length > 0 ? root.todoRowCardColor(root.composeTint, root.statusIncomplete) : Theme.surfaceContainerHigh

                        Column {
                            id: bottomBlock
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingS

                            DankTextField {
                                id: composeTitleField
                                width: parent.width
                                visible: root.composing
                                placeholderText: "New todo title"
                                text: root.composeTitleText
                                onTextChanged: {
                                    if (text.length > 240)
                                        root.composeTitleText = text.substring(0, 240);
                                    else
                                        root.composeTitleText = text;
                                }
                                onAccepted: root.commitCompose()
                                onVisibleChanged: {
                                    if (visible) {
                                        composeTitleFocusTimer.restart();
                                        composeTitleFocusTimer2.restart();
                                    }
                                }
                            }

                            DankTextField {
                                width: parent.width
                                visible: root.composing
                                placeholderText: "Notes (optional)"
                                text: root.composeNotesText
                                onTextChanged: {
                                    if (text.length > 2000)
                                        root.composeNotesText = text.substring(0, 2000);
                                    else
                                        root.composeNotesText = text;
                                }
                                onAccepted: root.commitCompose()
                            }

                            StyledText {
                                width: parent.width
                                visible: root.composing
                                text: "Colour & urgent"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }

                            Loader {
                                id: composeTintStripLoader
                                width: parent.width
                                active: root.composing
                                visible: active
                                height: item ? item.height : 0
                                sourceComponent: tintUrgentStripComponent

                                onLoaded: {
                                    item.composeMode = true;
                                    item.swatchDoubleClickExits = true;
                                }
                            }

                            Item {
                                width: parent.width
                                height: 48

                                DankButton {
                                    visible: !root.composing
                                    width: parent.width
                                    text: "Add todo"
                                    iconName: "add"
                                    buttonHeight: 48
                                    horizontalPadding: Theme.spacingM
                                    onClicked: root.startCompose()
                                }

                                Row {
                                    visible: root.composing
                                    width: parent.width
                                    height: 48
                                    spacing: Theme.spacingS

                                    DankButton {
                                        width: (parent.width - parent.spacing) / 2
                                        text: "Add"
                                        iconName: "check"
                                        buttonHeight: 48
                                        horizontalPadding: Theme.spacingM
                                        onClicked: root.commitCompose()
                                    }

                                    DankButton {
                                        width: (parent.width - parent.spacing) / 2
                                        text: "Cancel"
                                        iconName: "close"
                                        buttonHeight: 48
                                        horizontalPadding: Theme.spacingM
                                        onClicked: root.cancelCompose()
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            z: 100
                            visible: root.openMenuId !== ""
                            hoverEnabled: true
                            cursorShape: Qt.ArrowCursor
                            onClicked: root.openMenuId = ""
                        }
                }
            }
        }
    }
}
