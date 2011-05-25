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

Rectangle {
    id: target_item
    property alias pkg: package_
    property bool isCurrentItem: target_list.currentIndex === index

    QtObject {
        id: package_
        property string name: model.package.name
        property string version: model.package.version
        property string release: model.package.release
        property string arch: model.package.arch
        property string status: model.package.status
        property string source: model.package.source
        property string category: model.package.category
        property string summary: model.package.summary
        property string description: model.package.description
        property string size: model.package.size
        property string install_time: model.package.install_time
        property string icon: model.package.icon
    }

    function _setFocus() {
        target_list.currentIndex = index;
        forceActiveFocus();
    }

    function getIconFullPath(_prefix, _img) {
        if (_img) {
            return config.iconsDir + _prefix + _img.toLowerCase() + '.png'
        }
        else {
            return "";
        }
    }

    // Workaround as not getting the desired z behavior on highlight element
    color: isCurrentItem && !target_list.movingVertically? syspal.highlight : "white"

    // The templates below are meant to hold reusable components. Till we defines the details and Advanced
    // let is be like that to facilitate any possible refactory of this code.
    // Name template
    Text {
        parent: composer.name
        height: parent.height
        text: {
            if (model.package.name)
                return model.package.name;
            else
                return "waiting...";
        }
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        color: isCurrentItem? config._LIST_ITEM_NAME_HICOLOR :
        config._LIST_ITEM_NAME_COLOR
        font {
            pixelSize: height
            bold: true
        }
    }

    // Category Icon template
    Image {
        parent: composer.category_icon
        anchors.fill: parent
        source: getIconFullPath('category-', model.package.category)
        asynchronous: true
    }

    // Source Icon template
    Image {
        parent: composer.source_icon
        anchors.fill: parent
        source: getIconFullPath('source-', model.package.source)
        asynchronous: true
    }

    // Summary template
    Text {
        parent: composer.summary
        height: parent.height
        text: model.package.summary
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        font {
            pixelSize: height
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            _setFocus();
        }
        onClicked: {
            if (mouse.button == Qt.LeftButton) {
                // The controlmodifier is here just for testing layouts purposes (see TargetList)
                // It could be used on settings if such customization is applied. Let's see.
                if (mouse.modifiers & Qt.ControlModifier) {
                    target_list.relocateButtons = !target_list.relocateButtons;
                    return;
                }
            }
        }
    }
    // Icon template
    //    Image {
    //        parent: composer.icon
    //        anchors.fill: parent
    //        source: parent.getIconFullPath(model.package.icon)
    //        asynchronous: true
    //    }

    Row {
        id: composer
        property alias name: item_name
        property alias summary: item_summary
        property alias category_icon: item_category_icon
        property alias source_icon: item_source_icon
        //    property alias icon: item_icon

        x: 4
        width: parent.width - x
        height: parent.height
        spacing: 8

        Column {
            width: parent.width
            height: parent.height
            Item {
                id: header
                width: parent.width
                height: parent.height/2
                Image {
                    id: item_status

                    function getImageSource(_status) {
                        var _statusName = mam.mapStatus(_status);
                        if (_statusName === "")
                            return "";
                        else {
                            var _enabled = mam.statusEnabled(_status);
                            var _type = _enabled ? "enabled" : "disabled";
                            return config.imagesDir + _statusName + "-" + _type + ".png";
                        }
                    }

                    z: target_item.z + 2
                    height: config._LIST_ITEM_STATUS_ICON_SIZE
                    width: height
                    visible: source !== ""
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 0.9
                    smooth: true
                    source: getImageSource(model.package.status)
                    asynchronous: true

                    HintArea {
                        visible: !target_list.movingVertically
                        anchors.fill: parent
                        text: "Click to filter by " + mam.mapStatus(model.package.status)
                        onClicked: {
                            mam.currentStatus = model.package.status + '|';
                            mam.reloadData();
                        }
                    }
                }
                Item {
                    id: item_name
                    property int paintedWidth: children[0].paintedWidth

                    width: paintedWidth
                    height: config._LIST_ITEM_NAME_HEIGHT
                    anchors {
                        left: item_status.right
                        leftMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                }
                Row {
                    spacing: 4
                    width: parent.width - x
                    height: parent.height
                    anchors {
                        left: item_name.right
                        leftMargin: 20
                    }
                    Item {
                        id: item_source_icon
                        z: target_item.z + 2
                        visible: target_item.isCurrentItem
                        width: height
                        height: config._LIST_ITEM_SOURCE_ICON_SIZE
                        //anchors.verticalCenter: parent.verticalCenter

                        HintArea {
                            visible: !target_list.movingVertically
                            anchors.fill: parent
                            text: "Click to filter by " + model.package.source
                            onClicked: {
                                mam.currentSource = model.package.source;
                                mam.reloadData();
                            }
                        }
                    }
                    Item {
                        id: item_category_icon
                        z: target_item.z + 2
                        visible: target_item.isCurrentItem
                        width: height
                        height: config._LIST_ITEM_CATEGORY_ICON_SIZE
                        //anchors.verticalCenter: parent.verticalCenter

                        HintArea {
                            visible: !target_list.movingVertically
                            anchors.fill: parent
                            text: "Click to filter by " + model.package.category
                            onClicked: {
                                mam.currentCategory = model.package.category;
                                mam.reloadData();
                            }
                        }
                    }
                }
            }
            Item {
                width: parent.width
                height: parent.height/2
                Item {
                    id: item_summary
                    z: target_item.z + 2
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
