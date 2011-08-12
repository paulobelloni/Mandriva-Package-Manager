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

ActionDialog {
    width: 500
    height: 500

    buttons: [[qsTr("OK"), config._THEME_ICONS + config._DIALOG_OK_ICON]]

    body: ActionDialogBodyTemplate {
        epilogue: qsTr("Problems were found. No action will be taken.")

        RejectionDialogTab {
            id: not_installable
            title: qsTr("Cannot be installed")
            model: actionMgr.notInstallable
        }
        RejectionDialogTab {
            id: not_removable
            title: qsTr("Cannot be removed")
            model: actionMgr.notRemovable
        }
    }
}