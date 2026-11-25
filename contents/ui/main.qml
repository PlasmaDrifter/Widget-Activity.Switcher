import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.activities as Activities
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.taskmanager as TaskManager
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    implicitWidth: {
        if (Plasmoid.configuration.layoutOrientation === 0) {
            if (Plasmoid.configuration.buttonShape === 2) {
                return Plasmoid.configuration.buttonHeight + Kirigami.Units.gridUnit;
            }
            return Plasmoid.configuration.buttonWidth * Plasmoid.configuration.sizeRatio + Kirigami.Units.gridUnit;
        }
        var hItem = layoutLoader.item as Item;
        return hItem ? hItem.implicitWidth : Kirigami.Units.gridUnit * 10;
    }
    implicitHeight: {
        if (Plasmoid.configuration.layoutOrientation === 0) {
            var vItem = layoutLoader.item as Item;
            return vItem ? vItem.implicitHeight : Kirigami.Units.gridUnit * 5;
        }
        return Plasmoid.configuration.buttonHeight + Kirigami.Units.gridUnit * 0.5;
    }

    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.minimumWidth: 10
    Layout.minimumHeight: 10
    
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
        // 1. Custom explicitly assigned icons always override
        try {
            var icons = JSON.parse(Plasmoid.configuration.activityIcons);
            if (icons && icons[id] !== undefined && icons[id] !== "") {
                return icons[id];
            }
        } catch (e) {}
        
        // 2. Default Icon Style sets
        var style = Plasmoid.configuration.defaultIconStyle;
        
        if (style === 0 && index >= 0 && index < 9) {
            // Bubbles White (1.svg - 9.svg)
            return Qt.resolvedUrl((index + 1) + ".svg");
        } else if (style === 1 && index >= 0 && index < 9) {
            // Bubbles Black (1.svg - 9.svg)
            return Qt.resolvedUrl("icons/bubbles/black/" + (index + 1) + ".svg");
        } else if (style === 2 && index >= 0 && index < 9) {
            // Arabic White (1.png - 9.png)
            return Qt.resolvedUrl("icons/arabic/white/" + (index + 1) + ".png");
        } else if (style === 3 && index >= 0 && index < 9) {
            // Arabic Black (1.png - 9.png)
            return Qt.resolvedUrl("icons/arabic/black/" + (index + 1) + ".png");
        } else if (style === 4 && index >= 0 && index < 9) {
            // Roman White (I.png - IX.png)
            var roman = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"];
            return Qt.resolvedUrl("icons/roman/white/" + roman[index] + ".png");
        } else if (style === 5 && index >= 0 && index < 9) {
            // Roman Black (I.png - IX.png)
            var roman = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"];
            return Qt.resolvedUrl("icons/roman/black/" + roman[index] + ".png");
        } else if (style === 6) {
            // None - fall through to fallback
        }
        
        // 3. Fallback to system default
        return actInfo.activityIcon(id) || "activities";
    }

    Activities.ActivityModel {
        id: activityController
    }

    property var activitiesModel: []

    function updateActivitiesModel() {
        var current = actInfo.runningActivities();
        if (!current) {
            root.activitiesModel = [];
            return;
        }
        try {
            var order = JSON.parse(Plasmoid.configuration.customSortOrder || "[]");
            if (order && order.length > 0) {
                current.sort(function(a, b) {
                    var idxA = order.indexOf(a);
                    var idxB = order.indexOf(b);
                    if (idxA === -1) idxA = 999;
                    if (idxB === -1) idxB = 999;
                    return idxA - idxB;
                });
            }
        } catch (e) {}
        var processed = (Plasmoid.configuration.reverseOrder ? current.slice().reverse() : current);
        if (JSON.stringify(root.activitiesModel) !== JSON.stringify(processed)) {
            root.activitiesModel = processed;
        }
    }

    Connections {
        target: Plasmoid.configuration
        function onCustomSortOrderChanged() {
            root.updateActivitiesModel();
        }
        function onReverseOrderChanged() {
            root.updateActivitiesModel();
        }
    }

    TaskManager.ActivityInfo {
        id: actInfo
        Component.onCompleted: root.updateActivitiesModel()
        onNumberOfRunningActivitiesChanged: root.updateActivitiesModel()
        onNamesOfRunningActivitiesChanged: root.updateActivitiesModel()
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
            clip: true

            readonly property string activityId: modelData
            readonly property bool isCurrent: actInfo.currentActivity === activityId
            readonly property string customColorStr: root.getActivityColor(activityId)
            readonly property bool hasCustomColor: customColorStr !== ""
            readonly property color customColor: hasCustomColor ? customColorStr : Kirigami.Theme.highlightColor

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
                } else if (Plasmoid.configuration.buttonShape === 3) {
                    // Rounded Rectangle: small curved corners
                    return Plasmoid.configuration.cornerRadius;
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

            Item {
                id: contentContainer

                // Fixed content width to prevent layout recalculation during animation
                width: (btnIcon.visible ? btnIcon.width : 0) + (btnLabel.visible && btnIcon.visible ? Kirigami.Units.smallSpacing : 0) + (btnLabel.visible ? btnLabel.implicitWidth : 0)
                height: parent.height
                
                // Explicit float binding to avoid pixel snapping
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2

                Kirigami.Icon {
                    id: btnIcon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    
                    width: Plasmoid.configuration.showIcons ? Kirigami.Units.iconSizes.small : 0
                    height: Plasmoid.configuration.showIcons ? Kirigami.Units.iconSizes.small : 0
                    source: root.getActivityIcon(activityBtn.activityId, index)
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
                    anchors.left: btnIcon.visible ? btnIcon.right : parent.left
                    anchors.leftMargin: btnIcon.visible ? Kirigami.Units.smallSpacing : 0
                    anchors.verticalCenter: parent.verticalCenter
                    
                    text: actInfo.activityName(activityBtn.activityId) || "Unnamed Activity"
                    visible: Plasmoid.configuration.showNames && Plasmoid.configuration.buttonShape !== 2
                    
                    width: implicitWidth
                    horizontalAlignment: Text.AlignLeft
                    renderType: Text.QtRendering
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
                }
            }
            MouseArea {
                id: activityMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    activityController.setCurrentActivity(activityBtn.activityId, function() {})
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
