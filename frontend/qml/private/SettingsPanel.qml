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
import components 1.0 as QDESK

FocusScope {
    focus: true
    Rectangle {
        anchors.fill: parent
        color: syspal.window
    }

    SettingsToolbar {
        id: toolbar
        width: parent.width
        height: config._TOOLBAR_HEIGHT
    }

    QDESK.TabFrame {
        id:frame
        width: parent.width
        anchors {
            top: toolbar.bottom
            bottom: parent.bottom
        }

        focus:true
        position: "North"
        tabbar: QDESK.TabBar{
            parent: frame
            focus:true
        }

        QDESK.Tab {
            title: "Left-Panel"
            Column {
                anchors.centerIn: parent
                spacing: 10
                QDESK.CheckBox {
                    id: enabledCheck
                    enabled: false
                    text: "Enable customization"
                    checked: true
                    onCheckedChanged: {
                        mpm.enableLeftPanelCustomization = checked;
                    }
                }
                Button {
                    text: "Restore default"
                    width: enabledCheck.width
                    onClicked: {
                        mpmController.remove_config(config._LEFTPANEL_CONFIG_FILE);
                        mpm.restoreLeftPanel();
                    }
                }
            }
        }
    }
}
