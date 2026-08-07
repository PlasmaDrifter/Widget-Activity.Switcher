import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.taskmanager as TaskManager
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // Dynamic sizing for panel integration using Layout properties
    Layout.preferredWidth: {
        if (Plasmoid.configuration.layoutOrientation === 0) {
            // Stacked: width of circles is buttonHeight. Others can expand 30%, so max width is buttonWidth * 1.3
            if (Plasmoid.configuration.buttonShape === 2) {
                return Plasmoid.configuration.buttonHeight + Kirigami.Units.gridUnit;
            }
            return Plasmoid.configuration.buttonWidth * Plasmoid.configuration.sizeRatio + Kirigami.Units.gridUnit;
        } else {
            return layoutLoader.item ? layoutLoader.item.implicitWidth : Kirigami.Units.gridUnit * 10;
        }
    }
    Layout.preferredHeight: {
        if (Plasmoid.configuration.layoutOrientation === 0) {
            return layoutLoader.item ? layoutLoader.item.implicitHeight : Kirigami.Units.gridUnit * 5;
        } else {
            return Plasmoid.configuration.buttonHeight + Kirigami.Units.gridUnit * 0.5;
        }
    }

    Layout.minimumWidth: 10
    Layout.minimumHeight: 10

    implicitWidth: Layout.preferredWidth
    implicitHeight: Layout.preferredHeight
    
    // Parse custom activity color
    function getActivityColor(id) {
        try {
            var colors = JSON.parse(Plasmoid.configuration.activityColors);
            if (colors && colors[id]) {
                return colors[id];
            }
        } catch (e) {}
        return "";
    }

    // Parse custom activity icon
    function getActivityIcon(id, index) {
        try {
            var icons = JSON.parse(Plasmoid.configuration.activityIcons);
            if (icons && icons[id] !== undefined && icons[id] !== "") {
                return icons[id];
            }
        } catch (e) {}
        
        if (index === 0) {
            return Qt.resolvedUrl("1.svg");
        } else if (index === 1) {
            return Qt.resolvedUrl("2.svg");
        }
        
        return actInfo.activityIcon(id) || "activities";
    }

    // Executable data source for DBus switching commands
    Plasma5Support.DataSource {
        id: execSource
        engine: "executable"
        connectedSources: []
        onNewData: function(source, data) {
            disconnectSource(source)
        }
        function run(cmd) {
            connectSource(cmd)
        }
    }

    property var activitiesModel: []

    TaskManager.ActivityInfo {
        id: actInfo
        Component.onCompleted: root.activitiesModel = actInfo.runningActivities()
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var current = actInfo.runningActivities();
            if (JSON.stringify(root.activitiesModel) !== JSON.stringify(current)) {
                root.activitiesModel = current;
            }
        }
    }

    Loader {
        id: layoutLoader
        anchors.fill: parent
        sourceComponent: Plasmoid.configuration.layoutOrientation === 0 ? verticalLayout : horizontalLayout
    }

    // Stacked (Vertical) Layout
    Component {
        id: verticalLayout
        Column {
            id: vertCol
            spacing: Kirigami.Units.smallSpacing
            width: parent.width

            Repeater {
                model: root.activitiesModel
                delegate: activityButtonDelegate
            }
        }
    }

    // Side-by-side (Horizontal) Layout
    Component {
        id: horizontalLayout
        Row {
            id: horizRow
            spacing: Kirigami.Units.smallSpacing
            height: parent.height

            Repeater {
                model: root.activitiesModel
                delegate: activityButtonDelegate
            }
        }
    }

    Component {
        id: activityButtonDelegate
        
        Rectangle {
            id: activityBtn
            
            readonly property string activityId: modelData
            readonly property bool isCurrent: actInfo.currentActivity === activityId
            readonly property color customColor: root.getActivityColor(activityId)
            readonly property bool hasCustomColor: customColor.toString() !== "" && customColor.toString() !== "#000000"

            readonly property bool canExpand: Plasmoid.configuration.buttonShape !== 2 // Circles don't expand to ovals

            // Center vertically in horizontal row, center horizontally in vertical column
            x: (Plasmoid.configuration.layoutOrientation === 0 && parent) ? (parent.width - width) / 2 : 0
            y: (Plasmoid.configuration.layoutOrientation === 1 && parent) ? (parent.height - height) / 2 : 0

            // Width of button depends on layout orientation, shape, and active state
            width: {
                if (Plasmoid.configuration.buttonShape === 2) {
                    // Circle: width always equals height (which is custom buttonHeight)
                    return height;
                }
                // Custom configured base width
                var baseW = Plasmoid.configuration.buttonWidth;
                if (canExpand) {
                    var invert = Plasmoid.configuration.invertSelectionSizing;
                    var ratio = Plasmoid.configuration.sizeRatio;
                    if ((isCurrent && !invert) || (!isCurrent && invert)) {
                        return baseW * ratio; // Expanded state (scaled by custom ratio)
                    }
                }
                return baseW;
            }
            height: Plasmoid.configuration.buttonHeight

            // Shape border radius logic
            radius: {
                if (Plasmoid.configuration.buttonShape === 1 || Plasmoid.configuration.buttonShape === 2) {
                    // Pill or Circle: corner radius is half the height
                    return height / 2;
                } else {
                    // Rectangle: sharp corners
                    return 0;
                }
            }

            // Dynamic color/border states
            color: {
                if (isCurrent) {
                    return hasCustomColor ? customColor : Kirigami.Theme.highlightColor;
                } else {
                    var opacity = Plasmoid.configuration.unselectedOpacity;
                    var baseCol = (hasCustomColor && Plasmoid.configuration.colorUnselected) ? customColor : Kirigami.Theme.textColor;
                    var alphaVal = activityMouseArea.containsMouse ? Math.min(1.0, opacity + 0.1) : opacity;
                    return Qt.rgba(baseCol.r, baseCol.g, baseCol.b, alphaVal);
                }
            }

            border.color: {
                if (isCurrent) {
                    return hasCustomColor ? customColor : Kirigami.Theme.highlightColor;
                } else {
                    var baseCol = (hasCustomColor && Plasmoid.configuration.colorUnselected) ? customColor : Kirigami.Theme.textColor;
                    return Qt.rgba(baseCol.r, baseCol.g, baseCol.b, Math.min(1.0, Plasmoid.configuration.unselectedOpacity * 2));
                }
            }
            border.width: 1

            RowLayout {
                anchors.centerIn: parent
                width: Math.min(parent.width - Kirigami.Units.smallSpacing * 2, implicitWidth)
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    id: btnIcon
                    source: root.getActivityIcon(activityBtn.activityId, index)
                    Layout.preferredWidth: Plasmoid.configuration.showIcons ? Kirigami.Units.iconSizes.small : 0
                    Layout.preferredHeight: Plasmoid.configuration.showIcons ? Kirigami.Units.iconSizes.small : 0
                    visible: Plasmoid.configuration.showIcons
                    color: {
                        if (activityBtn.isCurrent) {
                            return Kirigami.Theme.highlightedTextColor;
                        } else {
                            if (activityBtn.hasCustomColor && Plasmoid.configuration.colorUnselected) {
                                return activityBtn.customColor;
                            } else {
                                return Kirigami.Theme.textColor;
                            }
                        }
                    }
                }

                Label {
                    id: btnLabel
                    text: actInfo.activityName(activityBtn.activityId) || "Unnamed Activity"
                    Layout.fillWidth: Plasmoid.configuration.layoutOrientation === 0
                    visible: Plasmoid.configuration.showNames && Plasmoid.configuration.buttonShape !== 2
                    font.bold: activityBtn.isCurrent
                    color: {
                        if (activityBtn.isCurrent) {
                            return Kirigami.Theme.highlightedTextColor;
                        } else {
                            if (activityBtn.hasCustomColor && Plasmoid.configuration.colorUnselected) {
                                return activityBtn.customColor;
                            } else {
                                return Kirigami.Theme.textColor;
                            }
                        }
                    }
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }
            }

            MouseArea {
                id: activityMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    execSource.run('qdbus org.kde.ActivityManager /ActivityManager/Activities SetCurrentActivity "' + activityBtn.activityId + '"')
                }
            }

            // Smooth width animation on activity change (expansion)
            Behavior on width {
                NumberAnimation {
                    duration: plasmoid.configuration.animationDuration
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation { duration: Kirigami.Units.shortDuration }
            }
        }
    }
}
