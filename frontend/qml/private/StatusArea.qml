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

Item {
    id: status_area
    property alias totalVisible: total.visible

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 1.0
                color: config._STATUSBAR_BACKGROUND_INITIAL_COLOR
            }
            GradientStop {
                position: 0.0
                color: config._STATUSBAR_BACKGROUND_FINAL_COLOR
            }
        }
    }

    TotalOfMatches {
        id: total
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }
    }

    Item {
        id: progress
        width: parent.width/2 - 10 //10 for splitter handle
        height: parent.height
        anchors {
            right: parent.right
            rightMargin: 16
            verticalCenter: parent.verticalCenter
        }

        Text {
            id: step_label
            anchors {
                right: progress_bar.left
                rightMargin: 2
                verticalCenter: parent.verticalCenter
            }
            text: {
                var _text = '';
                if (actionMgr.progress_step == 'DOWNLOAD') {
                    _text += qsTr('Downloading');
                }
                else if (actionMgr.progress_step == 'INSTALL') {
                    _text += qsTr('Installing');
                }
                else if (actionMgr.progress_step == 'REMOVE') {
                    _text += qsTr('Removing');
                }
                else {
                    return "";
                }
                return _text + '...';
            }
            visible: progress_bar.visible
            color: syspal.light
            font {
                pointSize: 10
                italic: true
            }
        }
        QDESK.ProgressBar {
            id: progress_bar
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            value: actionMgr.taskMgr.total > 0 ? actionMgr.taskMgr.processed/actionMgr.taskMgr.total : -1
            visible: value >= 0 && value < 1
            width: config._STATUSBAR_PROGRESS_BAR_WIDTH
            height: parent.height * config._STATUSBAR_PROGRESS_BAR_HEIGHT_RATE

            MouseArea {
                id: bar_mouse_area
                anchors.fill: parent
                hoverEnabled: true
            }
        }
        ProgressPanel {
            id: panel
            visible: false
            anchors {
                bottom: parent.top
                bottomMargin: 3
                right: progress_bar.right
            }
            states: [
                State {
                    name: "show"
                    when: bar_mouse_area.containsMouse && panel.packageName.length
                    PropertyChanges {
                        target: panel
                        visible: true
                    }
                }
            ]
        }
    }
}
