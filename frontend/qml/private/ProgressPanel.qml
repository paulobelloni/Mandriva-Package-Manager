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

Item {
    property alias packageName: name.text

    width: Math.max(250, progress_details.childrenRect.width + 50)
    height: progress_details.childrenRect.height

    Rectangle {
        anchors.fill: parent
        border {
            width: 3
            color: config._PROGRESS_PANEL_BACKGROUND_COLOR
        }
        Rectangle {
            anchors.fill: parent
            color: config._PROGRESS_PANEL_BACKGROUND_COLOR
            opacity: 0.7
        }
    }
    Column {
        id: progress_details
        x: 5
        spacing: 5
        Row {
            spacing: 5
            Text {
                id: step
                text: qsTr('Step') + ':'
                color: config._PROGRESS_PANEL_FONT_COLOR
                font {
                    bold: true
                }
            }
            Text {
                color: config._PROGRESS_PANEL_FONT_COLOR
                text: {
                    var _text = actionMgr.taskMgr.processed + '/' + actionMgr.taskMgr.total;
                    _text += '    (' + step_label.text + ')';
                    return _text;
                }
            }
        }
        Row {
            spacing: 5
            Text {
                id: name
                text: qsTr('Package') + ':'
                color: config._PROGRESS_PANEL_FONT_COLOR
                font {
                    bold: true
                }
            }
            Text {
                color: config._PROGRESS_PANEL_FONT_COLOR
                text: actionMgr.progress_package && actionMgr.progress_package.name
                      ? actionMgr.progress_package.name : ''
            }
        }
        Row {
            spacing: 10
            Row {
                spacing: 5
                Text {
                    text: qsTr('Version') + ':'
                    color: config._PROGRESS_PANEL_FONT_COLOR
                    font {
                        bold: true
                    }
                }
                Text {
                    color: config._PROGRESS_PANEL_FONT_COLOR
                    text: actionMgr.progress_package && actionMgr.progress_package.version
                          ? actionMgr.progress_package.version : ''
                }
            }
            Row {
                spacing: 5
                Text {
                    text: qsTr('Arch') + ':'
                    color: config._PROGRESS_PANEL_FONT_COLOR
                    font {
                        bold: true
                    }
                }
                Text {
                    color: config._PROGRESS_PANEL_FONT_COLOR
                    text: actionMgr.progress_package && actionMgr.progress_package.arch
                          ? actionMgr.progress_package.arch : ''
                }
            }
        }
        Row {
            spacing: 5
            Text {
                text: qsTr('Release') + ':'
                color: config._PROGRESS_PANEL_FONT_COLOR
                font {
                    bold: true
                }
            }
            Text {
                color: config._PROGRESS_PANEL_FONT_COLOR
                text: actionMgr.progress_package && actionMgr.progress_package.release
                      ? actionMgr.progress_package.release : ''
            }
        }
        Row {
            spacing: 10
            Row {
                spacing: 5
                visible: amount.text.length
                Text {
                    text: qsTr('Progress') + ':'
                    color: config._PROGRESS_PANEL_FONT_COLOR
                    font {
                        bold: true
                    }
                }
                Text {
                    id: amount
                    color: config._PROGRESS_PANEL_FONT_COLOR
                    text: {
                        if (actionMgr.progress_amount > 0 && actionMgr.progress_total > 0) {
                            var _progress = 100 * actionMgr.progress_amount/actionMgr.progress_total;
                            return _progress.toFixed(1) + '%';
                        }
                        else return '';
                    }
                }
            }
            Row {
                spacing: 5
                visible: total.text.length
                Text {
                    color: config._PROGRESS_PANEL_FONT_COLOR
                    text: qsTr('Total') + ':'
                    font {
                        bold: true
                    }
                }
                Text {
                    id: total
                    color: config._PROGRESS_PANEL_FONT_COLOR
                    text: actionMgr.progress_total? actionMgr.progress_total : ''
                }
            }
        }
        Row {
            spacing: 10
            Row {
                spacing: 5
                visible: eta.text.length
                Text {
                    color: config._PROGRESS_PANEL_FONT_COLOR
                    text: qsTr('ETA') + ':'
                    font {
                        bold: true
                    }
                }
                Text {
                    id: eta
                    color: config._PROGRESS_PANEL_FONT_COLOR
                    text: actionMgr.progress_eta? actionMgr.progress_eta : ''
                }
            }
            Row {
                spacing: 5
                visible: speed.text.length
                Text {
                    color: config._PROGRESS_PANEL_FONT_COLOR
                    text: qsTr('Speed') + ':'
                    font {
                        bold: true
                    }
                }
                Text {
                    id: speed
                    color: config._PROGRESS_PANEL_FONT_COLOR
                    text: actionMgr.progress_speed? actionMgr.progress_speed : ''
                }
            }
        }
    }
}
