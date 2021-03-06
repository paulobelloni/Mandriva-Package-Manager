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
    id: dialog
    objectName: "dialog"

    function _setLayout(component, _visible) {
        panel.source = component? component + ".qml" : "";
        dialog.visible = _visible;
    }

    function showIt(component) {         // 'show' seems to be overriden if used outside QML
        actionMgr.actionsAllowed = false;
        _setLayout(component, true);
        forceActiveFocus();
    }

    function hide() {
        _setLayout(undefined, false);
    }

    focus: true
    visible: false

    Shade {
        id: shade
        anchors.fill: parent
    }

    Loader {
        id: panel
        anchors.centerIn: parent
    }
}
