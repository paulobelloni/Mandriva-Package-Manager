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
        width: ListView.view.width
        height: childrenRect.height
        Row {
            spacing: 4
            Image {
                anchors.verticalCenter: item_label.verticalCenter
                width: template.height
                height: width
                source: config.iconsDir + model.icon
            }
            Text {
                id: item_label
                text: model.title
                color: config._LEFTPANEL_FONT_COLOR
                style: Text.Raised // shadow
                font {
                    pointSize: 10
                    bold: true
                }
                states: [
                    State {
                        name: "hovering"
                        when: mouse_area.containsMouse
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
            onClicked: {
                if (panel.markedItem !== model.title) {
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
