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

Item {
    id: button
    property int rootedX: 0
    property int rootedY: 0
    property alias enabled: enabled.visible
    property string statusName: ""
    property string status: ""
    signal buttonClicked(int x, int y)

    function getImageSource(type) {
        if (statusName == "")
            return ""
        else
            return config.imagesDir + statusName + "-" + type + ".png"
    }

    height: config._STATUSBUTTON_RADIUS
    width: height
    smooth: true

    Image {
        id: enabled

        smooth: true
        visible: !disabled.visible
        source: getImageSource("enabled")
        anchors.fill: parent
    }

    Image {
        id: disabled

        smooth: true
        source: getImageSource("disabled")
        anchors.fill: parent
    }

    HintArea {
        anchors.fill: parent
        text: "Show " + statusName
        onClicked: {
            disabled.visible = !disabled.visible;
            status_buttons.setStatus();
            mpm.reloadData();
        }
    }
}
