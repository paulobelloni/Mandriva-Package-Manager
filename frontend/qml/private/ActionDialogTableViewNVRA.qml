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
import "custom-qtdesktop" as MDV_QDESK

ActionDialogTableView {
    id: table_view
    property alias name: name.property
    property alias nameWidth: name.width
    property alias version: version.property
    property alias versionWidth: version.width
    property alias release: release.property
    property alias releaseWidth: release.width
    property alias arch: arch.property
    property alias archWidth: arch.width

    MDV_QDESK.TableColumn {
        id: name
        sortName: "Name"
        caption: qsTr("Name") + "   (" + table_view.count + ")"
        width: table_view.treeWidth -
               (version.width + release.width + arch.width)
    }
    MDV_QDESK.TableColumn {
        id: version
        sortName: "Version"
        caption: qsTr("Version")
        width: 80
    }
    MDV_QDESK.TableColumn {
        id: release
        sortName: "Release"
        caption: qsTr("Release")
        width: 60
    }
    MDV_QDESK.TableColumn {
        id: arch
        sortName: "Arch"
        caption: qsTr("Arch")
        width: 50
    }
}
