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

Item {
    property alias text:  button.text
    property alias color: foreground.color
    property alias fgOpacity: foreground.opacity
    property alias hover: button.hover
    property alias iconSource: button.iconSource
    property alias iconWidth: button.iconWidth
    property alias iconHeight: button.iconHeight

    Button {
        id: button
        anchors.fill: parent
    }

    Rectangle {
        id: foreground
        anchors {
            fill: parent
            margins: 2
        }
        opacity: 0.3
        color: "transparent"
    }
}
