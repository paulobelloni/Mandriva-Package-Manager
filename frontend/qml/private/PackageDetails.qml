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

Rectangle {
    id: details
    Item {
        anchors {
            top: parent.top
            topMargin: config._V_MARGIN_DETAILS
            bottom: parent.bottom
            bottomMargin: anchors.topMargin
            left: parent.left
            leftMargin: config._L_MARGIN_DETAILS
            right: parent.right
            rightMargin: config._R_MARGIN_DETAILS
        }
        Item {
            id: left_panel
            width: config._LEFT_PANEL_SIZE
            anchors {
                left: parent.left
                top: parent.top
                topMargin: 0
                bottom: parent.bottom
            }
            Column {
                spacing: 40
                width: parent.width
                //height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    spacing: 4
                    Column {
                        id: category_group
                        spacing: 4
                        Text {
                            text: "Category/Subgroup:"
                            font {
                                bold: true
                            }
                        }
                        Text {
                            text: target_view.currentPackage?  target_view.currentPackage.group : ""
                        }
                    }
                    Column {
                        id: source
                        spacing: 4
                        Text {
                            text: "Source:"
                            font {
                                bold: true
                            }
                        }
                        Text {
                            text: target_view.currentPackage?  target_view.currentPackage.source : ""
                        }
                    }
                    Column {
                        id: media
                        spacing: 4
                        Text {
                            text: "Media:"
                            font {
                                bold: true
                            }
                        }
                        Text {
                            text: target_view.currentPackage? target_view.currentPackage.media : ""
                        }
                    }
                    Column {
                        id: upgraded
                        visible: target_view.currentPackage != undefined &&
                                 target_view.currentPackage.installtime != ""
                        spacing: 4
                        Text {
                            text: "Installed Time:"
                            font {
                                bold: true
                            }
                        }
                        Text {
                            text: target_view.currentPackage? target_view.currentPackage.installtime : ""
                        }
                    }
                    Column {
                        id: current_version
                        spacing: 4
                        Text {
                            text: "Current Version:"
                            font {
                                bold: true
                            }
                        }
                        Text {
                            text: target_view.currentPackage? target_view.currentPackage.version : ""
                        }
                    }
                    Column {
                        id: current_release
                        spacing: 4
                        Text {
                            text: "Current Release:"
                            font {
                                bold: true
                            }
                        }
                        Text {
                            text: target_view.currentPackage? target_view.currentPackage.release : ""
                        }
                    }
                    Column {
                        id: current_arch
                        spacing: 4
                        Text {
                            text: "Architecture:"
                            font {
                                bold: true
                            }
                        }
                        Text {
                            text: target_view.currentPackage? target_view.currentPackage.arch : ""
                        }
                    }
                    Column {
                        id: size
                        property string _value: target_view.currentPackage?
                                    mpmController.pretty_value(target_view.currentPackage.size) : ""
                        property string _valueH: _value != "" ?
                                    mpmController.humanize_size(target_view.currentPackage.size, 1) : ""

                        visible: _value != "" && _value != "0"
                        spacing: 4
                        Text {
                            text: "Size:"
                            font {
                                bold: true
                            }
                        }
                        Text {
                            text: size._value + " bytes (" + size._valueH + ")"
                        }
                    }
//                    Column {
//                        id: developer
//                        spacing: 4
//                        Text {
//                            text: "Developer:"
//                            font {
//                                bold: true
//                            }
//                        }
//                        ExternalLink {
//                            height: 20
//                            url: "www.mandriva.com"
//                        }
//                    }
//                    Column {
//                        id: support
//                        spacing: 4
//                        Text {
//                            text: "Support:"
//                            font {
//                                bold: true
//                            }
//                        }
//                        ExternalLink {
//                            height: 20
//                            url: "www.mandriva.com"
//                        }
//                    }
                }
            }
        }
        Item {
            id: right_panel
            height: childrenRect.height
            anchors {
                top: parent.top
                topMargin: 20
                left: left_panel.right
                leftMargin: 80
                right: parent.right
            }
//            Item {
//                id: right_panel_fullname_banner
//                width: parent.width
//                height: config._APP_FULLNAME_DETAILS_SIZE
//            }
            Column {
                id: description_panel
                width: parent.width
//                anchors {
//                    top: right_panel_fullname_banner.bottom
//                    topMargin: 10
//                }
                states: [
                    State {
                        name: ""
                        when: !details.visible
                    },
                    State {
                        name: "more_clicked"
                        PropertyChanges {
                            target: description_banner
                            height: description_element.paintedHeight
                        }
                        PropertyChanges {
                            target: more_link
                            visible: false
                        }
                    }
                ]
                Flickable {
                    id: description_banner
                    clip: true
                    width: parent.width
                    height: config._DESCRIPTION_DETAILS_HEIGHT - 10
                    Text {
                        id: description_element
                        anchors {
                            fill: parent
                            leftMargin: 4
                        }
                        property string loremIpsum:
                            "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor "+
                            "incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud "+
                            "exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ";
                        property string loremIpsumx4: loremIpsum + loremIpsum + loremIpsum + loremIpsum
                        text: loremIpsumx4
                        wrapMode: Text.Wrap
                        //horizontalAlignment: Text.AlignJustify
                    }
                }
                Text {
                    id: more_link
                    anchors {
                        right: description_banner.right
                    }
                    font {
                        underline: true
                        pixelSize: more_link.height
                    }
                    text: "More..."
                    width: paintedWidth
                    height: 10
                    color: "blue"
                    MouseArea {
                        id: more_link_mousearea
                        anchors.fill: parent
                        onClicked: description_panel.state = "more_clicked"
                    }
                }
            }
        }
    }
//    QDESK.ScrollBar {
//        id: detail_scrollbar
//        anchors {
//            right: parent.right
//            top: parent.top
//            bottom: parent.bottom
//        }
//        value: 0
//        orientation: Qt.Vertical
//        visible: right_panel.height > parent.height
//        maximumValue: (right_panel.height - parent.height) + config._ADJUST_MARGIN_DETAILS
//        minimumValue: 0
//        onValueChanged: right_panel.y = value < 0? 0 : -value
//    }
}
