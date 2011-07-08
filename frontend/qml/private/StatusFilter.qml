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
        mpm.statusFilterNotInstalledEnabled = not_installed.enabled;
        mpm.statusFilterUpgradableEnabled = upgradable.enabled;
        mpm.statusFilterInProgressEnabled = in_progress.enabled;
        mpm.statusFilterInstalledEnabled = installed.enabled;

        mpm.currentStatus = ""
        if (not_installed.enabled) {
            mpm.currentStatus += "|" + not_installed.status;  //mpm.py expects the initial '|'
        }
        if (upgradable.enabled) {
            mpm.currentStatus += "|" + upgradable.status;
        }
        if (in_progress.enabled) {
            mpm.currentStatus += "|" + in_progress.status;
        }
        if (installed.enabled) {
            mpm.currentStatus += "|" + installed.status;
        }
    }


    Row {
        spacing: 6
        anchors.horizontalCenter: parent.horizontalCenter

        StatusFilterButton {
            id: not_installed
            statusName: "Not-installed"
            status: 'N'
        }

        StatusFilterButton {
            id: upgradable
            statusName: "Upgradable"
            status: 'U'
        }

        StatusFilterButton {
            id: in_progress
            statusName: "InProgress"
            status: 'G'
        }

        StatusFilterButton {
            id: installed
            statusName: "Installed"
            status: 'I'
        }
    }
}
