import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool active: false
    property int padding: 8

    readonly property string scratchpadScript: FileUtils.trimFileProtocol(`${Directories.config}/hypr/hyprland/scripts/toggle-scratchpad.sh`)
    property string diskPath: Config?.options?.developer?.system?.diskPath ?? "/"

    property bool diskAvailable: false
    property real diskUsedPercentage: 0
    property real diskTotalKb: 1
    property real diskAvailKb: 0
    property string diskFilesystem: ""
    property string diskMountpoint: ""
    property string diskError: ""

    function kbToGbString(kb) {
        return (kb / (1024 * 1024)).toFixed(1) + " GB";
    }

    function openBtop() {
        Quickshell.execDetached([
            scratchpadScript,
            "btop",
            "kitty",
            "--class",
            "btop",
            "-e",
            "btop"
        ])
    }

    function refreshDisk() {
        if (!root.active) return;
        diskProc.exec(["df", "-kP", root.diskPath]);
    }

    onActiveChanged: {
        if (root.active) refreshDisk();
    }
    onDiskPathChanged: {
        if (root.active) refreshDisk();
    }

    Timer {
        interval: Config?.options?.developer?.system?.diskRefreshInterval ?? 60000
        repeat: true
        running: root.active
        triggeredOnStart: true
        onTriggered: refreshDisk()
    }

    Process {
        id: diskProc
        stdout: StdioCollector { id: diskCollector }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.diskAvailable = false;
                root.diskError = "Failed to read disk usage";
                return;
            }

            const lines = diskCollector.text.trim().split("\n").filter(l => l.trim().length > 0);
            if (lines.length < 2) {
                root.diskAvailable = false;
                root.diskError = "Unexpected df output";
                return;
            }

            const parts = lines[lines.length - 1].trim().split(/\s+/);
            if (parts.length < 6) {
                root.diskAvailable = false;
                root.diskError = "Unexpected df output";
                return;
            }

            root.diskFilesystem = parts[0];
            root.diskTotalKb = parseFloat(parts[1]) || 1;
            root.diskAvailKb = parseFloat(parts[3]) || 0;
            root.diskUsedPercentage = (parseInt((parts[4] || "0").replace("%", "")) || 0) / 100;
            root.diskMountpoint = parts[5];
            root.diskAvailable = true;
            root.diskError = "";
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
                text: "monitoring"
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colOnSurfaceVariant
                fill: 0
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: Translation.tr("System")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colOnSurfaceVariant
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: diskAvailable ? `${Translation.tr("Disk")}: ${Math.round(diskUsedPercentage * 100)}%` : (diskError.length > 0 ? diskError : Translation.tr("Disk"))
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.m3colors.m3outline
                    elide: Text.ElideRight
                }
            }

            ToolbarButton {
                Layout.fillHeight: false
                implicitWidth: 34
                implicitHeight: 34
                onClicked: refreshDisk()

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
                onClicked: openBtop()

                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "terminal"
                    iconSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnSurfaceVariant
                    fill: 0
                }

                StyledToolTip {
                    text: Translation.tr("Open btop")
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Appearance.rounding.small
            color: Appearance.colors.colLayer1

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 10
                }
                spacing: 12

                MetricRow {
                    icon: "planner_review"
                    label: Translation.tr("CPU")
                    percent: ResourceUsage.cpuUsage
                    detail: Translation.tr("of %1").arg(ResourceUsage.maxAvailableCpuString)
                }

                MetricRow {
                    icon: "memory"
                    label: Translation.tr("RAM")
                    percent: ResourceUsage.memoryUsedPercentage
                    detail: Translation.tr("of %1").arg(ResourceUsage.maxAvailableMemoryString)
                }

                MetricRow {
                    visible: ResourceUsage.swapTotal > 0
                    icon: "swap_horiz"
                    label: Translation.tr("Swap")
                    percent: ResourceUsage.swapUsedPercentage
                    detail: Translation.tr("of %1").arg(ResourceUsage.maxAvailableSwapString)
                }

                MetricRow {
                    icon: "storage"
                    label: Translation.tr("Disk")
                    percent: diskAvailable ? diskUsedPercentage : 0
                    detail: diskAvailable ? Translation.tr("%1 free of %2").arg(kbToGbString(diskAvailKb)).arg(kbToGbString(diskTotalKb)) : (diskError.length > 0 ? diskError : Translation.tr("No data"))
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    component MetricRow: ColumnLayout {
        id: metricRow
        required property string icon
        required property string label
        required property real percent
        required property string detail

        spacing: 6
        Layout.fillWidth: true

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MaterialSymbol {
                text: metricRow.icon
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colOnSurfaceVariant
                fill: 0
            }

            StyledText {
                Layout.fillWidth: true
                text: metricRow.label
                font.pixelSize: Appearance.font.pixelSize.normal
                color: Appearance.colors.colOnSurfaceVariant
                elide: Text.ElideRight
            }

            StyledText {
                text: `${Math.round((metricRow.percent || 0) * 100)}%`
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.m3colors.m3outline
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 8
            radius: 4
            color: Appearance.colors.colLayer2

            Rectangle {
                width: Math.max(0, Math.min(1, metricRow.percent || 0)) * parent.width
                height: parent.height
                radius: parent.radius
                color: Appearance.colors.colPrimary

                Behavior on width {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: metricRow.detail
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.m3colors.m3outline
            elide: Text.ElideRight
        }
    }
}
