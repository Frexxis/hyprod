import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls

/**
 * A ListView with animations.
 */
ListView {
    id: root
    spacing: 5
    property real removeOvershoot: 20 // Account for gaps and bouncy animations
    property int dragIndex: -1
    property real dragDistance: 0
    property bool popin: true
    property bool animateAppearance: true
    property bool animateMovement: false
    // Accumulated scroll destination so wheel deltas stack while animating
    property real scrollTargetY: 0

    // Cleanup on destruction to prevent memory leaks
    Component.onDestruction: {
        // Reset model to release delegate references
        model = null;
        // Stop any running animations
        scrollTargetY = 0;
    }

    property real touchpadScrollFactor: Config?.options.interactions.scrolling.touchpadScrollFactor ?? 100
    property real mouseScrollFactor: Config?.options.interactions.scrolling.mouseScrollFactor ?? 50
    property real mouseScrollDeltaThreshold: Config?.options.interactions.scrolling.mouseScrollDeltaThreshold ?? 120

    function resetDrag() {
        root.dragIndex = -1
        root.dragDistance = 0
    }

    maximumFlickVelocity: 3500
    boundsBehavior: Flickable.DragOverBounds
    ScrollBar.vertical: StyledScrollBar {}

    MouseArea {
        visible: Config?.options.interactions.scrolling.fasterTouchpadScroll
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: function(wheelEvent) {
            const delta = wheelEvent.angleDelta.y / root.mouseScrollDeltaThreshold;
            // The angleDelta.y of a touchpad is usually small and continuous,
            // while that of a mouse wheel is typically in multiples of ±120.
            var scrollFactor = Math.abs(wheelEvent.angleDelta.y) >= root.mouseScrollDeltaThreshold ? root.mouseScrollFactor : root.touchpadScrollFactor;

            const maxY = Math.max(0, root.contentHeight - root.height);
            const base = scrollAnim.running ? root.scrollTargetY : root.contentY;
            var targetY = Math.max(0, Math.min(base - delta * scrollFactor, maxY));

            root.scrollTargetY = targetY;
            root.contentY = targetY;
            wheelEvent.accepted = true;
        }
    }

    Behavior on contentY {
        NumberAnimation {
            id: scrollAnim
            alwaysRunToEnd: true
            duration: Appearance.animation.scroll.duration
            easing.type: Appearance.animation.scroll.type
            easing.bezierCurve: Appearance.animation.scroll.bezierCurve
        }
    }

    // Keep target synced when not animating (e.g., drag/flick or programmatic changes)
    onContentYChanged: {
        if (!scrollAnim.running) {
            root.scrollTargetY = root.contentY;
        }
    }

    add: Transition {
        NumberAnimation {
            properties: root.popin ? "opacity,scale" : "opacity"
            from: root.animateAppearance ? 0 : 1
            to: 1
            duration: root.animateAppearance ? Appearance.animation.elementMove.duration : 0
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
    }

    addDisplaced: Transition {
        NumberAnimation {
            property: "y"
            duration: root.animateAppearance ? Appearance.animation.elementMove.duration : 0
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
        NumberAnimation {
            properties: root.popin ? "opacity,scale" : "opacity"
            to: 1
            duration: root.animateAppearance ? Appearance.animation.elementMove.duration : 0
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
    }

    displaced: Transition {
        NumberAnimation {
            property: "y"
            duration: root.animateMovement ? Appearance.animation.elementMove.duration : 0
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
        NumberAnimation {
            properties: "opacity,scale"
            to: 1
            duration: root.animateMovement ? Appearance.animation.elementMove.duration : 0
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
    }

    move: Transition {
        NumberAnimation {
            property: "y"
            duration: root.animateMovement ? Appearance.animation.elementMove.duration : 0
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
        NumberAnimation {
            properties: "opacity,scale"
            to: 1
            duration: root.animateMovement ? Appearance.animation.elementMove.duration : 0
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
    }

    moveDisplaced: Transition {
        NumberAnimation {
            property: "y"
            duration: root.animateMovement ? Appearance.animation.elementMove.duration : 0
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
        NumberAnimation {
            properties: "opacity,scale"
            to: 1
            duration: root.animateMovement ? Appearance.animation.elementMove.duration : 0
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
    }

    remove: Transition {
        NumberAnimation {
            property: "x"
            to: root.width + root.removeOvershoot
            duration: root.animateAppearance ? Appearance.animation.elementMove.duration : 0
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
        NumberAnimation {
            property: "opacity"
            to: root.animateAppearance ? 0 : 1
            duration: root.animateAppearance ? Appearance.animation.elementMove.duration : 0
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
    }

    // This is movement when something is removed, not removing animation!
    removeDisplaced: Transition {
        NumberAnimation {
            property: "y"
            duration: root.animateAppearance ? Appearance.animation.elementMove.duration : 0
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
        NumberAnimation {
            properties: "opacity,scale"
            to: 1
            duration: root.animateAppearance ? Appearance.animation.elementMove.duration : 0
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
    }
}
