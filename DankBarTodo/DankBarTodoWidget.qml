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

    property string editingId: ""
    property string editTitleText: ""
    property string editNotesText: ""

    property string openMenuId: ""

    readonly property int statusIncomplete: 0
    readonly property int statusActive: 1
    readonly property int statusComplete: 2

    readonly property int barCountFontPx: Math.max(6, Math.round(barThickness * 0.238))
    readonly property int barCountPillHeight: Math.max(10, Math.round(barThickness * 0.315))

    popoutWidth: 380

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
            return Theme.primary;
        if (st === statusComplete)
            return Theme.surfaceVariantText;
        return Theme.surfaceText;
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
            status: (t.status + 1) % 3
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
            status: (t.status + 2) % 3
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
        cancelEdit();
        openMenuId = "";
        Qt.callLater(() => composeTitleField.forceActiveFocus());
    }

    function cancelCompose() {
        composing = false;
        composeTitleText = "";
        composeNotesText = "";
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
                status: statusIncomplete
            }]);
        composing = false;
        composeTitleText = "";
        composeNotesText = "";
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
            status: t.status
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
                    height: Math.min(320, Math.max(80, todoListColumn.implicitHeight))
                    contentWidth: width
                    contentHeight: todoListColumn.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    onMovementStarted: root.openMenuId = ""

                    Column {
                        id: todoListColumn
                        width: flick.width
                        spacing: Theme.spacingXS

                        Repeater {
                            model: root.filteredTodos

                            StyledRect {
                                width: parent.width
                                height: rowInner.implicitHeight + Theme.spacingM * 2
                                radius: Theme.cornerRadius
                                color: Theme.surfaceContainerHigh

                                required property var modelData

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
                                        visible: root.editingId !== modelData.id

                                        MouseArea {
                                            width: statusTap.width
                                            height: statusTap.height
                                            cursorShape: Qt.PointingHandCursor
                                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                                            onClicked: mouse => {
                                                if (root.openMenuId === modelData.id) {
                                                    root.openMenuId = "";
                                                    return;
                                                }
                                                if (mouse.button === Qt.RightButton)
                                                    root.cycleStatusBackward(modelData.id);
                                                else
                                                    root.cycleStatus(modelData.id);
                                            }

                                            DankIcon {
                                                id: statusTap
                                                name: root.statusIcon(modelData.status)
                                                size: Theme.iconSize
                                                color: root.statusColor(modelData.status)
                                            }
                                        }

                                        Item {
                                            width: parent.width - statusTap.width - menuStrip.width - Theme.spacingS * 2
                                            implicitHeight: titleNotesCol.implicitHeight

                                            Column {
                                                id: titleNotesCol
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                anchors.top: parent.top
                                                spacing: Theme.spacingXS

                                                StyledText {
                                                    width: parent.width
                                                    text: modelData.title || ""
                                                    font.pixelSize: Theme.fontSizeMedium
                                                    font.weight: Font.Medium
                                                    color: Theme.surfaceText
                                                    wrapMode: Text.WordWrap
                                                    maximumLineCount: 4
                                                }

                                                StyledText {
                                                    width: parent.width
                                                    visible: (modelData.notes || "").length > 0
                                                    text: modelData.notes || ""
                                                    font.pixelSize: Theme.fontSizeSmall
                                                    color: Theme.surfaceVariantText
                                                    wrapMode: Text.WordWrap
                                                    maximumLineCount: 6
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                z: 10
                                                visible: root.openMenuId === modelData.id
                                                hoverEnabled: true
                                                cursorShape: Qt.ArrowCursor
                                                onClicked: root.openMenuId = ""
                                            }
                                        }

                                        Item {
                                            id: menuStrip
                                            width: root.openMenuId === modelData.id ? (40 + Theme.spacingXS + 40) : 36
                                            height: 36

                                            MouseArea {
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 36
                                                height: 36
                                                visible: root.openMenuId !== modelData.id
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    root.openMenuId = root.openMenuId === modelData.id ? "" : modelData.id;
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
                                                visible: root.openMenuId === modelData.id

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
                                                        onClicked: root.startEdit(modelData.id)
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
                                                        onClicked: root.deleteTodo(modelData.id)
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Column {
                                        id: editBlock
                                        width: parent.width
                                        spacing: Theme.spacingS
                                        visible: root.editingId === modelData.id

                                        DankTextField {
                                            id: editTitleField
                                            width: parent.width
                                            placeholderText: "Title"
                                            text: root.editTitleText
                                            maximumLength: 240
                                            onTextChanged: {
                                                if (root.editingId === modelData.id)
                                                    root.editTitleText = text;
                                            }
                                            onAccepted: root.commitEdit()
                                        }

                                        DankTextField {
                                            width: parent.width
                                            placeholderText: "Notes (optional)"
                                            text: root.editNotesText
                                            maximumLength: 2000
                                            onTextChanged: {
                                                if (root.editingId === modelData.id)
                                                    root.editNotesText = text;
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
                                    visible: root.openMenuId !== "" && root.openMenuId !== modelData.id
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
                        color: Theme.surfaceContainerHigh

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
                                maximumLength: 240
                                onTextChanged: root.composeTitleText = text
                                onAccepted: root.commitCompose()
                            }

                            DankTextField {
                                width: parent.width
                                visible: root.composing
                                placeholderText: "Notes (optional)"
                                text: root.composeNotesText
                                maximumLength: 2000
                                onTextChanged: root.composeNotesText = text
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
