import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.services.network
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.waffle.looks
import qs.modules.waffle.actionCenter

WChoiceButton {
    id: root

    property bool expanded: false
    checked: expanded
    clip: true

    horizontalPadding: 12
    verticalPadding: 6
    animateChoiceHighlight: false

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 200
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0,1,1,1,1,1]
        }
    }
    onClicked: expanded = !expanded
}
