pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import org.kde.syntaxhighlighting

ColumnLayout {
    id: root
    // These are needed on the parent loader
    property bool editing: false
    property bool renderMarkdown: true
    property bool enableMouseSelection: false
    property var segmentContent: ({})
    property var segmentLang: "txt"
    property var messageData: {}
    property bool isCommandRequest: segmentLang === "command"
    property var displayLang: (isCommandRequest ? "bash" : segmentLang)

    property real codeBlockBackgroundRounding: Appearance.rounding.small
    property real codeBlockHeaderPadding: 3
    property real codeBlockComponentSpacing: 2
    property bool showApplyDialog: false
    property string applyPath: ""
    property string applyError: ""

    spacing: codeBlockComponentSpacing

    function normalizeApplyPath(path) {
        const trimmed = (path ?? "").toString().trim();
        if (trimmed.length === 0) return "";
        if (trimmed === "~") {
            return FileUtils.trimFileProtocol(Directories.home);
        }
        if (trimmed.startsWith("~/")) {
            return FileUtils.trimFileProtocol(Directories.home) + trimmed.substring(1);
        }
        return trimmed;
    }

    function openApplyDialog() {
        root.applyPath = "";
        root.applyError = "";
        root.showApplyDialog = true;
    }

    function applyCodeToFile() {
        const target = normalizeApplyPath(root.applyPath);
        if (target.length === 0) {
            root.applyError = Translation.tr("File path is required");
            return;
        }

        const parentDir = FileUtils.parentDirectory(target);
        if (parentDir.length > 0) {
            Quickshell.execDetached(["mkdir", "-p", parentDir]);
        }

        applyFileView.path = Qt.resolvedUrl(target);
        applyFileView.setText(String(segmentContent));
        root.showApplyDialog = false;
        root.applyError = "";

        Quickshell.execDetached([
            "notify-send",
            Translation.tr("Code saved to file"),
            Translation.tr("Saved to %1").arg(target),
            "-a",
            "Shell"
        ]);
    }

    function explainCode() {
        const codeText = String(segmentContent ?? "").trim();
        if (codeText.length === 0) return;
        const lang = root.displayLang || "text";
        const prompt = Translation.tr("Explain this code") + ":\n\n```" + lang + "\n" + codeText + "\n```";
        Ai.sendUserMessage(prompt);
    }

    Rectangle { // Code background
        Layout.fillWidth: true
        topLeftRadius: codeBlockBackgroundRounding
        topRightRadius: codeBlockBackgroundRounding
        bottomLeftRadius: Appearance.rounding.unsharpen
        bottomRightRadius: Appearance.rounding.unsharpen
        color: Appearance.colors.colSurfaceContainerHighest
        implicitHeight: codeBlockTitleBarRowLayout.implicitHeight + codeBlockHeaderPadding * 2

        RowLayout { // Language and buttons
            id: codeBlockTitleBarRowLayout
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: codeBlockHeaderPadding
            anchors.rightMargin: codeBlockHeaderPadding
            spacing: 5

            StyledText {
                id: codeBlockLanguage
                Layout.alignment: Qt.AlignLeft
                Layout.fillWidth: false
                Layout.topMargin: 7
                Layout.bottomMargin: 7
                Layout.leftMargin: 10
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: Appearance.colors.colOnLayer2
                text: root.displayLang ? Repository.definitionForName(root.displayLang).name : "plain"
            }

            Item { Layout.fillWidth: true }

            ButtonGroup {
                AiMessageControlButton {
                    id: copyCodeButton
                    buttonIcon: activated ? "inventory" : "content_copy"

                    onClicked: {
                        Quickshell.clipboardText = segmentContent
                        copyCodeButton.activated = true
                        copyIconTimer.restart()
                    }

                    Timer {
                        id: copyIconTimer
                        interval: 1500
                        repeat: false
                        onTriggered: {
                            copyCodeButton.activated = false
                        }
                    }
                    StyledToolTip {
                        text: Translation.tr("Copy code")
                    }
                }
                AiMessageControlButton {
                    id: saveCodeButton
                    buttonIcon: activated ? "check" : "save"

                    onClicked: {
                        const downloadPath = FileUtils.trimFileProtocol(Directories.downloads)
                        Quickshell.execDetached(["bash", "-c", 
                            `echo '${StringUtils.shellSingleQuoteEscape(segmentContent)}' > '${downloadPath}/code.${segmentLang || "txt"}'`
                        ])
                        Quickshell.execDetached(["notify-send", 
                            Translation.tr("Code saved to file"), 
                            Translation.tr("Saved to %1").arg(`${downloadPath}/code.${segmentLang || "txt"}`),
                            "-a", "Shell"
                        ])
                        saveCodeButton.activated = true
                        saveIconTimer.restart()
                    }

                    Timer {
                        id: saveIconTimer
                        interval: 1500
                        repeat: false
                        onTriggered: {
                            saveCodeButton.activated = false
                        }
                    }
                    StyledToolTip {
                        text: Translation.tr("Save to Downloads")
                    }
                }
                AiMessageControlButton {
                    id: applyCodeButton
                    buttonIcon: activated ? "check" : "save_as"

                    onClicked: {
                        openApplyDialog();
                        applyCodeButton.activated = true;
                        applyIconTimer.restart();
                    }

                    Timer {
                        id: applyIconTimer
                        interval: 1500
                        repeat: false
                        onTriggered: {
                            applyCodeButton.activated = false
                        }
                    }
                    StyledToolTip {
                        text: Translation.tr("Apply to file")
                    }
                }
                AiMessageControlButton {
                    id: runInTerminalButton
                    visible: ["bash", "sh", "zsh", "fish", "command"].includes(root.segmentLang)
                    buttonIcon: activated ? "check" : "play_arrow"

                    onClicked: {
                        // Run script in terminal
                        const scriptContent = segmentContent;
                        Quickshell.execDetached(["kitty", "--hold", "-e", "bash", "-c", scriptContent]);
                        runInTerminalButton.activated = true;
                        runInTerminalTimer.restart();
                    }

                    Timer {
                        id: runInTerminalTimer
                        interval: 1500
                        repeat: false
                        onTriggered: {
                            runInTerminalButton.activated = false
                        }
                    }
                    StyledToolTip {
                        text: Translation.tr("Run in terminal")
                    }
                }
                AiMessageControlButton {
                    id: explainButton
                    buttonIcon: activated ? "check" : "lightbulb"

                    onClicked: {
                        explainCode();
                        explainButton.activated = true;
                        explainIconTimer.restart();
                    }

                    Timer {
                        id: explainIconTimer
                        interval: 1500
                        repeat: false
                        onTriggered: {
                            explainButton.activated = false
                        }
                    }
                    StyledToolTip {
                        text: Translation.tr("Explain code")
                    }
                }
            }
        }
    }

    RowLayout { // Line numbers and code
        spacing: codeBlockComponentSpacing

        Rectangle { // Line numbers
            implicitWidth: 40
            implicitHeight: lineNumberColumnLayout.implicitHeight
            Layout.fillHeight: true
            Layout.fillWidth: false
            topLeftRadius: Appearance.rounding.unsharpen
            bottomLeftRadius: codeBlockBackgroundRounding
            topRightRadius: Appearance.rounding.unsharpen
            bottomRightRadius: Appearance.rounding.unsharpen
            color: Appearance.colors.colLayer2

            ColumnLayout {
                id: lineNumberColumnLayout
                anchors {
                    left: parent.left
                    right: parent.right
                    rightMargin: 5
                    top: parent.top
                    topMargin: 6
                }
                spacing: 0
                
                Repeater {
                    model: codeTextArea.text.split("\n").length
                    Text {
                        required property int index
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignRight
                        font.family: Appearance.font.family.monospace
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colSubtext
                        horizontalAlignment: Text.AlignRight
                        text: index + 1
                    }
                }
            }
        }

        Rectangle { // Code background
            Layout.fillWidth: true
            topLeftRadius: Appearance.rounding.unsharpen
            bottomLeftRadius: Appearance.rounding.unsharpen
            topRightRadius: Appearance.rounding.unsharpen
            bottomRightRadius: codeBlockBackgroundRounding
            color: Appearance.colors.colLayer2
            implicitHeight: codeColumnLayout.implicitHeight

            ColumnLayout {
                id: codeColumnLayout
                anchors.fill: parent
                spacing: 0
                ScrollView {
                    id: codeScrollView
                    Layout.fillWidth: true
                    // Layout.fillHeight: true
                    implicitWidth: parent.width
                    implicitHeight: codeTextArea.implicitHeight + 1
                    contentWidth: codeTextArea.width - 1
                    // contentHeight: codeTextArea.contentHeight
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                    
                    ScrollBar.horizontal: ScrollBar {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        padding: 5
                        policy: ScrollBar.AsNeeded
                        opacity: visualSize == 1 ? 0 : 1
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Appearance.animation.elementMoveFast.duration
                                easing.type: Appearance.animation.elementMoveFast.type
                                easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                            }
                        }
                        
                        contentItem: Rectangle {
                            implicitHeight: 6
                            radius: Appearance.rounding.small
                            color: Appearance.colors.colLayer2Active
                        }
                    }

                    TextArea { // Code
                        id: codeTextArea
                        Layout.fillWidth: true
                        readOnly: !editing
                        selectByMouse: enableMouseSelection || editing
                        renderType: Text.NativeRendering
                        font.family: Appearance.font.family.monospace
                        font.hintingPreference: Font.PreferNoHinting // Prevent weird bold text
                        font.pixelSize: Appearance.font.pixelSize.small
                        selectedTextColor: Appearance.m3colors.m3onSecondaryContainer
                        selectionColor: Appearance.colors.colSecondaryContainer
                        // wrapMode: TextEdit.Wrap
                        color: messageData.thinking ? Appearance.colors.colSubtext : Appearance.colors.colOnLayer1

                        text: segmentContent
                        onTextChanged: {
                            segmentContent = text
                        }

                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Tab) {
                                // Insert 4 spaces at cursor
                                const cursor = codeTextArea.cursorPosition;
                                codeTextArea.insert(cursor, "    ");
                                codeTextArea.cursorPosition = cursor + 4;
                                event.accepted = true;
                            } else if ((event.key === Qt.Key_C) && event.modifiers == Qt.ControlModifier) {
                                codeTextArea.copy();
                                event.accepted = true;
                            }
                        }

                        SyntaxHighlighter {
                            id: highlighter
                            textEdit: codeTextArea
                            repository: Repository
                            definition: Repository.definitionForName(root.displayLang || "plaintext")
                            theme: Appearance.syntaxHighlightingTheme
                        }
                    }
                }
                Loader {
                    active: root.isCommandRequest && root.messageData.functionPending
                    visible: active
                    Layout.fillWidth: true
                    Layout.margins: 6
                    Layout.topMargin: 0
                    sourceComponent: RowLayout {
                        Item { Layout.fillWidth: true }
                        ButtonGroup {
                            GroupButton {
                                contentItem: StyledText {
                                    text: Translation.tr("Reject")
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colOnLayer2
                                }
                                onClicked: Ai.rejectCommand(root.messageData)
                            }
                            GroupButton {
                                toggled: true
                                contentItem: StyledText {
                                    text: Translation.tr("Approve")
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: Appearance.colors.colOnPrimary
                                }
                                onClicked: Ai.approveCommand(root.messageData)
                            }
                        }
                    }
                }
            }

            // MouseArea to block scrolling
            // MouseArea {
            //     id: codeBlockMouseArea
            //     anchors.fill: parent
            //     acceptedButtons: editing ? Qt.NoButton : Qt.LeftButton
            //     cursorShape: (enableMouseSelection || editing) ? Qt.IBeamCursor : Qt.ArrowCursor
            //     onWheel: (event) => {
            //         event.accepted = false
            //     }
            // }
        }
    }

    FileView {
        id: applyFileView
        path: ""
    }

    WindowDialog {
        id: applyDialog
        anchors.fill: parent
        show: root.showApplyDialog
        onDismiss: root.showApplyDialog = false

        WindowDialogTitle { text: Translation.tr("Apply code to file") }

        WindowDialogParagraph {
            text: Translation.tr("Overwrite a file with this code block")
        }

        MaterialTextField {
            Layout.fillWidth: true
            placeholderText: Translation.tr("File path")
            text: root.applyPath
            onTextChanged: {
                root.applyPath = text;
                root.applyError = "";
            }
        }

        StyledText {
            Layout.fillWidth: true
            visible: root.applyError.length > 0
            text: root.applyError
            color: Appearance.colors.colError
            wrapMode: Text.Wrap
        }

        WindowDialogButtonRow {
            Layout.fillWidth: true

            DialogButton {
                buttonText: Translation.tr("Cancel")
                onClicked: root.showApplyDialog = false
            }

            DialogButton {
                buttonText: Translation.tr("Save")
                onClicked: applyCodeToFile()
            }
        }
    }
}
