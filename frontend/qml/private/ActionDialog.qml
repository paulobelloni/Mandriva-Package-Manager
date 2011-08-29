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
    id: action_dialog
    property string executeLabel: ""

    function clearStatus() {
        actionMgr.cancelAction();
        actionMgr.actionsAllowed = true;
    }

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
    onClicked: {
        if (label == action_dialog.executeLabel) {
            if (!actionMgr.executeAction()) {
                dialog.showIt("AuthorizationDialog");
                action_dialog.clearStatus();
                return;
            }
        }
        else {
            action_dialog.clearStatus();
        }

        dialog.hide();
    }
}
