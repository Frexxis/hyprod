pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

/**
 * Provides a list of recent directories via zoxide.
 */
Singleton {
    id: root

    property bool available: false
    property string error: ""

    // List of { score: real, path: string }
    property var entries: []

    readonly property bool refreshing: listProc.running

    function refresh() {
        if (!root.available) {
            root.error = "zoxide is not installed";
            root.entries = [];
            return;
        }
        if (root.refreshing) return;

        root.error = "";
        listProc.exec(["zoxide", "query", "-ls"]);
    }

    Process {
        id: checkAvailabilityProc
        running: true
        command: ["which", "zoxide"]
        onExited: (exitCode, exitStatus) => {
            root.available = (exitCode === 0);
        }
    }

    Process {
        id: listProc
        stdout: StdioCollector { id: listCollector }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.error = "Failed to query zoxide";
                root.entries = [];
                return;
            }

            const output = listCollector.text ?? "";
            const lines = output.split("\n").map(l => l.trim()).filter(l => l.length > 0);

            const results = [];
            const seen = {};

            for (let i = 0; i < lines.length; i++) {
                const line = lines[i];
                const m = line.match(/^(\S+)\s+(.*)$/);

                let score = 0;
                let path = line;

                if (m) {
                    const maybeScore = parseFloat(m[1]);
                    if (!isNaN(maybeScore)) {
                        score = maybeScore;
                        path = m[2];
                    }
                }

                path = (path ?? "").toString().trim();
                if (path.length === 0) continue;
                if (seen[path]) continue;
                seen[path] = true;

                results.push({ score, path });
            }

            root.entries = results;
        }
    }
}
