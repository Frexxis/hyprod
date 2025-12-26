pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel

/**
 * Singleton service that handles tool approval communication between
 * QuickShell UI and Claude Code CLI hooks.
 *
 * Uses file-based IPC:
 * - Hook script writes to /tmp/quickshell/claude-hooks/pending/{id}.json
 * - This service watches pending/ directory and exposes approval requests
 * - User action writes to /tmp/quickshell/claude-hooks/responses/{id}.json
 * - Hook script reads response and exits with appropriate code
 */
Singleton {
    id: root

    readonly property string hookDir: "/tmp/quickshell/claude-hooks"
    readonly property string pendingDir: hookDir + "/pending"
    readonly property string responseDir: hookDir + "/responses"

    // List of pending tool approvals
    property var pendingApprovals: []
    readonly property bool hasPending: pendingApprovals.length > 0
    readonly property int pendingCount: pendingApprovals.length

    // Signals for UI notification
    signal approvalRequested(var approval)
    signal approvalCompleted(string id, bool approved)

    // Ensure directories exist on startup
    Component.onCompleted: {
        ensureDirsProcess.running = true;
        // Initial scan after a short delay
        Qt.callLater(scanPendingDirectory);
    }

    Process {
        id: ensureDirsProcess
        command: ["mkdir", "-p", root.pendingDir, root.responseDir]
        running: false
    }

    // FolderListModel to watch pending directory for changes
    FolderListModel {
        id: pendingFolderModel
        folder: "file://" + root.pendingDir
        nameFilters: ["*.json"]
        showDirs: false
        showDotAndDotDot: false
        sortField: FolderListModel.Time
        sortReversed: true

        onCountChanged: {
            root.scanPendingDirectory();
        }
    }

    // Timer for periodic scanning (backup for FolderListModel edge cases)
    Timer {
        id: scanTimer
        interval: 500 // 500ms
        running: true
        repeat: true
        onTriggered: root.scanPendingDirectory()
    }

    // FileView for reading pending files
    FileView {
        id: pendingFileReader
        property string currentId: ""
        property string currentPath: ""
        watchChanges: false

        onLoadedChanged: {
            if (!loaded || !currentId) return;
            try {
                const data = JSON.parse(text());
                const approval = {
                    id: data.id || currentId,
                    toolName: data.tool_name || "Unknown",
                    toolInput: data.tool_input || {},
                    timestamp: data.timestamp || Date.now() / 1000,
                    timeoutAt: data.timeout_at || 0
                };

                // Check if already in list
                const exists = root.pendingApprovals.some(a => a.id === approval.id);
                if (!exists) {
                    root.pendingApprovals = [...root.pendingApprovals, approval];
                    root.approvalRequested(approval);
                }
            } catch (e) {
                console.warn("[ClaudeToolApprovalService] Failed to parse pending file:", currentPath, e);
            }
            currentId = "";
            currentPath = "";
        }
    }

    // FileView for writing response files
    FileView {
        id: responseFileWriter
        watchChanges: false
        blockLoading: true
    }

    // Scan pending directory and update approvals list
    function scanPendingDirectory() {
        // Get current pending IDs from model
        const currentPendingIds = new Set();

        for (let i = 0; i < pendingFolderModel.count; i++) {
            const fileName = pendingFolderModel.get(i, "fileName");
            if (!fileName) continue;

            const id = fileName.replace(".json", "");
            currentPendingIds.add(id);

            // Read file if not already in our list
            const exists = root.pendingApprovals.some(a => a.id === id);
            if (!exists) {
                const filePath = root.pendingDir + "/" + fileName;
                readPendingFile(id, filePath);
            }
        }

        // Remove approvals that no longer have pending files (already processed)
        root.pendingApprovals = root.pendingApprovals.filter(a => currentPendingIds.has(a.id));
    }

    function readPendingFile(id, filePath) {
        pendingFileReader.currentId = id;
        pendingFileReader.currentPath = filePath;
        pendingFileReader.path = "";  // Unload
        pendingFileReader.path = "file://" + filePath;
        pendingFileReader.reload();
    }

    // Approve a tool use request
    function approve(id) {
        writeResponse(id, true);
    }

    // Reject a tool use request
    function reject(id) {
        writeResponse(id, false);
    }

    // Reject all pending approvals
    function rejectAll() {
        const ids = root.pendingApprovals.map(a => a.id);
        ids.forEach(id => reject(id));
    }

    // Write response file for hook to read
    function writeResponse(id, approved) {
        const responsePath = root.responseDir + "/" + id + ".json";
        const responseData = JSON.stringify({
            approved: approved,
            timestamp: Math.floor(Date.now() / 1000)
        });

        responseFileWriter.path = "";  // Unload
        responseFileWriter.path = "file://" + responsePath;
        responseFileWriter.setText(responseData);

        // Remove from pending list
        root.pendingApprovals = root.pendingApprovals.filter(a => a.id !== id);

        // Emit signal
        root.approvalCompleted(id, approved);
    }

    // Get approval by ID
    function getApproval(id) {
        return root.pendingApprovals.find(a => a.id === id) || null;
    }

    // Format tool input for display
    function formatToolInput(approval) {
        if (!approval || !approval.toolInput) return "";

        const input = approval.toolInput;
        const name = approval.toolName || "";

        if (name === "Read" && input.file_path) {
            return "File: " + input.file_path;
        }
        if (name === "Edit" && input.file_path) {
            return "Editing: " + input.file_path;
        }
        if (name === "Write" && input.file_path) {
            return "Writing: " + input.file_path;
        }
        if (name === "Bash" && input.command) {
            const cmd = input.command;
            return "Command: " + (cmd.length > 80 ? cmd.substring(0, 80) + "..." : cmd);
        }
        if (name === "MultiEdit" && input.edits) {
            return "Multiple edits: " + input.edits.length + " files";
        }

        // Generic fallback
        const str = JSON.stringify(input);
        return str.length > 100 ? str.substring(0, 100) + "..." : str;
    }
}
