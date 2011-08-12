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

FocusScope {
    focus: true
    property alias prologue: prologue.text
    property alias epilogue: epilogue.text
    default property alias tabs : table_area.tabs

    Text {
        id: prologue
        height: text ? paintedHeight : 0
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: 5
        }
    }
    QDESK.TabFrame {
        id: table_area
        property variant currentTab: tabs[current]

        width: parent.width
        anchors {
            top: prologue.bottom
            topMargin: 5
            bottom: epilogue.top
            bottomMargin: 5
        }
        focus: true
        position: "North"
        tabbar: QDESK.TabBar {
            parent: frame
            focus: true
        }
    }
    Text {
        id: epilogue
        height: paintedHeight
        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: 5
        }
    }
}
