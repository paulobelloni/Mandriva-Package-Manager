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
import config 1.0 as CFG

Item {
    id: template
    property string filterGroupName
    property bool isMarkedItem: panel.markedItem == model.title

    Row {
        spacing: 4
        Image {
            id: icon_image
            anchors.verticalCenter: item_label.verticalCenter
            width: item_label.paintedHeight
            height: width
            source: config.iconsDir + model.icon
            smooth: true
            asynchronous: true
        }
        Text {
            id: item_label
            text: qsTranslate(template.filterGroupName + "Model", model.title)
            color: isMarkedItem? config._LEFTPANEL_MARKED_FONT_COLOR : config._LEFTPANEL_FONT_COLOR
            style: isMarkedItem? Text.Normal : Text.Raised // shadow
            font {
                pointSize: 10
                bold: true
            }
            states: [
                State {
                    name: "hovering"
                    when: mouse_area.containsMouse && !isMarkedItem
                    PropertyChanges {
                        target: item_label
                        color: syspal.highlight
                        opacity: 1
                    }
                }
            ]

            onPaintedSizeChanged: {
                var _calcW = item_label.paintedWidth +
                            2*filter_list.anchors.leftMargin +
                            item_label.paintedHeight +
                            parent.spacing;
                main_left_panel.width = Math.max(main_left_panel.width, _calcW);
            }
        }
    }

    MouseArea {
        id: mouse_area
        anchors.fill: parent
        hoverEnabled: true
        onEntered: forceActiveFocus()
        onPressed: {
            if (!isMarkedItem) {
                panel.markedItem = model.title;
                ListView.view.highlightItem.visible = true;
                ListView.view.highlightItem.y = template.y;
            }
            else {
                panel.markedItem = "";
                ListView.view.highlightItem.visible = false;
            }
        }
    }
}
