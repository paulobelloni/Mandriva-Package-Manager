//
// Copyright (C) 2010-2011 Mandriva S.A <http://www.mandriva.com>
// All rights reserved
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., or visit: http://www.gnu.org/.
//
// Author(s): Paulo Belloni <paulo@mandriva.com>
//
//
import QtQuick 1.0
import components 1.0 as QDESK

Item {
    id: main_window
    Item {
        id: main_left_panel
        width: config._LEFTPANEL_WIDTH
        anchors {
            top: menu_area.bottom
            bottom: parent.bottom
            left:  parent.left
        }
        BorderImage {
            source: config.imagesDir + "panel-2.png"
            anchors.fill: parent
        }
        Column {
            id: filters_area
            property int currentPanel: 0
            property real _availableHeight: _calcAvailableHeight()
            property real expandedHeight: _availableHeight * 0.6
            property real contractedHeight: _availableHeight * 0.2
            function _childAt(child) {
                return children[child].children[0];
            }
            function _calcAvailableHeight() {
                return height - (children.length - 1)*spacing;
            }
            function recalculateChildrenHeight() {
                if (_availableHeight > 0)
                    _calcChildrenHeight(0, _availableHeight);
            }
            function _calcChildrenHeight(child, available) {
                function __treatCurrentPanel(child) {
                    _childAt(child).activeHeight = expandedHeight;
                    _childAt(child).inactiveHeight = contractedHeight;
                    return _childAt(child).isCurrentPanel
                            ? _childAt(child).activeHeight
                            : _childAt(child).inactiveHeight;
                }
                if (child >= children.length - 1) {   // 1 is to remove Repeater itself
                    return available;
                }
                if (available >= _childAt(child).preferredHeight) {
                    available -= _childAt(child).preferredHeight;
                    _childAt(child).activeHeight =
                            _childAt(child).inactiveHeight =
                            _childAt(child).preferredHeight;
                }
                else {
                    available -= __treatCurrentPanel(child);
                    if (available < 0) {
                        return available;
                    }
                }
                var rest = _calcChildrenHeight(child + 1, available);
                if (rest < 0) {
                    rest += _childAt(child).preferredHeight
                            - __treatCurrentPanel(child);
                }
                else if (rest > 0) {
                    var share = Math.floor(rest / (child + 1));
                    _childAt(child).activeHeight += share;
                    _childAt(child).inactiveHeight += share;
                    rest -= share;
                }
                return rest;
            }
            width: parent.width
            anchors {
                top: parent.top
                topMargin: 10
                bottom: parent.bottom
            }
            spacing: 10
            Repeater {
                id: panel_builder
                model: XmlListModel {
                    source: config.configDir + "FilterGroupsModel.xml";
                    query: "/mpm/model/filtergroups/item"

                    XmlRole { name: "title"; query: "title/string()" }
                }
                delegate: Item {
                    property alias contentHeight: panel.contentHeight       //got segfault by directly accessing panel
                    property alias needsContraction: panel.needsContraction //so, doing alias to get indirect access
                    width: filters_area.width
                    height: panel.height
                    FilterGroupPanel {
                        id: panel
                        panelTitle: modelData
                        isCurrentPanel: filters_area.currentPanel == index
                        width: filters_area.width
                        height: isCurrentPanel ? activeHeight : inactiveHeight
                        MouseArea {
                            z: parent.z - 1
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                if (!panel.isCurrentPanel) {
                                    filters_area.currentPanel = index;
                                    filters_area.recalculateChildrenHeight();
                                }
                            }
                        }
                        onMarkedItemChanged: {
                            //FIXME: Setting hardcoded due to QML limitations to broadcast
                            //javascript hash changes (no bindings get informed). The workaround
                            //(using temp) is bad, so lets keep hardcorded till we set a python
                            //helper function (or class).

                            if (panelTitle === 'Category')
                                mpm.currentCategory = markedItem;
                            else if (panelTitle === 'Sort')
                                mpm.currentSort = markedItem;
                            else if (panelTitle === 'Source')
                                mpm.currentSource = markedItem;
                            else {
                                console.log("ERROR: Unexpected panel: " + panelTitle);
                                return;
                            }

                            mpm.reloadData();
                        }
                    }
                    BorderImage {
                        visible: index < panel_builder.model.count - 1
                        x: width/2
                        y: (parent.height + parent.contentHeight)/2 + filters_area.spacing*2
                        width: filters_area.width/2
                        height: 2
                        opacity: 0.3
                        source: config.imagesDir + "track.png"
                    }
                }
            }
            onHeightChanged: {
                recalculateChildrenHeight();
            }
        }
// This to help decide where to put the status buttons
//        Column {
//            id: status_filter
//            spacing: 8
//            anchors {
//                horizontalCenter: parent.horizontalCenter
//                bottom: parent.bottom
//                bottomMargin: 4
//            }
//            BorderImage {
//                width: main_left_panel.width/2
//                height: 2
//                opacity: 0.3
//                source: config.imagesDir + "track.png"
//                anchors {
//                    horizontalCenter: parent.horizontalCenter
//                }
//            }
//            Text {
//                text: "Status"
//                height: font.pointSize + 4 // 4 for bold
//                color: config._LEFTPANEL_FONT_COLOR
//                font {
//                    italic: true
//                    pointSize: 11
//                }
//                anchors {
//                    horizontalCenter: parent.horizontalCenter
//                }
//            }
//            StatusFilter {
//                anchors {
//                    horizontalCenter: parent.horizontalCenter
//                }
//            }
//        }
    }
    TargetPanel {
        id: target_panel
        anchors {
            top: menu_area.bottom
            bottom: status_area.top
            left: separator.right
            right: parent.right
        }
    }
    StatusArea {
        id: status_area
        height: config._STATUS_AREA_HEIGHT
        anchors {
            left: separator.right
            right: parent.right
            bottom: parent.bottom
        }
    }
    Separator {
        id: separator
        x: config._LEFTPANEL_WIDTH
        width: config._SEPARATOR_WIDTH
        anchors {
            top: menu_area.bottom
            bottom: parent.bottom
        }
    }
    Item {
        id: menu_area
        width: parent.width
        height: config._TOOLBAR_HEIGHT
        ToolBar {
            id: main_menu
            anchors.fill: parent
            Row {
                id: navigation_buttons
                spacing: 0
                anchors.verticalCenter: parent.verticalCenter
                QDESK.ToolButton{
                    id: back
                    property Item targetPanel
                    enabled: false
                    opacity: enabled? 1 : 0.2
                    width: height
                    height: main_menu.height * 0.9
                    text: "Back"
                    iconSource: config._THEME_ICONS + config._PREVIOUS_ICON
                    states: [
                        State {
                            name: "on_details_visible"
                            when: detail_panel.visible && !manage_panel.visible
                            PropertyChanges {
                                target: back
                                targetPanel: detail_panel
                                enabled: true
                            }
                        },
                        State {
                            name: "on_manage_visible"
                            when: manage_panel.visible
                            PropertyChanges {
                                target: back
                                targetPanel: manage_panel
                                enabled: true
                            }
                        }
                    ]
                    onClicked: {
                        next.targetPanel = targetPanel;
                        targetPanel.visible = false;
                        next.enabled = true;
                    }
                }
                QDESK.ToolButton{
                    id: next
                    property Item targetPanel
                    enabled: false
                    opacity: enabled? 1 : 0.3
                    width: height
                    height: back.height
                    text: "Next"
                    iconSource: config._THEME_ICONS + config._NEXT_ICON
                    onClicked: {
                        targetPanel.visible = true;
                        next.enabled = false;
                    }
                }
                Component.onCompleted: {
                    x = (config._LEFTPANEL_WIDTH - width)/2;
                }
            }
            Item {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: navigation_buttons.right
                    right: search_box.left
                }
                BorderImage {
                    anchors.centerIn: parent
                    anchors.verticalCenter: parent.verticalCenter
                    width: config._TOOLBARITEMS_WITH
                    height: parent.height * 0.8
                    source: config.imagesDir + "rail.png"
                    ToolBarItems {
                        id: main_menu_items
                        anchors {
                            fill: parent
                            leftMargin: 2
                            rightMargin: 2
                        }
                    }
                }
            }
            SearchBox {
                id: search_box
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 5
                }
                width: config._SEARCHBOX_WITH
                height: main_menu_items.height

                onTextChanged: {
                    controllerData.pattern = text;
                }
            }
        }
    }
}
