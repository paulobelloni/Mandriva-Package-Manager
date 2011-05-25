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
//import components.qtdesktop.components 1.0 as QDESK

Rectangle {
    TargetList {
        id: target_list
        anchors {
            top: border.bottom
            bottom: parent.bottom
            bottomMargin: 0
            left: parent.left
            right: scrollbar.left
        }
    }

    FakeScrollbar {
        id: scrollbar
        anchors {
            top: target_list.top
            bottom: target_list.bottom
            right: parent.right
        }
        visible: target_list.visibleArea.heightRatio < 1.0
        maximumValue: target_list.count
        onHandlePosChanged: {
            if (mam.scrollbarFrozen)
                return;

            if (pos < _pathSize) {
                target_list.positionViewAtIndex(pos * _pathRatio, ListView.End);
            }
            else {
                target_list.positionViewAtIndex(maximumValue - 1, ListView.Beginning);
            }
        }
    }

    Rectangle {
        id: border
        width: parent.width
        height: 2
        anchors {
            top: parent.top
        }
        color: config._STATUSBAR_BACKGROUND_FINAL_COLOR
    }

// qt-components-desktop is crashing if we use scrollbar
// till we find out what is the issue (seems to be something related to
// the libqt declarative built on cooker) we use FakeScrollbar
//    QDESK.ScrollBar {
//        id: scrollbar
//        anchors {
//            top: parent.top
//            bottom: parent.bottom
//            right: parent.right
//        }
//        orientation: Qt.Vertical
//        visible: target_list.visibleArea.heightRatio < 1.0
//        maximumValue: target_list.count
//        minimumValue: 0
//        onValueChanged: {
//            value = Math.max(0, Math.floor(value));
//            target_list.positionViewAtIndex(value, ListView.Center);
//        }
//    }
}
