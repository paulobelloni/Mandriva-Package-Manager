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
import  QtQuick 1.0

Item {
//    Row {
//        anchors.bottom: parent.bottom
//        visible: target_list.showItemExpanded && hl.y === target_list.currentItem.y
//        spacing: 4
//        Text {
//            text: 'Version: ' + target_list.currentItem.pkg.version
//            width: paintedWidth
//            height: parent.height
//            horizontalAlignment: Text.AlignLeft
//            verticalAlignment: Text.AlignVCenter
//            color: config._LIST_ITEM_DETAILS_COLOR
//        }
//        Text {
//            text: 'Release: ' + target_list.currentItem.pkg.release
//            width: paintedWidth
//            height: parent.height
//            horizontalAlignment: Text.AlignLeft
//            verticalAlignment: Text.AlignVCenter
//            color: config._LIST_ITEM_DETAILS_COLOR
//        }
//        Text {
//            text: 'Architecture: ' + target_list.currentItem.pkg.arch
//            width: paintedWidth
//            height: parent.height
//            horizontalAlignment: Text.AlignLeft
//            verticalAlignment: Text.AlignVCenter
//            color: config._LIST_ITEM_DETAILS_COLOR
//        }
//        Text {
//            text: 'Category: ' + target_list.currentItem.pkg.category
//            width: paintedWidth
//            height: parent.height
//            horizontalAlignment: Text.AlignLeft
//            verticalAlignment: Text.AlignVCenter
//            color: config._LIST_ITEM_DETAILS_COLOR
//        }
//    }
    Row {
        id: action_buttons
        width: childrenRect.width
        height: parent.height
        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        spacing: 10
        ActionButton {
            id: action
            width: config._ACTION_BUTTON_WIDTH
            height: parent.height * config._ACTION_BUTTON_HEIGHT_RATE
            anchors.verticalCenter: parent.verticalCenter
            fgOpacity: hover ? 0.3 : 0.0

            states: [
                State {
                    name: "install"
                    when: target_list.currentItem.pkg.status === 'N'
                    PropertyChanges {
                        target: action
                        color: "green"
                        text: "INSTALL"
                    }
                },
                State {
                    name: "remove"
                    when: target_list.currentItem.pkg.status === 'I'
                    PropertyChanges {
                        target: action
                        color: "red"
                        text: "REMOVE"
                    }
                },
                State {
                    name: "update"
                    when: target_list.currentItem.pkg.status === 'U'
                    PropertyChanges {
                        target: action
                        color: "orange"
                        text: "UPDATE"
                    }
                }
            ]
        }
        ActionButton {
            width: config._ACTION_BUTTON_WIDTH
            height: parent.height * config._ACTION_BUTTON_HEIGHT_RATE
            anchors.verticalCenter: parent.verticalCenter
            text: "+ INFO"
        }
    }

    states: [
        State {
            name: "expanded"
            when: target_list.showItemExpanded
            PropertyChanges {
                target: hl_body
                y: height
            }
            PropertyChanges {
                target: action_buttons
                anchors.leftMargin: 20
            }
            AnchorChanges {
                target: action_buttons
                anchors.right: undefined
                anchors.left: parent.left
            }
        }
    ]

    transitions: [
        Transition {
            to: "expanded"
            SequentialAnimation {
                NumberAnimation { property: 'y'; duration: 200 }
                AnchorAnimation { duration: 500 }
            }
        },
        Transition {
            from: "expanded"
            SequentialAnimation {
                AnchorAnimation { duration: 500 }
                NumberAnimation { properties: "y"; duration: 200 }
            }
        }
    ]
}
