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

ListView {
    id: list
    spacing: 0
    highlightMoveSpeed: 500
    focus: true
    interactive: false
    orientation: ListView.Horizontal
    highlight: Item {
        Button {
            anchors.centerIn: parent
            hover: true
            width: parent.width
            height: parent.height - 4
        }
    }
    model: XmlListModel {
        id: xml_model
        source: config.configDir + "MainBarModel.xml"
        query: "/mpm/model/toolbar/item"

        XmlRole { name: "title"; query: "title/string()" }
    }
    delegate: Item {
        id: toolbar_item
        property string title: model.title
        width: list.width/list.count
        height: list.height
        Text {
            id: button_title
            anchors.centerIn: parent
            text: model.title
            font.pointSize: 11
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                forceActiveFocus();
                if (list.currentIndex != index) {
                    list.currentIndex = index;
                }
            }
        }
    }
    Keys.onLeftPressed: {
        decrementCurrentIndex()
    }
    Keys.onRightPressed: {
        incrementCurrentIndex()
    }
}
