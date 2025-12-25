pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Timeshift snapshot service for the developer sidebar.
 * Provides snapshot listing and creation functionality.
 */
Singleton {
    id: root

    property bool available: false
    property bool loading: false
    property var snapshots: []
    property string lastSnapshot: ""
    property string error: ""
    property bool creating: false

    readonly property bool hasSnapshots: snapshots.length > 0

    function refresh() {
        if (!root.available) return;
        if (listSnapshotsProc.running) return;
        listSnapshotsProc.running = true;
    }

    function createSnapshot() {
        if (!root.available || root.creating) return;
        root.creating = true;
        root.error = "";
        createProc.running = true;
    }

    function parseSnapshotLines(text) {
        const lines = (text || "").trim().split("\n").filter(l => l.trim().length > 0);
        const result = [];

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            // Timeshift list output format: "  0   >  2024-12-25_10-30-00   O  "
            const match = line.match(/^\s*(\d+)\s+[>]?\s+(\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})/);
            if (match) {
                const dateStr = match[2].replace("_", " ").replace(/-/g, (m, offset) => {
                    // Replace first two dashes with / for date, keep rest for time
                    return offset < 10 ? "/" : ":";
                });
                result.push({
                    id: match[1],
                    name: match[2],
                    date: match[2].split("_")[0],
                    time: match[2].split("_")[1] ? match[2].split("_")[1].replace(/-/g, ":") : ""
                });
            }
        }
        return result;
    }

    // Check if timeshift is available
    Process {
        id: checkTimeshiftProc
        running: true
        command: ["which", "timeshift"]
        onExited: (exitCode, exitStatus) => {
            root.available = (exitCode === 0);
            if (root.available) {
                listSnapshotsProc.running = true;
            }
        }
    }

    // List snapshots
    Process {
        id: listSnapshotsProc
        command: ["timeshift", "--list"]
        stdout: StdioCollector { id: listCollector }
        stderr: StdioCollector { id: listErrCollector }

        onStarted: {
            root.loading = true;
            root.error = "";
        }

        onExited: (exitCode, exitStatus) => {
            root.loading = false;

            // timeshift --list may return non-zero if no snapshots exist
            const parsed = root.parseSnapshotLines(listCollector.text);
            root.snapshots = parsed;

            if (parsed.length > 0) {
                root.lastSnapshot = parsed[0].date + " " + parsed[0].time;
            } else {
                root.lastSnapshot = "";
            }
        }
    }

    // Create snapshot (requires pkexec for root)
    Process {
        id: createProc
        command: ["pkexec", "timeshift", "--create", "--comments", "Manual snapshot from hyprod"]
        stderr: StdioCollector { id: createErrCollector }

        onExited: (exitCode, exitStatus) => {
            root.creating = false;

            if (exitCode !== 0) {
                const err = createErrCollector.text.trim();
                root.error = err.length > 0 ? err : "Failed to create snapshot";
            } else {
                root.error = "";
            }

            root.refresh();
        }
    }
}
