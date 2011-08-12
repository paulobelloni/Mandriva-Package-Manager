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
import "custom-qtdesktop" as MDV_QDESK

ActionDialogTab {
    id: tab
    property alias model: table_view.model
    property alias count: table_view.count

    hidden: !actionMgr.rejection

    ActionDialogTableViewNVRA {
        id: table_view
        property variant rejection: table_view.itemModel ? table_view.itemModel.rejection : null

        width: parent.width
        anchors {
            top: parent.top
            bottom: detail_area.top
        }
        name: "rejection.package.name"
        nameWidth: 120
        version: "rejection.package.version"
        release: "rejection.package.release"
        arch: "rejection.package.arch"

        MDV_QDESK.TableColumn {
            id: type
            property: "mpm.rejectionTypeToText(rejection.type)"
            sortName: "Type"
            caption: qsTr("Reason")
            width: table_view.treeWidth -
                   (table_view.nameWidth + table_view.versionWidth +
                    table_view.releaseWidth + table_view.archWidth)
        }
    }
    Loader {
        id: detail_view
        property variant model: table_view.rejection
                                ? table_view.rejection.detail : null
        property int headerHeight: item && item.headerHeight
                                   ? item.headerHeight : 0
        property bool hscrollbarVisible: item && item.hscrollbarVisible
                                         ? item.hscrollbarVisible : false
        property int hscrollbarHeight: item && item.hscrollbarHeight
                                       ? item.hscrollbarHeight : 0

        width: parent.width
        anchors {
            top: detail_area.bottom
            bottom: parent.bottom
        }

        Component {
            id: nvra_detail
            ActionDialogTableViewNVRA {
                model: detail_view.model
                name: "detail.name"
                version: "detail.version"
                release: "detail.release"
                arch: "detail.arch"
            }
        }

        Component {
            id: capabilities_detail
            ActionDialogTableView {
                id: capabilities_table_view
                model: detail_view.model
                MDV_QDESK.TableColumn {
                    id: name
                    property: "typeof(detail) == 'string' ? detail : ''"
                    sortName: "Capability"
                    caption: qsTr("Capability") + "   (" + capabilities_table_view.count + ")"
                    width: table_view.treeWidth
                }
            }
        }

        sourceComponent: {
            if (!table_view.rejection)
                return null;

            if (table_view.rejection.type == 'reject-remove-basesystem')
                return null;
            else if (table_view.rejection.type == 'reject-install-unsatisfied')
                return capabilities_detail;
            else
                return nvra_detail;
        }
    }
    SplitterColumn {
        id: detail_area
        frameVisible: true
        minimumY: table_view.headerHeight +
                  (table_view.hscrollbarVisible? table_view.hscrollbarHeight : 0)
        maximumY: parent.height -
                  (height + detail_view.headerHeight +
                    (detail_view.hscrollbarVisible? detail_view.hscrollbarHeight : 0))
        width: parent.width
        height: detail_summary.height + 10
        handleAnchors {
            centerIn: undefined
            bottom: detail_area.bottom
            bottomMargin: -2
            horizontalCenter: detail_area.horizontalCenter
        }
        Row {
            id: detail_summary
            spacing: 5
            height: rejected_name.paintedHeight
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 5
            }
            Text {
                id: rejected_name
                text: table_view.rejection? table_view.rejection.package.name : ""
                font {
                    underline: true
                }
            }
            Text {
                id: rejected_text
                property string rejType: table_view.rejection? table_view.rejection.type : ""
                text: rejectionTypeToDetail(rejType) + ":"
            }
        }
        Component.onCompleted: {
            y = (parent.height - height)/2;
        }
    }
}
