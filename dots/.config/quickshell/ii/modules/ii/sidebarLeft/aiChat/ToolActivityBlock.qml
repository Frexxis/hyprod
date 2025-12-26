pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

/**
 * Displays a tool use activity block in Claude Code messages.
 * Shows tool name, status, input summary, and approval buttons for interactive mode.
 */
Item {
    id: root

    // Tool data: {id, name, input, status, result, isError}
    required property var toolData
    // Message ID for approval/rejection
    property string messageId: ""

    property real blockPadding: 8
    property real blockRounding: Appearance.rounding.small

    Layout.fillWidth: true
    implicitHeight: contentColumn.implicitHeight + blockPadding * 2

    // Background color based on status
    Rectangle {
        anchors.fill: parent
        radius: blockRounding
        color: {
            switch (root.toolData?.status) {
                case "pending": return Appearance.colors.colWarningContainer ?? Appearance.colors.colSurfaceContainerHighest;
                case "running": return Appearance.colors.colSecondaryContainer;
                case "approved": return Appearance.colors.colSecondaryContainer;  // Approved, waiting for execution
                case "done": return Appearance.colors.colSuccessContainer ?? Appearance.colors.colSurfaceContainerHighest;
                case "error": return Appearance.colors.colErrorContainer;
                case "rejected": return Appearance.colors.colErrorContainer;
                default: return Appearance.colors.colSurfaceContainerHighest;
            }
        }
        border.width: root.toolData?.status === "pending" ? 1 : 0
        border.color: Appearance.colors.colWarning ?? Appearance.colors.colOutline
    }

    ColumnLayout {
        id: contentColumn
        anchors {
            fill: parent
            margins: root.blockPadding
        }
        spacing: 4

        // Header row: icon, name, status
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MaterialSymbol {
                text: getToolIcon(root.toolData?.name ?? "")
                iconSize: 18
                color: getStatusColor()
            }

            StyledText {
                text: root.toolData?.name ?? "Unknown Tool"
                font.weight: Font.Medium
                font.pixelSize: Appearance.font.pixelSize.normal
                color: Appearance.m3colors.m3onSurface
            }

            Item { Layout.fillWidth: true }

            // Status badge
            Rectangle {
                implicitWidth: statusText.implicitWidth + 12
                implicitHeight: statusText.implicitHeight + 4
                radius: Appearance.rounding.full
                color: getStatusBadgeColor()

                StyledText {
                    id: statusText
                    anchors.centerIn: parent
                    text: getStatusText()
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.Medium
                    color: getStatusTextColor()
                }
            }
        }

        // Input summary (collapsed)
        StyledText {
            visible: root.toolData?.input && Object.keys(root.toolData.input).length > 0
            Layout.fillWidth: true
            text: formatInput(root.toolData?.input ?? {})
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colSubtext
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            maximumLineCount: 2
        }

        // Result preview (when done or error)
        StyledText {
            visible: (root.toolData?.status === "done" || root.toolData?.status === "error") && root.toolData?.result
            Layout.fillWidth: true
            text: {
                const result = root.toolData?.result ?? "";
                if (result.length > 100) {
                    return result.substring(0, 100) + "...";
                }
                return result;
            }
            font.pixelSize: Appearance.font.pixelSize.small
            font.family: "monospace"
            color: root.toolData?.status === "error" ? Appearance.colors.colError : Appearance.colors.colSubtext
            wrapMode: Text.Wrap
            maximumLineCount: 3
        }

        // Approval buttons (for pending status in interactive mode)
        RowLayout {
            visible: root.toolData?.status === "pending"
            Layout.fillWidth: true
            spacing: 8

            Item { Layout.fillWidth: true }

            RippleButton {
                implicitWidth: rejectButtonContent.implicitWidth + 16
                implicitHeight: 28
                buttonRadius: Appearance.rounding.small
                colBackground: Appearance.colors.colErrorContainer
                colBackgroundHover: Appearance.colors.colError

                onClicked: {
                    if (root.messageId) {
                        Ai.rejectToolUse(root.messageId, root.toolData?.id);
                    }
                }

                contentItem: RowLayout {
                    id: rejectButtonContent
                    anchors.centerIn: parent
                    spacing: 4
                    MaterialSymbol {
                        text: "close"
                        iconSize: 14
                        color: Appearance.colors.colOnErrorContainer
                    }
                    StyledText {
                        text: Translation.tr("Reject")
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnErrorContainer
                    }
                }
            }

            RippleButton {
                implicitWidth: approveButtonContent.implicitWidth + 16
                implicitHeight: 28
                buttonRadius: Appearance.rounding.small
                colBackground: Appearance.colors.colPrimary
                colBackgroundHover: Appearance.colors.colPrimaryHover ?? Appearance.colors.colPrimary

                onClicked: {
                    if (root.messageId) {
                        Ai.approveToolUse(root.messageId, root.toolData?.id);
                    }
                }

                contentItem: RowLayout {
                    id: approveButtonContent
                    anchors.centerIn: parent
                    spacing: 4
                    MaterialSymbol {
                        text: "check"
                        iconSize: 14
                        color: Appearance.colors.colOnPrimary
                    }
                    StyledText {
                        text: Translation.tr("Approve")
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colOnPrimary
                    }
                }
            }
        }
    }

    // Helper functions
    function getToolIcon(name) {
        const icons = {
            "Read": "description",
            "Edit": "edit",
            "Write": "save",
            "Bash": "terminal",
            "Glob": "folder_open",
            "Grep": "search",
            "WebSearch": "travel_explore",
            "WebFetch": "public",
            "Task": "account_tree",
            "LS": "folder",
            "NotebookEdit": "edit_note",
            "MultiEdit": "edit_document"
        };
        return icons[name] || "build";
    }

    function getStatusColor() {
        switch (root.toolData?.status) {
            case "pending": return Appearance.colors.colWarning ?? Appearance.colors.colOnSurface;
            case "running": return Appearance.colors.colSecondary;
            case "approved": return Appearance.colors.colPrimary;
            case "done": return Appearance.colors.colSuccess ?? Appearance.colors.colPrimary;
            case "error": return Appearance.colors.colError;
            case "rejected": return Appearance.colors.colError;
            default: return Appearance.colors.colOnSurface;
        }
    }

    function getStatusBadgeColor() {
        switch (root.toolData?.status) {
            case "pending": return Appearance.colors.colWarning ?? Appearance.colors.colSecondary;
            case "running": return Appearance.colors.colSecondary;
            case "approved": return Appearance.colors.colPrimary;
            case "done": return Appearance.colors.colSuccess ?? Appearance.colors.colPrimary;
            case "error": return Appearance.colors.colError;
            case "rejected": return Appearance.colors.colError;
            default: return Appearance.colors.colSecondary;
        }
    }

    function getStatusTextColor() {
        switch (root.toolData?.status) {
            case "pending": return Appearance.colors.colOnWarning ?? Appearance.m3colors.m3onPrimary;
            case "running": return Appearance.colors.colOnSecondary;
            case "approved": return Appearance.colors.colOnPrimary;
            case "done": return Appearance.colors.colOnSuccess ?? Appearance.m3colors.m3onPrimary;
            case "error": return Appearance.colors.colOnError;
            case "rejected": return Appearance.colors.colOnError;
            default: return Appearance.m3colors.m3onSurface;
        }
    }

    function getStatusText() {
        switch (root.toolData?.status) {
            case "pending": return Translation.tr("Pending");
            case "running": return Translation.tr("Running");
            case "done": return Translation.tr("Done");
            case "error": return Translation.tr("Error");
            case "rejected": return Translation.tr("Rejected");
            case "approved": return Translation.tr("Approved");
            default: return root.toolData?.status ?? "";
        }
    }

    function formatInput(input) {
        if (!input || typeof input !== "object") return "";

        // Format based on tool type
        const name = root.toolData?.name ?? "";

        if (name === "Read" && input.file_path) {
            return Translation.tr("File: %1").arg(input.file_path);
        }
        if (name === "Edit" && input.file_path) {
            return Translation.tr("Editing: %1").arg(input.file_path);
        }
        if (name === "Write" && input.file_path) {
            return Translation.tr("Writing: %1").arg(input.file_path);
        }
        if (name === "Bash" && input.command) {
            const cmd = input.command.length > 60 ? input.command.substring(0, 60) + "..." : input.command;
            return Translation.tr("Command: %1").arg(cmd);
        }
        if (name === "Glob" && input.pattern) {
            return Translation.tr("Pattern: %1").arg(input.pattern);
        }
        if (name === "Grep" && input.pattern) {
            return Translation.tr("Search: %1").arg(input.pattern);
        }
        if (name === "WebSearch" && input.query) {
            return Translation.tr("Query: %1").arg(input.query);
        }
        if (name === "WebFetch" && input.url) {
            return Translation.tr("URL: %1").arg(input.url);
        }

        // Generic fallback
        const str = JSON.stringify(input);
        return str.length > 80 ? str.substring(0, 80) + "..." : str;
    }
}
