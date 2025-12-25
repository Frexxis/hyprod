pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Docker container monitoring service for the developer sidebar.
 * Provides container list, status, and basic management actions.
 */
Singleton {
    id: root

    property bool available: false
    property bool loading: false
    property var containers: []
    property int runningCount: 0
    property int stoppedCount: 0
    property string error: ""

    readonly property bool hasContainers: containers.length > 0

    function refresh() {
        if (!root.available) return;
        if (listContainersProc.running) return;
        listContainersProc.running = true;
    }

    function startContainer(containerId) {
        if (!root.available || !containerId) return;
        startProc.exec(["docker", "start", containerId]);
    }

    function stopContainer(containerId) {
        if (!root.available || !containerId) return;
        stopProc.exec(["docker", "stop", containerId]);
    }

    function restartContainer(containerId) {
        if (!root.available || !containerId) return;
        restartProc.exec(["docker", "restart", containerId]);
    }

    function parseContainerLines(text) {
        const lines = (text || "").trim().split("\n").filter(l => l.trim().length > 0);
        const result = [];
        for (let i = 0; i < lines.length; i++) {
            try {
                const parsed = JSON.parse(lines[i]);
                result.push(parsed);
            } catch (e) {
                // Skip malformed lines
            }
        }
        return result;
    }

    // Check if docker is available
    Process {
        id: checkDockerProc
        running: true
        command: ["which", "docker"]
        onExited: (exitCode, exitStatus) => {
            root.available = (exitCode === 0);
            if (root.available) {
                refreshTimer.running = true;
                listContainersProc.running = true;
            }
        }
    }

    // List all containers - output is JSON lines
    Process {
        id: listContainersProc
        command: ["docker", "ps", "-a", "--format", "{{json .}}"]
        stdout: StdioCollector { id: listCollector }

        onStarted: {
            root.loading = true;
            root.error = "";
        }

        onExited: (exitCode, exitStatus) => {
            root.loading = false;

            if (exitCode !== 0) {
                root.containers = [];
                root.runningCount = 0;
                root.stoppedCount = 0;
                return;
            }

            const parsed = root.parseContainerLines(listCollector.text);
            root.containers = parsed;
            root.runningCount = parsed.filter(c => c.State === "running").length;
            root.stoppedCount = parsed.filter(c => c.State !== "running").length;
        }
    }

    // Start container
    Process {
        id: startProc
        stderr: StdioCollector { id: startErrCollector }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.error = startErrCollector.text.trim() || "Failed to start container";
            }
            root.refresh();
        }
    }

    // Stop container
    Process {
        id: stopProc
        stderr: StdioCollector { id: stopErrCollector }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.error = stopErrCollector.text.trim() || "Failed to stop container";
            }
            root.refresh();
        }
    }

    // Restart container
    Process {
        id: restartProc
        stderr: StdioCollector { id: restartErrCollector }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.error = restartErrCollector.text.trim() || "Failed to restart container";
            }
            root.refresh();
        }
    }

    // Refresh timer - every 10 seconds
    Timer {
        id: refreshTimer
        interval: 10000
        running: false
        repeat: true
        onTriggered: {
            if (root.available) {
                listContainersProc.running = true;
            }
        }
    }
}
