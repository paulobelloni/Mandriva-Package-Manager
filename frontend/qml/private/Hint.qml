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

//FIXME: fix a bug in the mouse_area's. The mouse coordenates is out of
// sync. We keep getting the last position instead of the current one.
// Maybe it is a QT/QML bug.
Rectangle {
    id: hint
    property alias text: text.text
    property alias interval: timer.interval
    property int refX: 0
    property int refY: 0

    function show(target, pointX, pointY, _text, _interval) {
        pointX = mapFromItem(target, pointX, 0).x;
        pointY = mapFromItem(target, 0, pointY).y;
        hint.refX = mapToItem(main_window, pointX, 0).x;
        hint.refY = mapToItem(main_window, 0, pointY).y;
        hint.text = _text;
        if (_interval != null)
            hint.interval = _interval;
        timer.restart();
        hint.visible = true;
    }

    function hide() {
        hint.refX = hint.refY = 0;
        hint.text = "";
        hint.interval = config._DEFAULT_HINT_INTERVAL;
        hint.visible = false;
    }

    function _calcX() {
        var limitX = main_window.x + main_window.width;
        var _refX = refX - width - config._HINT_HORIZONTAL_GAP;
        if (_refX <= 0) {
            _refX = 8;
        }
        else if (_refX + width > limitX) {
            _refX = limitX - width - 8
        }

        return _refX;
    }

    function _calcY() {
        var limitY = main_window.y + main_window.height;
        var _refY = refY - height - config._HINT_VERTICAL_GAP;
        if (_refY <= 0) {
            _refY = 8;
        }
        else if (_refY + height > limitY) {
            _refY = limitY - height - 8
        }

        return _refY;
    }

    x: _calcX()
    y: _calcY()
    width: childrenRect.width + 8
    height: 16
    visible: false
    radius: 4
    color: Qt.lighter("lightyellow")
    border {
        width: 1
        color: "black"
    }

    Text {
        id: text

        x: 4
        y: 2
        font {
            italic: true
            pointSize: 8
        }
    }

    Timer {
        id: timer

        interval: config._DEFAULT_HINT_INTERVAL
        onTriggered: hide()
    }
}
