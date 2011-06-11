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
import "custom-qtdesktop" as MDV_QDESK

Item {
    id: target_view
    property bool itemMarked: false
    property bool itemSelected: table_view.currentIndex >= 0
    property variant currentPackage
    property alias headerHeight: table_view.headerHeight
    property alias hscrollbarHeight: table_view.hscrollbarHeight

    Component {
        id: delegates
        Loader {
            height: config._LIST_ITEM_HEIGHT
            Component {
                id: status_delegate
                TargetViewDelegateStatus {
                }
            }
            Component {
                id: name_summary_delegate
                TargetViewDelegateNameSummary {
                }
            }
            Component {
                id: version_release_delegate
                TargetViewDelegateText {
                    visible: !target_view.itemMarked || !itemSelected
                }
            }
            Component {
                id: size_release_delegate
                TargetViewDelegateText {
                    visible: !target_view.itemMarked || !itemSelected
                }
            }
            Component.onCompleted: sourceComponent = resources[table_view.header[columnIndex].index];
        }
    }

    MDV_QDESK.TableView {
        id: table_view
        anchors.fill: parent
        cacheBuffer: 1000
        itemHeight: config._LIST_ITEM_HEIGHT
        maximumFlickVelocity: 400
        flickDeceleration: 100
        spacing: 0
        interactive: true
        highlightFollowsCurrentItem: false
        highlightMoveDuration: 1
        highlightMoveSpeed: contentHeight
        frame: false
        headerVisible: true
        alternateRowColor: true
        sortIndicatorVisible: !itemMarked
        forceHscrollbarHiding: itemMarked
        forceVscrollbarHiding: itemMarked
        model: packageModel
        highlight: null_item
        itemDelegate: delegates
        rowDelegate: QDESK.QStyleItem {
            id: rowstyle
            property alias packageToolbarWidth: package_toolbar.width

            elementType: "itemrow"
            activeControl: itemAlternateBackground ? "alternate" : ""
            //selected: itemSelected ? "true" : "false"

            Rectangle {
                id: background
                anchors.fill: parent
                color: itemSelected ? syspal.highlight : "transparent"
                opacity: 0.5
                states: [
                    State {
                        name: "itemMarked"
                        when: target_view.itemMarked
                        PropertyChanges {
                            target: background
                            opacity: 1
                        }
                    }
                ]
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    if (!target_view.itemMarked)
                        table_view.currentIndex = rowIndex;
                    forceActiveFocus()
                }
                onClicked: {
                    if (target_view.itemMarked && table_view.currentIndex == rowIndex) {
                        target_view.itemMarked = false;
                    }
                    else {
                        if (target_view.itemMarked) {
                            table_view.currentIndex = rowIndex;
                        }
                        else {
                            target_view.itemMarked = true;
                            table_view.changeIndex(rowIndex, ListView.Beginning, true);
                        }
                    }
                }
            }

            PackageToolbar {
                id: package_toolbar
                visible: target_view.itemMarked && itemSelected
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 10//column2.width - width
                }
            }
        }

        MDV_QDESK.TableColumn {
            id: column0
            index: 0
            resizeEnabled: false
            dragEnabled: !target_view.itemMarked
            property: 'package.status'
            caption: ''
            width: 30
        }
        MDV_QDESK.TableColumn {
            id: column1
            index: 1
            resizeEnabled: !target_view.itemMarked
            dragEnabled: !target_view.itemMarked
            property: '[package.name, package.summary]'
            caption: 'Name / Summary'
            sortName: 'Name'
            width: table_view.treeWidth -
                   (column0.contentWidth +
                    (column2.visible? column2.contentWidth : 0) +
                    (column3.visible? column3.contentWidth : 0))

//            contentWidth: itemMarked ? table_view.width - rowstyle.packageToolbarWidth : width //FIXME
            contentWidth: itemMarked ? width * 0.7 : width
        }
        MDV_QDESK.TableColumn {
            id: column2
            index: 2
            property: 'package.version'
            caption: 'Version'
            width: 100
            visible: !target_view.itemMarked
        }
        MDV_QDESK.TableColumn {
            id: column3
            index: 3
            property: 'mpmController.humanize_size(package.size, 1)'
            caption: 'Size'
            width: 100 + table_view.vscrollbarWidth
            contentWidth: 100
            visible: !target_view.itemMarked
        }

        onItemModelChanged: target_view.currentPackage = itemModel.package

        onSortIndicatorDirectionChanged: {
            mpm.currentSort = header[sortColumn].sortName;
            mpm.currentSortDirection = sortIndicatorDirection;
            mpm.reloadData();
        }
    }

    Connections {
        target: mpm
        onReloadData: {
            table_view.resetList();
            mpm.runSearch();
        }
    }
}
