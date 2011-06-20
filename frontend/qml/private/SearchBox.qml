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
import "custom-qtdesktop" as MDV_QDESK

FocusScope {
    property alias enabled: search_input.enabled
    property alias text: search_input.text

    focus: true
    MDV_QDESK.TextField {
        id: search_input
        anchors.fill: parent
        leftMargin: search_image.width + search_image.anchors.leftMargin + 4
        rightMargin: clear_image.width + clear_image.anchors.rightMargin + 2
        placeholderText: " " + qsTr("type to search")
        font.italic: true
        grabFocusOnHovering: true
    }
    Image {
        id: search_image
        source: config._THEME_ICONS + config._EDIT_FIND_ICON
        width: height
        height: parent.height * 0.6
        smooth: true
        asynchronous: true
        anchors {
            left: parent.left
            leftMargin: 4
            verticalCenter: parent.verticalCenter
        }
    }
    Image {
        id: clear_image
        visible: search_input.text.length > 0
        source: config._THEME_ICONS + config._EDIT_CLEAR_ICON
        width: height
        height: parent.height * 0.6
        smooth: true
        asynchronous: true
        anchors {
            right: parent.right
            rightMargin: 2
            verticalCenter: parent.verticalCenter
        }
        MouseArea {
            enabled: search_input.enabled
            anchors.fill: parent
            onClicked: search_input.text = ""
        }
    }
}
