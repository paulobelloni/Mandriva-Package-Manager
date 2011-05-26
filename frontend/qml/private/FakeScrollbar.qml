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

//FIXME: We need to sync with Flikable
// This is a very, very simple scrollbar implementation just to serve as a temporary
// workaround till we get the real ScrollBar (from qt-components-desktop) working
// correctly.
Item {
    id: scrollbar
    property int maximumValue: 1
    property double _pathSize: scrollbar.height - handle.height
    property double _pathRatio: _pathSize > 0? maximumValue/_pathSize : 1

    signal handlePosChanged(int pos)

    width: 12
    Rectangle {
        id: handle
        property int _minimumHeight: 15

        height: Math.max(target_list.visibleArea.heightRatio * scrollbar.height, _minimumHeight)
        width: 6
        color: syspal.highlight
        radius: width/2
        anchors.horizontalCenter: parent.horizontalCenter
        MouseArea {
            id: mouse_area
            anchors.fill: parent
            hoverEnabled: true
            drag {
                target: handle
                axis: Drag.YAxis
                minimumY: 0
                maximumY: scrollbar.height - handle.height
            }

        }
        states: [
            State {
                name: "hovering"
                when: mouse_area.containsMouse
                PropertyChanges {
                    target: handle
                    color: "#597b90"
                }
                PropertyChanges {
                    target: mpm
                    scrollbarFrozen: false  // Just to simplify things as this is temporary
                }
            }
        ]
        onYChanged: {
            scrollbar.handlePosChanged(y);
        }

        Connections {
            target: mpm
            onResetView: handle.y = 0;
        }
    }
}
