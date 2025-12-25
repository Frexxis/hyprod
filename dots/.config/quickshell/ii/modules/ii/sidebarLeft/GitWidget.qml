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
    property string repoPathConfig: Config?.options?.developer?.git?.repoPath ?? ""
    property string commitMessage: ""
    property string selectedFile: ""
    property bool showDiff: false

    readonly property string scratchpadScript: FileUtils.trimFileProtocol(`${Directories.config}/hypr/hyprland/scripts/toggle-scratchpad.sh`)

    function openLazygit() {
        Quickshell.execDetached([
            scratchpadScript,
            "lazygit",
            "kitty",
            "--class",
            "lazygit",
            "-e",
            "lazygit"
        ])
    }

    function refreshIfActive() {
        if (root.active) Git.refresh();
    }

    onActiveChanged: refreshIfActive()
    onRepoPathConfigChanged: refreshIfActive()

    Timer {
        interval: Config?.options?.developer?.git?.refreshInterval ?? 5000
        repeat: true
        running: root.active && Git.repoAvailable
        triggeredOnStart: true
        onTriggered: Git.refresh()
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
                text: "account_tree"
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colOnSurfaceVariant
                fill: 0
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: Git.repoAvailable ? FileUtils.fileNameForPath(Git.repoRoot) : Translation.tr("Git")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colOnSurfaceVariant
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Git.repoAvailable ? `${Git.branch}${Git.ahead > 0 ? `  ↑${Git.ahead}` : ""}${Git.behind > 0 ? `  ↓${Git.behind}` : ""}` : (Git.refreshing ? Translation.tr("Refreshing...") : (Git.error || Translation.tr("No git repository found")))
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.m3colors.m3outline
                    elide: Text.ElideRight
                }
            }

            ToolbarButton {
                Layout.fillHeight: false
                implicitWidth: 34
                implicitHeight: 34
                onClicked: Git.refresh()

                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "refresh"
                    iconSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnSurfaceVariant
                    fill: 0
                }

                StyledToolTip {
                    text: Translation.tr("Refresh")
                }
            }

            ToolbarButton {
                Layout.fillHeight: false
                implicitWidth: 34
                implicitHeight: 34
                enabled: Git.repoAvailable
                onClicked: openLazygit()

                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "terminal"
                    iconSize: Appearance.font.pixelSize.larger
                    color: enabled ? Appearance.colors.colOnSurfaceVariant : Appearance.m3colors.m3outline
                    fill: 0
                }

                StyledToolTip {
                    text: Translation.tr("Open lazygit")
                    extraVisibleCondition: Git.repoAvailable
                }
            }
        }

        StyledText {
            Layout.fillWidth: true
            visible: Git.error.length > 0
            text: Git.error
            color: Appearance.colors.colError
            font.pixelSize: Appearance.font.pixelSize.small
            wrapMode: Text.Wrap
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Appearance.rounding.small
            color: Appearance.colors.colLayer1

            StyledListView {
                id: fileList
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6
                visible: Git.repoAvailable && Git.files.length > 0

                model: ScriptModel {
                    values: Git.files.slice(0, 50)
                }

                delegate: ColumnLayout {
                    required property var modelData
                    spacing: 4
                    width: fileList.width

                    readonly property bool isUntracked: modelData.x === "?" && modelData.y === "?"
                    readonly property bool hasStaged: !isUntracked && modelData.x !== " "
                    readonly property bool hasUnstaged: isUntracked || (!isUntracked && modelData.y !== " ")
                    readonly property bool isSelected: root.selectedFile === modelData.path

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        StyledText {
                            text: `${modelData.x}${modelData.y}`
                            font.family: Appearance.font.family.monospace
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: isUntracked ? Appearance.m3colors.m3outline :
                                (modelData.x !== " ") ? Appearance.colors.colPrimary : Appearance.colors.colOnSurfaceVariant
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.path
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: isSelected ? Appearance.colors.colPrimary : Appearance.colors.colOnSurfaceVariant
                            elide: Text.ElideRight

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.selectedFile === modelData.path) {
                                        root.selectedFile = "";
                                        root.showDiff = false;
                                        Git.clearDiff();
                                    } else {
                                        root.selectedFile = modelData.path;
                                        root.showDiff = true;
                                        Git.getDiff(modelData.path);
                                    }
                                }
                            }
                        }

                        ActionButton {
                            visible: hasUnstaged
                            icon: "add"
                            tooltip: Translation.tr("Stage")
                            onClicked: Git.stage(modelData.path)
                        }

                        ActionButton {
                            visible: hasStaged
                            icon: "remove"
                            tooltip: Translation.tr("Unstage")
                            onClicked: Git.unstage(modelData.path)
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        visible: isSelected && root.showDiff
                        height: visible ? Math.min(diffText.implicitHeight + 16, 150) : 0
                        radius: Appearance.rounding.small
                        color: Appearance.colors.colLayer2
                        clip: true

                        Flickable {
                            anchors.fill: parent
                            anchors.margins: 8
                            contentWidth: diffText.width
                            contentHeight: diffText.height
                            clip: true

                            StyledText {
                                id: diffText
                                text: Git.diffLoading ? Translation.tr("Loading...") :
                                    (Git.diffContent.length > 0 ? Git.diffContent : Translation.tr("No changes"))
                                font.family: Appearance.font.family.monospace
                                font.pixelSize: Appearance.font.pixelSize.tiny
                                color: Appearance.colors.colOnSurfaceVariant
                                wrapMode: Text.NoWrap
                            }
                        }
                    }
                }
            }

            PagePlaceholder {
                shown: Git.repoAvailable && Git.files.length === 0 && !Git.refreshing
                icon: "check_circle"
                title: Translation.tr("Clean working tree")
                description: Translation.tr("No local changes")
                shape: MaterialShape.Shape.PixelCircle
            }

            PagePlaceholder {
                shown: !Git.repoAvailable && !Git.refreshing
                icon: Git.available ? "account_tree" : "block"
                title: Git.available ? Translation.tr("No repository") : Translation.tr("Git is not installed")
                description: Git.available ? (
                    root.repoPathConfig.trim().length > 0 ?
                        Translation.tr("Set repoPath to a valid git repo in %1").arg(Directories.shellConfigPath) :
                        Translation.tr("Set developer.git.repoPath in %1").arg(Directories.shellConfigPath)
                ) : Translation.tr("Install git to enable this tab")
                shape: MaterialShape.Shape.PixelCircle
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: Git.repoAvailable
            spacing: 8

            MaterialTextField {
                id: commitField
                Layout.fillWidth: true
                implicitHeight: 36
                placeholderText: Translation.tr("Commit message")
                text: root.commitMessage
                onTextChanged: root.commitMessage = text
            }

            DialogButton {
                buttonText: Translation.tr("Commit")
                enabled: Git.repoAvailable && Git.staged > 0 && root.commitMessage.trim().length > 0
                onClicked: {
                    Git.commit(root.commitMessage);
                    root.commitMessage = "";
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            visible: Git.repoAvailable
            radius: Appearance.rounding.small
            color: Appearance.colors.colLayer1

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 8
                }
                spacing: 6

                StyledText {
                    Layout.fillWidth: true
                    text: Translation.tr("Recent commits")
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnSurfaceVariant
                }

                Repeater {
                    model: Git.logEntries
                    delegate: RowLayout {
                        required property var modelData
                        spacing: 8

                        StyledText {
                            text: modelData.hash
                            font.family: Appearance.font.family.monospace
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.m3colors.m3outline
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.subject
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colOnSurfaceVariant
                            elide: Text.ElideRight
                        }
                    }
                }

                StyledText {
                    visible: Git.logEntries.length === 0
                    text: Translation.tr("No commits")
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.m3colors.m3outline
                }
            }
        }

        StyledText {
            Layout.fillWidth: true
            visible: Git.repoAvailable
            text: Git.repoRoot
            font.family: Appearance.font.family.monospace
            font.pixelSize: Appearance.font.pixelSize.tiny
            color: Appearance.m3colors.m3outline
            elide: Text.ElideRight
        }

        RowLayout {
            Layout.fillWidth: true
            visible: Git.repoAvailable
            spacing: 10

            StyledText {
                text: Translation.tr("Staged: %1").arg(Git.staged)
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.m3colors.m3outline
            }
            StyledText {
                text: Translation.tr("Unstaged: %1").arg(Git.unstaged)
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.m3colors.m3outline
            }
            StyledText {
                text: Translation.tr("Untracked: %1").arg(Git.untracked)
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.m3colors.m3outline
            }
            Item { Layout.fillWidth: true }
        }
    }

    component ActionButton: ToolbarButton {
        id: action
        required property string icon
        required property string tooltip

        Layout.fillHeight: false
        implicitWidth: 28
        implicitHeight: 28

        contentItem: MaterialSymbol {
            anchors.centerIn: parent
            text: action.icon
            iconSize: Appearance.font.pixelSize.larger
            color: action.enabled ? Appearance.colors.colOnSurfaceVariant : Appearance.m3colors.m3outline
            fill: 0
        }

        StyledToolTip {
            text: action.tooltip
        }
    }
}
