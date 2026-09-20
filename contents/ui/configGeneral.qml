import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQuickControls
import org.kde.taskmanager as TaskManager
import org.kde.iconthemes as KIconThemes

KCM.SimpleKCM {
    id: root

    property alias cfg_showNames: showNamesCheckbox.checked
    property alias cfg_showIcons: showIconsCheckbox.checked
    property alias cfg_layoutOrientation: layoutOrientationComboBox.currentIndex
    property alias cfg_buttonShape: buttonShapeComboBox.currentIndex
    property alias cfg_cornerRadius: cornerRadiusSpinBox.value
    property alias cfg_buttonWidth: buttonWidthSpinBox.value
    property alias cfg_buttonHeight: buttonHeightSpinBox.value
    property alias cfg_colorUnselected: colorUnselectedCheckbox.checked
    property alias cfg_unselectedOpacity: unselectedOpacitySlider.value
    property alias cfg_invertSelectionSizing: invertSelectionSizingCheckbox.checked
    property alias cfg_sizeRatio: sizeRatioSlider.value
    property alias cfg_animationDuration: animationDurationSpinBox.value
    property string cfg_activityColors
    property string cfg_activityIcons

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

    // Helper functions for custom activity colors
    function getActivityColor(id) {
        try {
            var colors = JSON.parse(cfg_activityColors);
            return colors[id] || "";
        } catch (e) {
            return "";
        }
    }

    function updateActivityColor(id, colorHex) {
        var colors = {};
        try {
            colors = JSON.parse(cfg_activityColors);
        } catch (e) {}
        colors[id] = colorHex;
        cfg_activityColors = JSON.stringify(colors);
    }

    function resetActivityColor(id) {
        var colors = {};
        try {
            colors = JSON.parse(cfg_activityColors);
        } catch (e) {}
        delete colors[id];
        cfg_activityColors = JSON.stringify(colors);
    }

    // Helper functions for custom activity icons
    function getActivityIcon(id, index) {
        try {
            var icons = JSON.parse(cfg_activityIcons);
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

    function updateActivityIcon(id, iconName) {
        var icons = {};
        try {
            icons = JSON.parse(cfg_activityIcons);
        } catch (e) {}
        icons[id] = iconName;
        cfg_activityIcons = JSON.stringify(icons);
    }

    function resetActivityIcon(id) {
        var icons = {};
        try {
            icons = JSON.parse(cfg_activityIcons);
        } catch (e) {}
        delete icons[id];
        cfg_activityIcons = JSON.stringify(icons);
    }

    // IconDialog instance for picking custom icons
    KIconThemes.IconDialog {
        id: iconDialog
        property string targetActivityId: ""
        onIconNameChanged: iconName => {
            if (targetActivityId !== "") {
                root.updateActivityIcon(targetActivityId, iconName || "");
            }
        }
    }

    Kirigami.FormLayout {
        CheckBox {
            id: showNamesCheckbox
            Kirigami.FormData.label: "Display Name:"
            text: "Show activity names in buttons"
        }

        CheckBox {
            id: showIconsCheckbox
            Kirigami.FormData.label: "Display Icon:"
            text: "Show icons in buttons"
        }

        CheckBox {
            id: colorUnselectedCheckbox
            Kirigami.FormData.label: "Color Unselected:"
            text: "Apply color to unselected buttons"
        }

        RowLayout {
            Kirigami.FormData.label: "Unselected Opacity:"
            enabled: colorUnselectedCheckbox.checked
            spacing: Kirigami.Units.smallSpacing

            Slider {
                id: unselectedOpacitySlider
                from: 0.0
                to: 1.0
                stepSize: 0.05
                Layout.fillWidth: true
            }

            Label {
                text: Math.round(unselectedOpacitySlider.value * 100) + "%"
                Layout.preferredWidth: Kirigami.Units.gridUnit * 2
            }
        }

        CheckBox {
            id: invertSelectionSizingCheckbox
            Kirigami.FormData.label: "Invert Selection Sizing:"
            text: "Make unselected buttons expand instead of the selected one"
        }

        RowLayout {
            Kirigami.FormData.label: "Sizing Scale Ratio:"
            spacing: Kirigami.Units.smallSpacing

            Slider {
                id: sizeRatioSlider
                from: 1.0
                to: 2.0
                stepSize: 0.05
                Layout.fillWidth: true
            }

            Label {
                text: Math.round(sizeRatioSlider.value * 100) + "%"
                Layout.preferredWidth: Kirigami.Units.gridUnit * 2
            }
        }

        ComboBox {
            id: layoutOrientationComboBox
            Kirigami.FormData.label: "Orientation:"
            model: ["Stacked (Vertical)", "Side-by-side (Horizontal)"]
        }

        ComboBox {
            id: buttonShapeComboBox
            Kirigami.FormData.label: "Button Shape:"
            model: ["Rectangle", "Pill", "Circle", "Rounded Rectangle"]
        }

        SpinBox {
            id: cornerRadiusSpinBox
            Kirigami.FormData.label: "Corner Radius:"
            from: 1
            to: 100
            stepSize: 1
            visible: buttonShapeComboBox.currentIndex === 3
        }

        SpinBox {
            id: buttonWidthSpinBox
            Kirigami.FormData.label: "Button Width:"
            from: 20
            to: 500
            stepSize: 5
        }

        SpinBox {
            id: buttonHeightSpinBox
            Kirigami.FormData.label: "Button Height:"
            from: 10
            to: 200
            stepSize: 2
        }

        SpinBox {
            id: animationDurationSpinBox
            Kirigami.FormData.label: "Resize Animation (ms):"
            from: 0
            to: 5000
            stepSize: 50
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(1, 1, 1, 0.1)
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Custom Activity Styles"
        }

        ColumnLayout {
            Kirigami.FormData.isSection: true
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Repeater {
                model: root.activitiesModel

                delegate: RowLayout {
                spacing: Kirigami.Units.gridUnit * 0.5
                
                Kirigami.Icon {
                    source: root.getActivityIcon(modelData, index)
                    Layout.preferredWidth: Kirigami.Units.iconSizes.small
                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                }
                
                Label {
                    text: actInfo.activityName(modelData) || "Unnamed Activity"
                    Layout.fillWidth: true
                    font.bold: true
                }
                
                // Color customization group
                RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    
                    KQuickControls.ColorButton {
                        id: colorPicker
                        ToolTip.text: "Change button color"
                        ToolTip.visible: hovered
                        
                        Component.onCompleted: {
                            var c = root.getActivityColor(modelData);
                            color = c ? c : "#ffffff";
                        }
                        
                        onColorChanged: {
                            root.updateActivityColor(modelData, color.toString());
                        }
                    }
                    
                    Button {
                        text: "Reset Color"
                        display: AbstractButton.IconOnly
                        icon.name: "edit-clear"
                        ToolTip.text: "Reset to default theme color"
                        ToolTip.visible: hovered
                        onClicked: {
                            root.resetActivityColor(modelData);
                            colorPicker.color = "#ffffff";
                        }
                    }
                }

                // Separator between color and icon picker
                Rectangle {
                    width: 1
                    height: Kirigami.Units.gridUnit
                    color: Qt.rgba(1, 1, 1, 0.15)
                }

                // Icon customization group
                RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    
                    Button {
                        id: iconSelectBtn
                        ToolTip.text: "Change button icon"
                        ToolTip.visible: hovered
                        
                        contentItem: Kirigami.Icon {
                            source: root.getActivityIcon(modelData, index)
                            implicitWidth: Kirigami.Units.iconSizes.small
                            implicitHeight: Kirigami.Units.iconSizes.small
                        }
                        
                        onClicked: {
                            iconDialog.targetActivityId = modelData;
                            iconDialog.open();
                        }
                    }
                    
                    Button {
                        display: AbstractButton.IconOnly
                        icon.name: "edit-clear"
                        ToolTip.text: "Reset to default activity icon"
                        ToolTip.visible: hovered
                        onClicked: {
                            root.resetActivityIcon(modelData);
                            // Force refresh of the icon button display
                            iconSelectBtn.contentItem.source = root.getActivityIcon(modelData, index);
                        }
                    }
                }
            }
            }
        }
    }
}
