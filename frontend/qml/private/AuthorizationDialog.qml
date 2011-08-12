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

DialogTemplate {
    width: 300
    height: 200

    buttons: [[qsTr("OK"), config._THEME_ICONS + config._DIALOG_OK_ICON]]

    title: {
        var _text = '';
        if (actionMgr.type == 'INSTALL') {
            _text += qsTr('Installing');
        }
        else if (actionMgr.type == 'UPGRADE') {
            _text += qsTr('Upgrading');
        }
        else {
            _text += qsTr('Removing');
        }

        _text += " '" + actionMgr.target.name + "'";
        _text += archToWordSize(actionMgr.target.arch) == 32 ?
                    " (32 " + qsTr("bits") + ")" : "";
        return _text;
    }
    body: Item {
        anchors {
            fill: parent
            margins: 5
        }
        Column {
            anchors.centerIn: parent
            width: childrenRect.width
            height: childrenRect.height
            spacing: 10
            Text {
                anchors.horizontalCenter: second.horizontalCenter
                text: qsTr("Authorization failed!")
                font {
                    bold: true
                    pointSize: 12
                }
            }
            Text {
                id: second
                text: qsTr("You need Super User power to proceed.")
                font {
                    bold: true
                    pointSize: 10
                }
            }
        }
    }

    onClicked: {
        dialog.hide();
    }
}
