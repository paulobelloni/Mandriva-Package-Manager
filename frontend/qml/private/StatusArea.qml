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

FocusScope {
    focus:  false

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 0
                color: config._STATUSBAR_BACKGROUND_INITIAL_COLOR
            }
            GradientStop {
                position: 1
                color: config._STATUSBAR_BACKGROUND_FINAL_COLOR
            }
        }
    }

    Row {
        spacing: 50
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            rightMargin: 100
        }

        Column {
            spacing: 1
            anchors {
                verticalCenter: parent.verticalCenter
            }

            TotalOfMatches {
            }

            TechnicalToggler {
            }
        }
        StatusFilter {
            anchors {
                verticalCenter: parent.verticalCenter
            }
        }
    }
}
