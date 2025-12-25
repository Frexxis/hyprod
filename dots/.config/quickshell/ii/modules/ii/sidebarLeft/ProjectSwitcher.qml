import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property bool active: false
    property int padding: 8
    property string searchText: ""

    readonly property var favorites: Config?.options?.developer?.projects?.favorites ?? []
    readonly property int maxItems: Config?.options?.developer?.projects?.maxItems ?? 200

    function shellQuoted(str) {
        return `'${StringUtils.shellSingleQuoteEscape(str)}'`;
    }

    function toggleFavorite(path) {
        const favs = (root.favorites ?? []).slice(0);
        const idx = favs.indexOf(path);
        if (idx >= 0) {
            favs.splice(idx, 1);
        } else {
            favs.push(path);
        }
        Config.setNestedValue("developer.projects.favorites", favs);
    }

    function isFavorite(path) {
        return (root.favorites ?? []).includes(path);
    }

    function setGitRepo(path) {
        Config.setNestedValue("developer.git.repoPath", path);
    }

    function openFolder(path) {
        Quickshell.execDetached(["xdg-open", path]);
    }

    function copyPath(path) {
        Quickshell.clipboardText = path;
    }

    function openEditor(path) {
        const p = shellQuoted(path);
        Quickshell.execDetached(["bash", "-c", `code ${p} || codium ${p} || cursor ${p} || zed ${p} || xdg-open ${p}`]);
    }

    function openTerminal(path) {
        const terminal = (Config?.options?.apps?.terminal ?? "").toString().trim();
        const shell = (Quickshell.env("SHELL") || "bash").toString();

        const pathQ = shellQuoted(path);
        const shellQ = shellQuoted(shell);
        const innerScript = `cd ${pathQ} && exec ${shellQ} -l`;
        const innerScriptQ = shellQuoted(innerScript);

        if (terminal.length === 0) {
            Quickshell.execDetached(["bash", "-lc", innerScript]);
            return;
        }

        Quickshell.execDetached(["bash", "-c", `${terminal} -e bash -lc ${innerScriptQ}`]);
    }

    function refreshIfActive() {
        if (root.active) Projects.refresh();
    }

    onActiveChanged: refreshIfActive()

    Timer {
        interval: Config?.options?.developer?.projects?.refreshInterval ?? 15000
        repeat: true
        running: root.active && Projects.available
        triggeredOnStart: true
        onTriggered: Projects.refresh()
    }

    readonly property var displayEntries: {
        const favs = (root.favorites ?? []).map(p => ({ score: null, path: p, favorite: true }));

        const z = (Projects.entries ?? []).slice(0, root.maxItems);
        const seen = {};

        const combined = [];
        for (let i = 0; i < favs.length; i++) {
            const p = favs[i].path;
            if (!p || seen[p]) continue;
            seen[p] = true;
            combined.push(favs[i]);
        }
        for (let i = 0; i < z.length; i++) {
            const p = z[i].path;
            if (!p || seen[p]) continue;
            seen[p] = true;
            combined.push({ score: z[i].score, path: p, favorite: root.isFavorite(p) });
        }

        const q = root.searchText.trim();
        if (q.length === 0) return combined;

        const prepared = combined.map(e => ({ name: Fuzzy.prepare(e.path), obj: e }));
        const results = Fuzzy.go(q, prepared, { all: true, key: "name" });
        return results.map(r => r.obj);
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
                text: "folder_open"
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colOnSurfaceVariant
                fill: 0
            }

            ToolbarTextField {
                id: searchField
                Layout.fillWidth: true
                implicitHeight: 36
                placeholderText: Translation.tr("Search projects")
                text: root.searchText
                onTextChanged: root.searchText = text
            }

            ToolbarButton {
                Layout.fillHeight: false
                implicitWidth: 34
                implicitHeight: 34
                onClicked: Projects.refresh()

                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "refresh"
                    iconSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnSurfaceVariant
                    fill: 0
                }

                StyledToolTip { text: Translation.tr("Refresh") }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Appearance.rounding.small
            color: Appearance.colors.colLayer1

            StyledListView {
                id: list
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                visible: Projects.available && root.displayEntries.length > 0

                model: ScriptModel {
                    values: root.displayEntries
                }

                delegate: ProjectRow {
                    required property var modelData
                    path: modelData.path
                    score: modelData.score
                    favorite: root.isFavorite(modelData.path)
                }
            }

            PagePlaceholder {
                shown: Projects.available && root.displayEntries.length === 0 && !Projects.refreshing
                icon: "folder_open"
                title: Translation.tr("No projects")
                description: Translation.tr("Use zoxide to build history")
                shape: MaterialShape.Shape.PixelCircle
            }

            PagePlaceholder {
                shown: !Projects.available && !Projects.refreshing
                icon: "block"
                title: Translation.tr("zoxide is not installed")
                description: Translation.tr("Install zoxide to enable this tab")
                shape: MaterialShape.Shape.PixelCircle
            }
        }
    }

    component ProjectRow: Rectangle {
        id: row
        required property string path
        required property var score
        required property bool favorite

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
                text: row.favorite ? "star" : "folder"
                iconSize: Appearance.font.pixelSize.larger
                color: row.favorite ? Appearance.colors.colPrimary : Appearance.colors.colOnSurfaceVariant
                fill: row.favorite ? 1 : 0
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: FileUtils.fileNameForPath(row.path)
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colOnSurfaceVariant
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: row.path
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.m3colors.m3outline
                    font.family: Appearance.font.family.monospace
                    elide: Text.ElideRight
                }
            }

            StyledText {
                visible: row.score !== null && row.score !== undefined
                text: row.score !== null ? row.score.toFixed(1) : ""
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.m3colors.m3outline
                font.family: Appearance.font.family.monospace
            }

            ActionButton {
                icon: "terminal"
                tooltip: Translation.tr("Open terminal")
                onClicked: root.openTerminal(row.path)
            }

            ActionButton {
                icon: "code"
                tooltip: Translation.tr("Open in editor")
                onClicked: root.openEditor(row.path)
            }

            ActionButton {
                icon: "folder_open"
                tooltip: Translation.tr("Open in file manager")
                onClicked: root.openFolder(row.path)
            }

            ActionButton {
                icon: "content_copy"
                tooltip: Translation.tr("Copy path")
                onClicked: root.copyPath(row.path)
            }

            ActionButton {
                icon: row.favorite ? "star" : "star_border"
                tooltip: row.favorite ? Translation.tr("Unfavorite") : Translation.tr("Favorite")
                onClicked: root.toggleFavorite(row.path)
            }

            ActionButton {
                icon: "account_tree"
                tooltip: Translation.tr("Use for Git")
                onClicked: root.setGitRepo(row.path)
            }
        }

        MouseArea {
            z: -1
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton
            onClicked: root.openTerminal(row.path)
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
