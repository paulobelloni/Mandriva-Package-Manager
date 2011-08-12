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

FocusScope {
    focus: true
    property alias itemMarked: target_view.itemMarked  //FIXME - should be a temporary solution with Back button

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: forceActiveFocus()
    }
    TargetView {
        id: target_view
        width: parent.width
        anchors {
            top: parent.top
            bottom: panel_separator.top
            bottomMargin: 0
        }
    }
    Row {
        width: parent.width
        anchors {
            top: panel_separator.bottom
            bottom: status_area.top
        }
        PackageDetails {
            id: details_area
            visible: target_view.itemSelected
            width: parent.width
            height: parent.height
        }
        QDESK.TextArea {
            id: output_area
            width: parent.width
            height: parent.height
            frame: true
            readOnly: true
            wrapMode: TextEdit.NoWrap
            text: qsTr("Under construction")
        }
    }
    Rectangle {
        anchors.fill: panel_separator
        gradient: Gradient {
            GradientStop {
                position: 1.0
                color: config._STATUSBAR_BACKGROUND_INITIAL_COLOR
            }
            GradientStop {
                position: 0.0
                color: config._STATUSBAR_BACKGROUND_FINAL_COLOR
            }
        }
    }
    StatusArea {
        id: status_area
        width: parent.width
        height: config._STATUS_AREA_HEIGHT
        anchors {
            bottom: parent.bottom
        }
    }
    TargetPanelSeparator {
        id: panel_separator
        width: parent.width
        height: config._TARGET_PANEL_SEPARATOR_HEIGHT
        minimumY: config._LIST_ITEM_HEIGHT + target_view.headerHeight +
                  (target_view.hscrollbarVisible? target_view.hscrollbarHeight : 0)
        maximumY: parent.height - height
        Component.onCompleted: {
            y =  parent.height - height
        }
    }

    states: [
        State {
            name: "itemMarked"
            when: target_view.itemMarked && target_view.doubleClicked
            PropertyChanges {
                target: panel_separator
                y: config._LIST_ITEM_HEIGHT + target_view.headerHeight
            }
        }
    ]
}
