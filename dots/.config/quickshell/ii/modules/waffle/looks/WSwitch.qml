import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.modules.common
import qs.modules.waffle.looks

Switch {
    id: root

    implicitWidth: 40
    implicitHeight: 20
    property real indicatorHeight: 12
    property real indicatorPressedHeight: 14
    property real indicatorPressedWidth: 17
    property color checkedColor: Looks.colors.accent
    property color uncheckedColor: Looks.colors.bg1
    property color borderColor: Looks.colors.controlBgInactive

    readonly property real indicatorPressedWidthDiff: indicatorPressedWidth - indicatorHeight
    
    background: Rectangle {
        width: parent.width
        height: parent.height
        radius: height / 2
        color: root.checked ? root.checkedColor : root.uncheckedColor
        border.width: 1
        border.color: root.checked ? root.checkedColor : root.borderColor

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.34, 0.80, 0.34, 1.00, 1, 1]
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.34, 0.80, 0.34, 1.00, 1, 1]
            }
        }
    }

    // Custom thumb styling
    indicator: Rectangle {
        implicitWidth: (root.pressed || root.down) ? root.indicatorPressedWidth : root.indicatorHeight
        implicitHeight: (root.pressed || root.down) ? root.indicatorPressedHeight : root.indicatorHeight
        radius: height / 2
        color: root.checked ? Looks.colors.accentFg : root.borderColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: {
            if (root.checked) {
                return 24 - (root.pressed || root.down ? root.indicatorPressedWidthDiff : 0);
            } else {
                return (root.pressed || root.down) ? 3 : (Config.options.waffles.tweaks.switchHandlePositionFix ? 4 : 3);
            }
        }

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: 250
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0,1,1,1,1,1]
            }
        }
        Behavior on implicitWidth {
            NumberAnimation {
                duration: 200
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0,1,1,1,1,1]
            }
        }
        Behavior on implicitHeight {
            NumberAnimation {
                duration: 200
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0,1,1,1,1,1]
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: 80
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0,1,1,1,1,1]
            }
        }
    }
}
