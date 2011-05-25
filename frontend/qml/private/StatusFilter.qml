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

Column {
    id: status_buttons

    spacing: 4

    function setStatus() {
        mam.statusFilterNotInstalledEnabled = not_installed.enabled;
        mam.statusFilterUpgradeEnabled = upgrade.enabled;
        mam.statusFilterInstallingEnabled = installing.enabled;
        mam.statusFilterInstalledEnabled = installed.enabled;

        mam.currentStatus = ""
        if (not_installed.enabled) {
            mam.currentStatus += not_installed.status + "|";
        }
        if (upgrade.enabled) {
            mam.currentStatus += upgrade.status + "|";
        }
        if (installing.enabled) {
            mam.currentStatus += installing.status + "|";
        }
        if (installed.enabled) {
            mam.currentStatus += installed.status + "|";
        }
    }

    StatusFilterButton {
        id: not_installed
        statusName: "Not-installed"
        status: 'N'
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Row {
        spacing: 4
        anchors.horizontalCenter: parent.horizontalCenter

        StatusFilterButton {
            id: upgrade
            statusName: "Upgrade"
            status: 'U'
        }

        StatusFilterButton {
            id: installing
            statusName: "Installing"
            status: 'G'
        }

        StatusFilterButton {
            id: installed
            statusName: "Installed"
            status: 'I'
        }
    }
}
