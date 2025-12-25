import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool active: false
    property int padding: 8
    property string searchText: ""

    property bool showAddDialog: false

    property string newLabel: ""
    property string newIcon: "terminal"
    property string newCmd: ""
    property bool newTerminal: true

    property string errorText: ""

    readonly property string actionsDir: Directories.userActions

    function shellQuoted(str) {
        return `'${StringUtils.shellSingleQuoteEscape(str)}'`;
    }

    function openAddDialog() {
        root.newLabel = "";
        root.newIcon = "terminal";
        root.newCmd = "";
        root.newTerminal = true;
        root.errorText = "";
        root.showAddDialog = true;
    }

    function saveNewCommand() {
        const label = root.newLabel.trim();
        const cmd = root.newCmd.trim();
        const icon = root.newIcon.trim() || "terminal";

        if (label.length === 0) {
            root.errorText = Translation.tr("Label is required");
            return;
        }
        if (cmd.length === 0) {
            root.errorText = Translation.tr("Command is required");
            return;
        }

        const existing = (Config?.options?.developer?.commands?.commands ?? []).slice(0);
        existing.push({
            "label": label,
            "icon": icon,
            "cmd": cmd,
            "terminal": root.newTerminal
        });
        Config.setNestedValue("developer.commands.commands", existing);
        root.showAddDialog = false;
    }

    function deleteCommand(index) {
        const existing = (Config?.options?.developer?.commands?.commands ?? []).slice(0);
        if (index < 0 || index >= existing.length) return;
        existing.splice(index, 1);
        Config.setNestedValue("developer.commands.commands", existing);
    }

    function runCommand(entry, forceTerminal) {
        if (!entry) return;

        if (entry.type === "script") {
            Quickshell.execDetached([entry.path]);
            return;
        }

        const cmd = (entry.cmd ?? "").toString();
        const wantTerminal = forceTerminal || !!entry.terminal;

        if (wantTerminal) {
            const terminal = (Config?.options?.apps?.terminal ?? "").toString().trim();
            const escaped = shellQuoted(cmd);
            if (terminal.length === 0) {
                Quickshell.execDetached(["bash", "-lc", cmd]);
            } else {
                Quickshell.execDetached(["bash", "-c", `${terminal} -e bash -lc ${escaped}`]);
            }
            return;
        }

        if (runProc.running) {
            Quickshell.execDetached(["notify-send", Translation.tr("Command"), Translation.tr("Another command is still running"), "-a", "Shell"]);
            return;
        }

        runProc.exec(["bash", "-lc", cmd]);
        runProc.lastLabel = entry.label ?? "";
    }

    readonly property var configCommands: (Config?.options?.developer?.commands?.commands ?? []).map((cmd, idx) => {
        return {
            type: "command",
            index: idx,
            label: cmd.label ?? "",
            icon: cmd.icon ?? "terminal",
            cmd: cmd.cmd ?? "",
            terminal: cmd.terminal ?? true,
        };
    })

    // Scripts from ~/.config/illogical-impulse/actions
    FolderListModel {
        id: actionsFolder
        folder: Qt.resolvedUrl(root.actionsDir)
        showDirs: false
        showHidden: false
        sortField: FolderListModel.Name
    }

    readonly property var scriptCommands: {
        const scripts = [];
        for (let i = 0; i < actionsFolder.count; i++) {
            const fileName = actionsFolder.get(i, "fileName");
            const filePath = actionsFolder.get(i, "filePath");
            if (!fileName || !filePath) continue;
            const label = fileName.replace(/\.[^/.]+$/, "");
            scripts.push({
                type: "script",
                label,
                icon: "bolt",
                path: FileUtils.trimFileProtocol(filePath.toString()),
                cmd: label,
                terminal: false,
            });
        }
        return scripts;
    }

    readonly property var allEntries: configCommands.concat(scriptCommands)

    readonly property var filteredEntries: {
        const q = root.searchText.trim();
        if (q.length === 0) return allEntries;

        const prepared = allEntries.map(e => ({
            name: Fuzzy.prepare(`${e.label} ${e.cmd} ${e.type}`),
            obj: e
        }));
        const results = Fuzzy.go(q, prepared, { all: true, key: "name" });
        return results.map(r => r.obj);
    }

    Process {
        id: runProc
        property string lastLabel: ""
        stdout: StdioCollector { id: runCollector }
        onExited: (exitCode, exitStatus) => {
            const name = runProc.lastLabel || Translation.tr("Command");
            Quickshell.execDetached([
                "notify-send",
                name,
                Translation.tr("Exited with code %1").arg(exitCode),
                "-a",
                "Shell"
            ]);
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: root.padding
        }
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MaterialSymbol {
                text: "terminal"
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colOnSurfaceVariant
                fill: 0
            }

            ToolbarTextField {
                id: searchField
                Layout.fillWidth: true
                implicitHeight: 36
                placeholderText: Translation.tr("Search commands")
                text: root.searchText
                onTextChanged: root.searchText = text
            }

            ToolbarButton {
                Layout.fillHeight: false
                implicitWidth: 34
                implicitHeight: 34
                onClicked: openAddDialog()

                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "add"
                    iconSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnSurfaceVariant
                    fill: 0
                }

                StyledToolTip { text: Translation.tr("Add command") }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Appearance.rounding.small
            color: Appearance.colors.colLayer1

            StyledListView {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                visible: filteredEntries.length > 0

                model: ScriptModel {
                    values: filteredEntries
                }

                delegate: CommandRow {
                    required property var modelData
                    entry: modelData
                }
            }

            PagePlaceholder {
                shown: filteredEntries.length === 0
                icon: "terminal"
                title: Translation.tr("No commands")
                description: Translation.tr("Add commands or drop scripts into %1").arg(root.actionsDir)
                shape: MaterialShape.Shape.PixelCircle
            }
        }

        WindowDialog {
            id: addDialog
            anchors.fill: parent
            show: root.showAddDialog
            onDismiss: root.showAddDialog = false

            WindowDialogTitle { text: Translation.tr("Add command") }

            WindowDialogParagraph {
                text: Translation.tr("Create a quick command for this machine")
            }

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Label")
                text: root.newLabel
                onTextChanged: root.newLabel = text
            }

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Icon name (Material)")
                text: root.newIcon
                onTextChanged: root.newIcon = text
            }

            MaterialTextField {
                Layout.fillWidth: true
                placeholderText: Translation.tr("Command")
                text: root.newCmd
                onTextChanged: root.newCmd = text
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                MaterialSymbol {
                    text: "terminal"
                    iconSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnSurfaceVariant
                    fill: 0
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Translation.tr("Run in terminal")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colOnSurfaceVariant
                }

                StyledSwitch {
                    checked: root.newTerminal
                    onCheckedChanged: root.newTerminal = checked
                }
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.errorText.length > 0
                text: root.errorText
                color: Appearance.colors.colError
                wrapMode: Text.Wrap
            }

            WindowDialogButtonRow {
                Layout.fillWidth: true

                DialogButton {
                    buttonText: Translation.tr("Cancel")
                    onClicked: root.showAddDialog = false
                }

                DialogButton {
                    buttonText: Translation.tr("Save")
                    onClicked: saveNewCommand()
                }
            }
        }
    }

    component CommandRow: Rectangle {
        id: row
        required property var entry

        radius: Appearance.rounding.small
        color: Appearance.colors.colLayer2
        implicitHeight: content.implicitHeight + 10 * 2

        RowLayout {
            id: content
            anchors {
                fill: parent
                margins: 10
            }
            spacing: 8

            MaterialSymbol {
                text: row.entry.icon || (row.entry.type === "script" ? "bolt" : "terminal")
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colOnSurfaceVariant
                fill: 0
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: row.entry.label
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colOnSurfaceVariant
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: row.entry.type === "script" ? row.entry.path : row.entry.cmd
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.m3colors.m3outline
                    font.family: Appearance.font.family.monospace
                    elide: Text.ElideRight
                }
            }

            ActionButton {
                icon: "play_arrow"
                tooltip: Translation.tr("Run")
                onClicked: root.runCommand(row.entry, false)
            }

            ActionButton {
                icon: "terminal"
                tooltip: Translation.tr("Run in terminal")
                onClicked: root.runCommand(row.entry, true)
            }

            ActionButton {
                visible: row.entry.type === "command"
                icon: "delete"
                tooltip: Translation.tr("Delete")
                onClicked: root.deleteCommand(row.entry.index)
            }
        }
    }

    component ActionButton: ToolbarButton {
        id: action
        required property string icon
        required property string tooltip
        implicitWidth: 30
        implicitHeight: 30

        contentItem: MaterialSymbol {
            anchors.centerIn: parent
            text: action.icon
            iconSize: Appearance.font.pixelSize.larger
            color: Appearance.colors.colOnSurfaceVariant
            fill: 0
        }

        StyledToolTip { text: action.tooltip }
    }
}
