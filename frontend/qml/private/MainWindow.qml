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
import config 1.0 as CFG

Item {
    id: main_window
    Item {
        id: main_left_panel
        anchors {
            top: toolbar_area.bottom
            bottom: parent.bottom
            left:  parent.left
        }

        BorderImage {
            source: config.imagesDir + "panel.png"
            anchors.fill: parent
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
                model: CFG.FilterGroupsModel {
                    Component.onCompleted: {
                        for (var i = 0; i < count; i++) {
                            mpm.currentFilters[get(i).title] = '';
                        }
                    }
                }
                delegate: FilterGroupPanel {
                    id: panel
                    property int panelIndex: index
                    property int panelUtilHeight: mpm.height - main_left_panel.y
                    // panelUtilHeight - is an answer to a binding loop problem that
                    // appears on diretly binding to either filters_are.height or
                    // main_left_panel.height. It seems to be a possible QML bug.

                    Item {
                        id: y_helper
                        onYChanged: {
                            tran.y = y;
                        }
                    }

                    transform: Translate {
                        id: tran
                    }

                    filterGroupName: title
                    panelTitle: qsTranslate("FilterGroupsModel", title)
                    isCurrentPanel: filters_area.currentPanel == index
                    width: filters_area.width
                    height: {
                        if (index < panel_builder.model.count - 1) {
                            var _nextPos = panel_builder.model.get(index + 1).position;
                        }
                        else {
                            _nextPos = panel.panelUtilHeight;
                        }

                        var _y = tran.y == 0? y : tran.y
                        return Math.max((_nextPos * panel.panelUtilHeight) - _y, 0);
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
                        filters[filterGroupName] = markedItem;
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
        x: main_left_panel.width
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
