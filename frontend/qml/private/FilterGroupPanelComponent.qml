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

LayoutItem {
    property alias contentHeight: filter_list.contentHeight
    property alias filterCount: filter_list.count
    property alias filterGroupName: filter_list.filterGroupName

    clip: true

    Item {
        anchors.fill: parent
        BorderImage {
            id: toolbar
            source: config.imagesDir + "rail.png"
            width: parent.width
            height: config._LEFTPANEL_TOOLBAR_HEIGHT
            Text {
                id: title
                height: font.pointSize + 4 // 4 for bold
                text: panel.panelTitle
                color: config._LEFTPANEL_TITLE_FONT_COLOR
                font {
                    italic: true
                    bold: true
                }
                anchors {
                    centerIn: parent
                }
            }

            Row {
                id: tool_buttons
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 4
                }
                spacing: 0
                height: parent.height * 0.7
                Button {
                    id: close
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    enabled: mpm.enableLeftPanelCustomization
                    width: height
                    height: parent.height
                    iconSource: config._THEME_ICONS + config._CLOSE_ICON
                    iconHeight: height * 0.6
                    onClicked: {
                        panel.closePanel();
                    }
                }
            }

//            MouseArea {
//                id: toolbar_mouse_area
//                anchors.fill: parent
//                enabled: panel.panelIndex > 0
//                drag {
//                    target: y_helper
//                    axis: Drag.YAxis
//                    minimumY: -200//left_panel.y
//                    maximumY: left_panel.height - config._LEFTPANEL_TOOLBAR_HEIGHT
//                }
//            }
        }

        FilterGroupList {
            id: filter_list
            anchors {
                left: parent.left
                leftMargin: 10
                right: parent.right
                top: toolbar.bottom
                topMargin: 10
                bottom: parent.bottom
            }
        }
    }
}
