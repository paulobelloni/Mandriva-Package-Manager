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

Panel {
    id: panel
    property alias contentHeight: filter_list.contentHeight
    property alias panelTitle: title.text
    property alias currentFilter: banner.text
    property bool needsContraction: inactiveHeight < preferredHeight
    property bool isCurrentPanel: false
    property string markedItem: ""

    function _getPreferredHeight() {
        var pref = title.height + filter_list.height + 20; //20 bottomMargin workaround
        if (pref > filters_area.expandedHeight)
            return filters_area.expandedHeight;
        else
            return pref;
    }

    preferredHeight: _getPreferredHeight()
    Text {
        id: title
        height: font.pointSize + 4 // 4 for bold

        color: config._LEFTPANEL_FONT_COLOR
        font {
            italic: true
            pointSize: 11
        }
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: panel.top
            topMargin: 5
        }
    }
    Text {
        id: banner
        function _visible() {
            return !panel.isCurrentPanel
                    && text != ""
                   && panel.needsContraction;
        }
        height: font.pointSize + 4 // 4 for bold
        visible: _visible()
        color: config._LEFTPANEL_FONT_COLOR
        font {
            pointSize: 11
            bold: true
        }
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: title.bottom
            topMargin: 15
        }
    }
    FilterGroupList {
        id: filter_list
        filterGroupName: panel.panelTitle
        height: childrenRect.height
        visible: isCurrentPanel || !panel.needsContraction
        anchors {
            left: panel.left
            leftMargin: 10
            right: panel.right
            top: title.bottom
            topMargin: 15
        }
    }
    onPreferredHeightChanged: {
        filters_area.recalculateChildrenHeight();
    }
}
