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

ListView {
    objectName: "target_list"
    property int maxVisibleItems: height/(config._LIST_ITEM_HEIGHT + spacing)
    property bool relocateButtons: false // Just for testing layouts, remove this before later on! (customization??)
    property bool showItemExpanded: relocateButtons // Also for tests...
                                                    // Expansion could be used for displaying more
                                                    // information, like NVRA, description...
                                                    // Needs UxD to indicate the way to go.
    function resetList() {
        target_list.positionViewAtIndex(0, ListView.Beginning);
    }

    clip: true
    focus: true
    highlightFollowsCurrentItem: false
    spacing: 10
    cacheBuffer: 1000
    model:  packageModel
    delegate: TargetListDelegate {
        width: ListView.view.width
        height: config._LIST_ITEM_HEIGHT * (showItemExpanded && isCurrentItem? 2 : 1)
    }
    highlight: Item {
        id: hl
        visible: !target_list.movingVertically
        y: target_list.currentItem.y
        z: target_list.currentItem.z + 1
        width: target_list.width
        height: target_list.currentItem.height
        TargetListHighlight {
            id: hl_body
            z: parent.itemZ + 100
            anchors.fill: parent
        }
    }

    Connections {
        target: mam
        onResetView: target_list.resetList()
    }
}
