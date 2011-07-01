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
import "../../js/Store.js" as Store

Item {
    id: main_window
    Row {
        id: main_area
        width: parent.width
        height: parent.height
        Item {
            id: main_panel
            width: parent.width
            height: parent.height

            Item {
                id: left_panel
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
                        property string defaultModelJSON

                        model: CFG.FilterGroupsModel {
                            Component.onCompleted: {
                                for (var i = 0; i < count; i++) {
                                    mpm.currentFilters[get(i).title] = '';
                                }
                                panel_builder.defaultModelJSON = Store.modelTOjson(panel_builder.model);
                                if (mpm.enableLeftPanelCustomization) {
                                    var jsonGetter = function () {
                                        return mpmController.restore_config(config._LEFTPANEL_CONFIG_FILE);
                                    }
                                    Store.restoreModel(panel_builder.model, jsonGetter);
                                }
                            }
                        }
                        delegate: FilterGroupPanel {
                            id: panel
                            property int panelIndex: index
                            property int panelUtilHeight: mpm.height - left_panel.y
                            // panelUtilHeight - is an answer to a binding loop problem that
                            // appears on diretly binding to either filters_are.height or
                            // left_panel.height. It seems to be a possible QML bug.

                            filterGroupName: title
                            panelTitle: qsTranslate("FilterGroupsModel", title)
                            isCurrentPanel: filters_area.currentPanel == index
                            width: filters_area.width
                            height: {
                                if (index < 0) return 0;
                                var _pos = panel_builder.model.get(index).position;
                                var _nextPos = 1;
                                if (index < panel_builder.model.count - 1) {
                                    _nextPos = panel_builder.model.get(index + 1).position;
                                }

                                return (_nextPos - _pos) * panel.panelUtilHeight;
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
                            onClosePanel: {
                                if (mpm.enableLeftPanelCustomization) {
                                    panel_builder.model.remove(index);
                                    var jsonSetter = function (json) {
                                        mpmController.store_config(config._LEFTPANEL_CONFIG_FILE, json);
                                    }
                                    Store.storeModel(panel_builder.model, jsonSetter);
                                }
                            }
                        }
                        onCountChanged: {
                            if (count == 0) {
                                left_panel.width = 0;
                            }
                        }
                    }
                    Connections {
                        target: mpm
                        onRestoreLeftPanel: {
                            var jsonGetter = function () {
                                return panel_builder.defaultModelJSON;
                            }
                            Store.restoreModel(panel_builder.model, jsonGetter);
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
                x: left_panel.width
                width: left_panel.width > 0 ? config._SEPARATOR_WIDTH : 0
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
        SettingsPanel {
            id: settings_panel
            width: parent.width
            height: parent.height
        }

        states: [
            State {
                name: "show_settings"
                PropertyChanges {
                    target: main_area
                    x: -main_panel.width
                }
            }
        ]
    }
}
