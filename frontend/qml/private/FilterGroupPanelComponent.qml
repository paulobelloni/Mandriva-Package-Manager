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
    property alias listHeight: filter_list.height
    property alias filterCount: filter_list.count

    clip: true
    BorderImage {
        source: config.imagesDir + "panel.png"
        anchors.fill: parent
    }
//    Rectangle {
//        anchors.fill: parent
//        color: config._LEFTPANEL_BACKGROUND_COLOR
//    }

    Column {
        spacing: 10
        width: panel.width
        BorderImage {//QDESK.QStyleItem {
            id: toolbar
//            elementType: "header"
//            activeControl: itemSort
//            raised: true
//            sunken: itemPressed
//            hover: itemContainsMouse
            source: config.imagesDir + "rail.png"
            width: parent.width
            height: config._LEFTPANEL_TOOLBAR_HEIGHT
            //height: sizeFromContents(title.font.pixelSize, toolbar.fontHeight).height
            Text {
                id: title
                height: font.pointSize + 4 // 4 for bold
                text: panel.panelTitle
                color: config._LEFTPANEL_TITLE_FONT_COLOR
                font {
                    italic: true
                    //pointSize: 11
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
                width: childrenRect.width
                height: parent.height * 0.7
                Button {
                    id: close
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    width: height
                    height: parent.height
                    iconSource: config._THEME_ICONS + config._CLOSE_ICON
                    iconHeight: height * 0.6
                }
            }

//            MouseArea {
//                id: toolbar_mouse_area
//                anchors.fill: parent
//                enabled: panel.panelIndex > 0
//                drag {
//                    target: y_helper
//                    axis: Drag.YAxis
//                    minimumY: -200//main_left_panel.y
//                    maximumY: main_left_panel.height - config._LEFTPANEL_TOOLBAR_HEIGHT
//                }
//            }
        }

        FilterGroupList {
            id: filter_list
            filterGroupName: panel.panelTitle
            height: panel.height
            visible: panel.isCurrentPanel || !panel.needsContraction
            anchors {
                left: parent.left
                leftMargin: 10
                right: parent.right
            }
        }
    }
}
