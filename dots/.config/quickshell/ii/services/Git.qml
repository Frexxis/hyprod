pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.functions

/**
 * Lightweight git status helper for the developer sidebar.
 */
Singleton {
    id: root

    property bool available: false
    property bool repoAvailable: false
    property string requestedPath: ""
    property string repoRoot: ""

    property string branch: ""
    property int ahead: 0
    property int behind: 0

    property int staged: 0
    property int unstaged: 0
    property int untracked: 0

    property var files: []
    property var logEntries: []
    property string error: ""

    property string currentDiffPath: ""
    property string diffContent: ""
    property bool diffLoading: false

    readonly property bool dirty: root.files.length > 0
    readonly property bool refreshing: checkRepoProc.running || statusProc.running

    function normalizePath(path) {
        const trimmed = (path ?? "").toString().trim();
        if (trimmed.length === 0) return "";

        if (trimmed.startsWith("file://")) {
            return FileUtils.trimFileProtocol(trimmed);
        }
        if (trimmed === "~") {
            return FileUtils.trimFileProtocol(Directories.home);
        }
        if (trimmed.startsWith("~/")) {
            return FileUtils.trimFileProtocol(Directories.home) + trimmed.substring(1);
        }
        return trimmed;
    }

    function clearRepoState() {
        repoAvailable = false;
        repoRoot = "";
        branch = "";
        ahead = 0;
        behind = 0;
        staged = 0;
        unstaged = 0;
        untracked = 0;
        files = [];
        logEntries = [];
    }

    function parseStatus(porcelain) {
        branch = "";
        ahead = 0;
        behind = 0;
        staged = 0;
        unstaged = 0;
        untracked = 0;
        files = [];

        const lines = (porcelain ?? "").toString().split("\n").filter(l => l.trim().length > 0);
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];

            if (line.startsWith("## ")) {
                const rest = line.substring(3);
                const headPart = rest.split(" ")[0];
                branch = headPart.split("...")[0];

                const aheadMatch = rest.match(/\[.*ahead (\d+).*\]/);
                const behindMatch = rest.match(/\[.*behind (\d+).*\]/);
                if (aheadMatch) ahead = parseInt(aheadMatch[1]);
                if (behindMatch) behind = parseInt(behindMatch[1]);
                continue;
            }

            if (line.length < 3) continue;
            const x = line[0];
            const y = line[1];
            const path = line.substring(3);

            files.push({ x, y, path });

            if (x === "?" && y === "?") {
                untracked++;
                continue;
            }

            if (x !== " " && x !== "?" && x !== "!") staged++;
            if (y !== " " && y !== "?" && y !== "!") unstaged++;
        }
    }

    function refresh() {
        if (!root.available) {
            root.error = "Git is not installed";
            root.clearRepoState();
            return;
        }
        if (root.refreshing) return;

        root.error = "";

        const configPath = Config?.options?.developer?.git?.repoPath ?? "";
        const detectedPath = Quickshell.shellPath("");
        const path = root.normalizePath(configPath) || root.normalizePath(detectedPath) || detectedPath;
        root.requestedPath = path;

        checkRepoProc.exec(["git", "-C", path, "rev-parse", "--show-toplevel"]);
    }

    function refreshLog() {
        if (!root.repoAvailable) return;
        if (logProc.running) return;
        logProc.exec(["git", "-C", root.repoRoot, "log", "-3", "--pretty=format:%h\t%s"]);
    }

    function stage(path) {
        if (!root.repoAvailable) return;
        const p = (path ?? "").toString();
        if (p.trim().length === 0) return;
        root.error = "";
        stageProc.exec(["git", "-C", root.repoRoot, "add", "--", p]);
    }

    function unstage(path) {
        if (!root.repoAvailable) return;
        const p = (path ?? "").toString();
        if (p.trim().length === 0) return;
        root.error = "";
        unstageProc.exec(["git", "-C", root.repoRoot, "restore", "--staged", "--", p]);
    }

    function commit(message) {
        if (!root.repoAvailable) return;
        const msg = (message ?? "").toString().trim();
        if (msg.length === 0) {
            root.error = "Commit message is required";
            return;
        }
        root.error = "";
        commitProc.exec(["git", "-C", root.repoRoot, "commit", "-m", msg]);
    }

    function getDiff(path) {
        if (!root.repoAvailable) return;
        const p = (path ?? "").toString().trim();
        if (p.length === 0) {
            root.currentDiffPath = "";
            root.diffContent = "";
            return;
        }
        if (diffProc.running) return;
        root.currentDiffPath = p;
        root.diffLoading = true;
        root.diffContent = "";
        diffProc.exec(["git", "-C", root.repoRoot, "diff", "--", p]);
    }

    function clearDiff() {
        root.currentDiffPath = "";
        root.diffContent = "";
        root.diffLoading = false;
    }

    Process {
        id: checkAvailabilityProc
        running: true
        command: ["which", "git"]
        onExited: (exitCode, exitStatus) => {
            root.available = (exitCode === 0);
        }
    }

    Process {
        id: checkRepoProc
        stdout: StdioCollector { id: repoRootCollector }

        onExited: (exitCode, exitStatus) => {
            const resolved = repoRootCollector.text.trim();
            if (exitCode !== 0 || resolved.length === 0) {
                root.error = "No git repository found";
                root.clearRepoState();
                return;
            }

            root.repoAvailable = true;
            root.repoRoot = resolved;
            statusProc.exec(["git", "-C", root.repoRoot, "status", "--porcelain=v1", "-b"]);
        }
    }

    Process {
        id: statusProc
        stdout: StdioCollector { id: statusCollector }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.error = "Failed to read git status";
                root.clearRepoState();
                return;
            }

            root.repoAvailable = true;
            root.parseStatus(statusCollector.text);
            root.refreshLog();
        }
    }

    Process {
        id: logProc
        stdout: StdioCollector { id: logCollector }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.logEntries = [];
                return;
            }

            const lines = (logCollector.text ?? "").split("\n").map(l => l.trim()).filter(l => l.length > 0);
            root.logEntries = lines.map(line => {
                const tabIdx = line.indexOf("\t");
                if (tabIdx === -1) return { hash: line, subject: "" };
                return { hash: line.substring(0, tabIdx), subject: line.substring(tabIdx + 1) };
            });
        }
    }

    Process {
        id: stageProc
        stderr: StdioCollector { id: stageErrCollector }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                const err = stageErrCollector.text.trim();
                root.error = err.length > 0 ? err : "Failed to stage";
                return;
            }
            root.refresh();
        }
    }

    Process {
        id: unstageProc
        stderr: StdioCollector { id: unstageErrCollector }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                const err = unstageErrCollector.text.trim();
                root.error = err.length > 0 ? err : "Failed to unstage";
                return;
            }
            root.refresh();
        }
    }

    Process {
        id: commitProc
        stderr: StdioCollector { id: commitErrCollector }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                const err = commitErrCollector.text.trim();
                root.error = err.length > 0 ? err : "Commit failed";
                return;
            }
            root.refresh();
        }
    }

    Process {
        id: diffProc
        stdout: StdioCollector { id: diffCollector }
        onExited: (exitCode, exitStatus) => {
            root.diffLoading = false;
            if (exitCode !== 0) {
                root.diffContent = "";
                return;
            }
            root.diffContent = diffCollector.text;
        }
    }
    Component.onDestruction: {
         const processes = [checkAvailabilityProc, checkRepoProc, statusProc, logProc, stageProc, unstageProc, commitProc, diffProc];
         processes.forEach(p => { if(p) p.running = false; });
    }
}
