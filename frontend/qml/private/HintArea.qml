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

MouseArea {
    id: hint_area
    property string text: ""
    property int interval: config._DEFAULT_HINT_INTERVAL

    hoverEnabled: true
    onEntered: hint.show(hint_area, mouseX, mouseY, text, interval)
    states: [
        State {
            name: "hover"
            when: hint_area.containsMouse
            PropertyChanges {
                target: mpmController
                cursor: "Qt.PointingHandCursor"
            }
        }
    ]
}
