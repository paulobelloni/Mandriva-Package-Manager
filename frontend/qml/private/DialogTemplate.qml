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

FocusScope {
    id: dialog_template
    signal clicked(string label)

    property alias title: title_area.text
    property alias body: inner_body.sourceComponent
    property alias buttons: buttons_builder.model

    focus: true

    DialogFrame {
        id: frame
        anchors.fill: parent
    }
    Item {
        id: outer_body
        anchors {
            fill: frame
            margins: frame.border.width
        }
        Rectangle {
            id: title_bg
            width: parent.width
            anchors {
                top: parent.top
                bottom: title_area.bottom
                bottomMargin: -2
            }
            gradient: Gradient {
                GradientStop {
                    position: 1.0
                    color: syspal.light
                }
                GradientStop {
                    position: 0.0
                    color: syspal.dark
                }
            }
        }
        Text {
            id: title_area
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            anchors {
                top: parent.top
                topMargin: 2
            }
            font {
                pointSize: 11
            }
        }
        Loader {
            id: inner_body
            width: parent.width
            anchors {
                top: title_bg.bottom
                topMargin: 5
                bottom: buttons_area.top
            }
        }
        Row {
            id: buttons_area
            spacing: 20
            anchors {
                right: parent.right
                rightMargin: 10
                bottom: parent.bottom
                bottomMargin: 5
            }
            Repeater {
                id: buttons_builder
                Button {
                    width: 90
                    height: 25
                    focus: index == 0? true : false
                    iconLabel: modelData[0]
                    iconSource: modelData[1]
                    onClicked: dialog_template.clicked(iconLabel)
                }
            }
        }
    }
}
