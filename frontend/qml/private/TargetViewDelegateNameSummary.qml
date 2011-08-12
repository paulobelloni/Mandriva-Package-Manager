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

TargetViewDelegateTemplate {
    Column {
        anchors.fill: parent
        Row {
            width: parent.width
            height: parent.height/2
            spacing: 10
            Text {
                id: name_text
                property string name: validate(itemModel.package.name)
                text: {
                    if (name)
                        return name;
                    else
                        return qsTr("waiting...");
                }
                height: parent.height
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                font {
                    pointSize: 12
                    bold: true
                }
            }
            Text {
                text: {
                    var pkg_ws = mpm.archToWordSize(validate(itemModel.package.arch));
                    if (name_text.text && pkg_ws > 0 &&
                            mpmController.getArchWordSize() != pkg_ws)
                        return "(" + pkg_ws + " bits)";
                    else
                        return "";
                }
                height: parent.height
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                color: config._ARCH_WORDSIZE_COLOR
                font {
                    pointSize: 8
                }
            }
        }
        Item {
            width: parent.width
            height: parent.height/2
            Text {
                visible: !progress.visible
                anchors.fill: parent
                text: validate(itemModel.package.summary)
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            QDESK.ProgressBar {
                id: progress
                visible: value < 1.0
                width: parent.width * 0.9
                height: parent.height * 0.6
                anchors.verticalCenter: parent.verticalCenter
                value: validate(itemModel.package.action_progress, 1.0)
            }
        }
    }
}
