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

Flipable {
    id: flipable_view
    property bool flipped: false
    signal finished

    transform: Rotation {
        id: rotation

        origin.x: flipable_view.x + flipable_view.width/2
        origin.y: flipable_view.y + flipable_view.height/2
        axis.x: 0
        axis.y: 1
        axis.z: 0
        angle: 0

        onAngleChanged: {
            if ((flipped && angle == -180) ||
                (!flipped && angle == 0)) {
                flipable_view.finished();
            }
        }
    }

    states: State {
        name: "back"
        when: flipped
        PropertyChanges {
            target: rotation
            angle: -180
        }
    }

    transitions: Transition {
        NumberAnimation {
            target: rotation
            property: "angle"
            duration: 1000
        }
    }
}
