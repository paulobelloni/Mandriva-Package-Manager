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

Row {
    spacing: 10
    ActionButton {
        id: upgrade_action
        visible: false
        width: config._ACTION_BUTTON_WIDTH
        height: config._ACTION_BUTTON_HEIGHT
        anchors.verticalCenter: parent.verticalCenter
        fgOpacity: hover ? 0.3 : 0.0
        state: target_view.currentPackage? target_view.currentPackage.status : ""

        states: [
            State {
                name: 'Upgradable'
                PropertyChanges {
                    target: upgrade_action
                    color: config._UPGRADE_BUTTON_BACKGROUND
                    text: qsTr("UPGRADE")
                    visible: true
                    enabled: true
                }
            }
        ]

        onClicked: {
            actionMgr.upgradePackage(target_view.currentPackage);
            dialog.show("ConfirmationDialog");
        }
    }
    ActionButton {
        id: basic_action
        width: config._ACTION_BUTTON_WIDTH
        height: config._ACTION_BUTTON_HEIGHT
        anchors.verticalCenter: parent.verticalCenter
        visible: false
        fgOpacity: hover ? 0.3 : 0.0
        state: target_view.currentPackage? target_view.currentPackage.status : ""

        states: [
            State {
                name: 'Not-Installed'
                PropertyChanges {
                    target: basic_action
                    color: config._INSTALL_BUTTON_BACKGROUND
                    text: qsTr("INSTALL")
                    visible: true
                    enabled: true
                }
            },
            State {
                name: 'Upgradable'
                PropertyChanges {
                    target: basic_action
                    color: config._REMOVE_BUTTON_BACKGROUND
                    text: qsTr("REMOVE")
                    visible: true
                    enabled: true
                }
            },
            State {
                name: 'Installed'
                extend: 'Upgradable'
            },
            State {
                name: 'In-Progress'
                PropertyChanges {
                    target: basic_action
                    visible: false
                    enabled: false
                }
            }
        ]

        onClicked: {
            var ok;
            if (state == 'Not-Installed') {
                ok = actionMgr.installPackage(target_view.currentPackage);
            }
            else {  // (state == 'Upgradable' || state == 'Installed')
                ok = actionMgr.removePackage(target_view.currentPackage);
            }

            if (ok)
                dialog.show("ConfirmationDialog");
            else
                dialog.show("RejectionDialog");
        }
    }
}
