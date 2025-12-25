import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root
    required property var scopeRoot
    property int sidebarPadding: 10
    anchors.fill: parent
    property var tabButtonList: [
        {"icon": "neurology", "name": Translation.tr("Intelligence")},
        {"icon": "account_tree", "name": Translation.tr("Git")},
        {"icon": "folder_open", "name": Translation.tr("Projects")},
        {"icon": "terminal", "name": Translation.tr("Commands")},
        {"icon": "monitoring", "name": Translation.tr("System")}
    ]
    property int tabCount: swipeView.count

    function focusActiveItem() {
        swipeView.currentItem.forceActiveFocus()
    }

    Keys.onPressed: (event) => {
        if (event.modifiers === Qt.ControlModifier) {
            if (event.key === Qt.Key_PageDown) {
                swipeView.incrementCurrentIndex()
                event.accepted = true;
            }
            else if (event.key === Qt.Key_PageUp) {
                swipeView.decrementCurrentIndex()
                event.accepted = true;
            }
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: sidebarPadding
        }
        spacing: sidebarPadding

        Toolbar {
            Layout.alignment: Qt.AlignHCenter
            enableShadow: false
            ToolbarTabBar {
                id: tabBar
                Layout.alignment: Qt.AlignHCenter
                tabButtonList: root.tabButtonList
                currentIndex: swipeView.currentIndex
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitWidth: swipeView.implicitWidth
            implicitHeight: swipeView.implicitHeight
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer1

            SwipeView { // Content pages
                id: swipeView
                anchors.fill: parent
                spacing: 10
                currentIndex: tabBar.currentIndex

                clip: true
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: swipeView.width
                        height: swipeView.height
                        radius: Appearance.rounding.small
                    }
                }

                contentChildren: [
                    aiChat.createObject(),
                    gitWidget.createObject(null, {
                        "active": Qt.binding(() => swipeView.currentIndex === 1 && GlobalStates.sidebarLeftOpen)
                    }),
                    projectSwitcher.createObject(null, {
                        "active": Qt.binding(() => swipeView.currentIndex === 2 && GlobalStates.sidebarLeftOpen)
                    }),
                    quickCommands.createObject(null, {
                        "active": Qt.binding(() => swipeView.currentIndex === 3 && GlobalStates.sidebarLeftOpen)
                    }),
                    systemMonitor.createObject(null, {
                        "active": Qt.binding(() => swipeView.currentIndex === 4 && GlobalStates.sidebarLeftOpen)
                    })
                ]
            }
        }

        Component {
            id: aiChat
            AiChat {}
        }

        Component {
            id: gitWidget
            GitWidget {}
        }

        Component {
            id: projectSwitcher
            ProjectSwitcher {}
        }

        Component {
            id: quickCommands
            QuickCommands {}
        }

        Component {
            id: systemMonitor
            SystemMonitor {}
        }

    }
}