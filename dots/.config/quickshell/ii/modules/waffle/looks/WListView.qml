import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls

ListView {
    id: root

    boundsBehavior: Flickable.DragOverBounds

    ScrollBar.vertical: WScrollBar {}

    displaced: Transition {
        NumberAnimation {
            property: "y"
            duration: 250
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0,1,1,1,1,1]
        }
    }

}
