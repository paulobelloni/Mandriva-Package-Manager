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

QDESK.Button {
    id: button
    property int iconWidth: iconHeight
    property int iconHeight: height * 0.8
    property bool hover: containsMouse
    property variant style: Text.Normal
    property string iconLabel

    label: Item {
        visible: button.iconSource != ""
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4
            Image {
                source: button.iconSource
                anchors.verticalCenter: button.text? undefined : parent.verticalCenter
                width: button.iconWidth
                height: button.iconHeight
                fillMode: Image.Stretch //mm Image should shrink if button is too small, depends on QTBUG-14957
            }
            Text {
                id: text
                color: textColor
                anchors.verticalCenter: parent.verticalCenter
                text: button.iconLabel
                style: button.style
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}

