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
            top: toolbar_area.bottom
            bottom: parent.bottom
            left:  parent.left
        }

        Rectangle {
            anchors.fill: parent
            color: config._LEFTPANEL_BACKGROUND_COLOR
        }

        Column {
            id: filters_area
            property int currentPanel: 0

            anchors {
                top: parent.top
                topMargin: 0
                bottom: parent.bottom
            }
            width: parent.width
            Repeater {
                id: panel_builder
                model: XmlListModel {
                    source: config.configDir + "FilterGroupsModel.xml";
                    query: "/mpm/model/filtergroups/item"

                    XmlRole { name: "title"; query: "title/string()" }
                    XmlRole { name: "position"; query: "position/number()" }

                    onStatusChanged: {
                        if (status == XmlListModel.Ready) {
                            for (var i = 0; i < count; i++) {
                                mpm.currentFilters[get(i).title] = '';
                            }
                        }
                    }
                }
                delegate: FilterGroupPanel {
                    id: panel
                    property int panelIndex: index

                    Item {
                        id: y_helper
                        onYChanged: {
                            tran.y = y;
                        }
                    }

                    transform: Translate {
                        id: tran
                    }

                    panelTitle: title
                    isCurrentPanel: filters_area.currentPanel == index
                    width: filters_area.width
                    height: {
                        if (index < panel_builder.model.count - 1) {
                            var _nextPos = panel_builder.model.get(index + 1).position;
                        }
                        else {
                            _nextPos = main_left_panel.height;
                        }

                        var _y = tran.y == 0? y : tran.y
                        return Math.max((_nextPos * main_left_panel.height) - _y, 0);
                    }

                    MouseArea {
                        z: parent.z - 1
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            if (!panel.isCurrentPanel) {
                                filters_area.currentPanel = index;
                            }
                        }
                    }
                    onMarkedItemChanged: {
                        var filters = mpm.currentFilters;  // We need this 'cause QML does not bind array members
                        filters[panelTitle] = markedItem;
                        mpm.currentFilters = filters;
                        mpm.reloadData();
                    }
                }
            }
        }
    }
    TargetPanel {
        id: target_panel
        anchors {
            top: toolbar_area.bottom
            bottom: parent.bottom
            left: separator.right
            right: parent.right
        }
    }
    Separator {
        id: separator
        x: config._LEFTPANEL_WIDTH
        width: config._SEPARATOR_WIDTH
        anchors {
            top: toolbar_area.bottom
            bottom: parent.bottom
        }
    }
    MainToolbar {
        id: toolbar_area
        width: parent.width
        height: config._TOOLBAR_HEIGHT
    }
}
