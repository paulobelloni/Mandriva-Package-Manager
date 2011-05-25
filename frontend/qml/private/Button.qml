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
import components.qtdesktop.components 1.0 as QDESK

QDESK.Button {
    id: button
    property int fontPixelSize: 10
    property bool hover: containsMouse
    property variant style: Text.Normal

    background: QDESK.QStyleItem {
        id: styleitem
        anchors.fill: parent
        elementType: "button"
        sunken: pressed
        raised: !pressed
        hover: button.hover
        text: iconSource === "" ? button.text : ""  // PBelloni - bugfix
        focus: button.focus
        hint: button.hint
        activeControl: focus ? "default" : ""
        Connections{
            target: button
            onToolTipTriggered: styleitem.showTip()
        }
        function showTip(){
            showToolTip(tooltip);
        }
    }
    label: Item {
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 4
            Image {
                visible: button.iconSource !== ""; // PBelloni - bugfix
                source: button.iconSource
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.Stretch //mm Image should shrink if button is too small, depends on QTBUG-14957
            }
            Text {
                id: text
                color: textColor
                anchors.verticalCenter: parent.verticalCenter
                text: button.text
                font.pixelSize: button.fontPixelSize
                style: button.style
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}

