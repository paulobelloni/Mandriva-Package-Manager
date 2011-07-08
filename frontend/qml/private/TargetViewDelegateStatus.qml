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
    Image {
        id: item_status

        function getImageSource(_status) {
            if (_status == "" || _status == undefined)
                return "";
            else {
                var _enabled = mpm.statusEnabled(_status);
                var _type = _enabled ? "enabled" : "disabled";
                var _name = "status-" + _status.toLowerCase();// + "-" + _type; //FIXME - We should take type too
                return config.iconsDir + _name + ".png";
            }
        }

        anchors.centerIn: parent
        height: config._LIST_ITEM_STATUS_ICON_SIZE
        width: height
        visible: source !== ""
        opacity: 0.9
        smooth: true
        source: getImageSource(itemValue)
        asynchronous: true

        //    HintArea {
        //        visible: !target_list.movingVertically
        //        anchors.fill: parent
        //        text: "Click to filter by " + model.package.status
        //        onClicked: {
        //            mpm.currentStatus = model.package.status + '|';
        //            mpm.reloadData();
        //        }
        //    }
    }
}
