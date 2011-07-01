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

Rectangle {//QDESK.ToolBar { - Toolbar is causing segfault
    id: toolbar
    color: syspal.window
    QDESK.ToolButton {
        id: back
        width: height
        height: parent.height * 0.8
        text: qsTr("Back")
        iconSource: config._THEME_ICONS + config._PREVIOUS_ICON
        onClicked: {
            main_area.state = "";
        }
    }

    Text {
        id: title
        anchors.fill: parent
        anchors.leftMargin: -back.width
        horizontalAlignment: Text.AlignHCenter
        text: "Settings"
    }
}
