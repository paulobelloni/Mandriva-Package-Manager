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

VisualDataModel {
    id: item
    property string filterGroupName
    model: XmlListModel {
         source: config.configDir + item.filterGroupName + "Model.xml"
         query: "/mpm/model/" + item.filterGroupName.toLowerCase() + "/item"

         XmlRole { name: "title"; query: "title/string()" }
         XmlRole { name: "icon"; query: "icon/string()" }
    }
    delegate: Item {
        id: template
        property bool isMarkedItem: panel.markedItem == model.title

        width: ListView.view.width
        height: childrenRect.height
        Row {
            spacing: 4
            Image {
                anchors.verticalCenter: item_label.verticalCenter
                width: template.height
                height: width
                source: config.iconsDir + model.icon
                smooth: true
                asynchronous: true
            }
            Text {
                id: item_label
                text: model.title
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
            }
        }
        MouseArea {
            id: mouse_area
            anchors.fill: parent
            hoverEnabled: true
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
}
