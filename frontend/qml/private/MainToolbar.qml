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

QDESK.ToolBar {
    id: toolbar
    Row {
        id: navigation_buttons
        spacing: 0
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height * 0.8
        QDESK.ToolButton {
            id: back
            property Item targetPanel
            enabled: target_panel.itemMarked //FIXME - This is temporary solution.
            opacity: enabled? 1 : 0.2
            width: height
            height: parent.height
            text: "Back"
            iconSource: config._THEME_ICONS + config._PREVIOUS_ICON
//            states: [
//                State {
//                    name: "on_details_visible"
//                    when: detail_panel.visible && !manage_panel.visible
//                    PropertyChanges {
//                        target: back
//                        targetPanel: detail_panel
//                        enabled: true
//                    }
//                },
//                State {
//                    name: "on_manage_visible"
//                    when: manage_panel.visible
//                    PropertyChanges {
//                        target: back
//                        targetPanel: manage_panel
//                        enabled: true
//                    }
//                }
//            ]
            onClicked: {
                target_panel.itemMarked = false;  //FIXME - This is temporary feature.
            }
        }
        QDESK.ToolButton {
            id: next
            property Item targetPanel
            enabled: false
            opacity: enabled? 1 : 0.3
            width: height
            height: parent.height
            text: "Next"
            iconSource: config._THEME_ICONS + config._NEXT_ICON
            onClicked: {
                targetPanel.visible = true;
                next.enabled = false;
            }
        }
        Component.onCompleted: {
            x = (main_left_panel.width - width)/2;
        }
    }
    Item {
        id: separator_place_holder
        Component.onCompleted: {
            x = main_left_panel.width;
        }
    }
    SearchBox {
        id: search_box
        anchors {
            verticalCenter: parent.verticalCenter
            left: separator_place_holder.right
            right: buttons.left
            rightMargin: 10
        }
        height: navigation_buttons.height

        onTextChanged: {
            controllerData.pattern = text;
        }
    }
    Row {
        id: buttons
        spacing: 2
        height: navigation_buttons.height
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 10
        }
        QDESK.ToolButton {
            id: history
            anchors {
                verticalCenter: parent.verticalCenter
            }
            width: height
            height: parent.height
            text: "History"
            tooltip: text
            iconSource: config._THEME_ICONS + config._HISTORY_ICON
            onClicked: {
                //TODO
            }
        }
        QDESK.ToolButton {
            id: settings
            anchors {
                verticalCenter: parent.verticalCenter
            }
            width: height
            height: navigation_buttons.height
            text: "Settings"
            iconSource: config._THEME_ICONS + config._SETTINGS_ICON
            onClicked: {
                //TODO
            }
        }
    }
}
