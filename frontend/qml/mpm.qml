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
import components 1.0 as QDESK
import QtQuick 1.0
import "private" as MPM

//FIXME: All configuration and globals needs to be refactored
//      In controller maybe...
LayoutItem {
    id: mpm

    signal reloadData()
    signal restoreLeftPanel()

    property variant currentFilters: {'':''}
    property string currentSort: ""
    property string currentSortDirection: "up"
    property bool techItemsShown: false
    property real handlePosition: 0
    property int totalOfItems: packageModel.totalOfMatches
    property bool leftPanelHidden: false
    property bool statusFilterNotInstalledEnabled: false
    property bool statusFilterInstalledEnabled: false
    property bool statusFilterUpgradableEnabled: false
    property bool statusFilterInProgressEnabled: false
    property bool scrollbarFrozen: true
    property bool enableLeftPanelCustomization

    // FIXME: change everything about configuration below...
    //       including change them to upper case.
    //       we should get it from outside
    QtObject {
        id: config

        property string rootDir: mpmController.getRootDir()
        property string configDir: rootDir + "/config/"
        property string imagesDir: rootDir + "/images/"
        property string iconsDir: imagesDir + "icons/"

        property int _SEARCH_TIMER_INTERVAL: 150
        property int _DEFAULT_HINT_INTERVAL: 800
        property int _HINT_HORIZONTAL_GAP: 4
        property int _HINT_VERTICAL_GAP: 4
        property int _TOOLBAR_HEIGHT: 35
        property int _GRID_B_MARGIN: 20
        property int _GRID_L_MARGIN: 10
        property int _GRID_R_MARGIN: 10
        property int _GRID_ITEM_MAX_WIDTH: 200
        property int _GRID_ITEM_HEIGHT: 120
        property int _GRID_ITEM_CONTENT_H_MARGIN: 20
        property int _GRID_ITEM_CONTENT_V_MARGIN: 10
        property int _GRID_APP_NAME_SIZE: 15
        property int _LIST_APP_NAME_SIZE: 12
        property int _GRID_ICON_SIZE: 64
        property int _LIST_ICON_SIZE: 48
        property int _GRID_STATUS_WIDTH: 60
        property int _LEFT_PANEL_SIZE: 150
        property int _APP_FULLNAME_DETAILS_SIZE: 20
        property int _STATUS_DETAILS_WIDTH: 90
        property int _DESCRIPTION_DETAILS_HEIGHT: 250
        property int _IMAGE_DETAILS_WIDTH: _IMAGE_DETAILS_HEIGHT * 1.5
        property int _IMAGE_DETAILS_HEIGHT: 400
        property int _BORDER_DETAILS_WIDTH: 2
        property int _ADJUST_MARGIN_DETAILS: 40 // when scrollbar is visible
        property int _L_MARGIN_DETAILS: 20
        property int _R_MARGIN_DETAILS: 50
        property int _V_MARGIN_DETAILS: 0
        property int _L_MARGIN_MANAGE: 20
        property int _R_MARGIN_MANAGE: 20
        property int _V_MARGIN_MANAGE: 20
        property int _LIST_ITEM_HEIGHT: 50
        property int _MANAGE_BUTTON_WIDTH: 80
        property int _MANAGE_BUTTON_HEIGHT: 30
        property int _STATUS_AREA_HEIGHT: 20
        property int _STATUS_BUTTON_RADIUS: 15
        property int _TOOLBARITEMS_WITH: 400
        property int _SEARCHBOX_WITH: 300
        property int _LEFTPANEL_WIDTH: 140
        property int _LEFTPANEL_TOOLBAR_HEIGHT: 20
        property int _SEPARATOR_WIDTH: 2
        property int _ACTION_BUTTON_WIDTH: 70
        property int _ACTION_BUTTON_HEIGHT: 25
        property int _LIST_ITEM_NAME_HEIGHT: 16
        property int _LIST_ITEM_CATEGORY_ICON_SIZE: 20
        property int _LIST_ITEM_SOURCE_ICON_SIZE: 20
        property int _LIST_ITEM_STATUS_ICON_SIZE: 15
        property int _MINIMUM_TARGET_PANEL_HEIGHT: 50

        //---rates
        property real _GRID_ITEM_WIDTH_RATE: 5.3
        property real _ICON_STATUS_RATE: 3.5
        property real _FOLDER_RATION: 0.25

        //---colors
        property color _SEPARATOR_COLOR:  "#c9c9c8"
        property color _INSTALLED_BACKGROUND_COLOR: "#6dab6e"
        property color _INSTALL_BUTTON_BACKGROUND: "green"
        property color _UPGRADE_BUTTON_BACKGROUND: "yellow"
        property color _REMOVE_BUTTON_BACKGROUND: "red"
        property color _STATUS_BORDER: "#ebebec"
        property color _STATUS_FONT_COLOR: "#ffffff"
        property color _BUTTON_FONT_COLOR: "#000000"
        property color _TOOLBAR_BACKGROUND_COLOR: syspal.window
        property color _TOOLBAR_BORDER_COLOR: "transparent"//Qt.lighter(syspal.window)
        property color _TOOLBARITEM_FONT_COLOR: syspal.text
        property color _TOOLBARITEM_BACKGROUND_COLOR: "#9fa1a0"
        property color _LEFTPANEL_BACKGROUND_COLOR: syspal.dark
        property color _LEFTPANEL_TOOLBAR_INITIAL_COLOR: "#6d6d6d"
        property color _LEFTPANEL_TOOLBAR_FINAL_COLOR: "#4d4d4d"
        property color _LEFTPANEL_FONT_COLOR: "#ffffff"
        property color _LEFTPANEL_MARKED_FONT_COLOR: syspal.highlightedText
        property color _LEFTPANEL_TITLE_FONT_COLOR: syspal.text
        property color _LEFTPANEL_HIGHLIGHT_COLOR: syspal.highlight
        property color _TARGETPANEL_BACKGROUND_COLOR: syspal.base
        property color _STATUSBAR_BACKGROUND_INITIAL_COLOR: "#6d6d6d"
        property color _STATUSBAR_BACKGROUND_FINAL_COLOR: "#4d4d4d"
        property color _LIST_ITEM_NAME_COLOR: "#000000"
        property color _LIST_ITEM_NAME_HICOLOR: "#000000"
        property color _LIST_ITEM_DETAILS_COLOR: "#000000"

        //---icons
        property url    _THEME_ICONS: "image://desktoptheme/"
        property string _EDIT_CLEAR_ICON: "edit-clear"
        property string _EDIT_FIND_ICON: "edit-find"
        property string _PREVIOUS_ICON: "go-previous"
        property string _NEXT_ICON: "go-next"
        property string _UPGRADE_ICON: "go-bottom"
        property string _NO_IMAGE: "no-image"
        property string _SETTINGS_ICON: "preferences-system"
        property string _HISTORY_ICON: "document-open-recent"
        property string _CLOSE_ICON: "window-close"

        //---files
        property string _LEFTPANEL_CONFIG_FILE: "LeftPanel.json"
    }

    QtObject {
        id: controllerData

        property string pattern: ""
        property string category: normalize(mpm.currentFilters['Category'])
        property string source: normalize(mpm.currentFilters['Source'])
        property string status: normalize(mpm.currentFilters['Status'])
        property string sort: mpm.currentSort
        property string sortDirection: mpm.currentSortDirection

        onPatternChanged: search_timer.restart()
    }

    function normalize(value) {
        return value? value : ""
    }

    function debugData() {
        console.debug("==> pattern: "+controllerData.pattern)
        console.debug("==> category: "+controllerData.category)
        console.debug("==> source: "+controllerData.source)
        console.debug("==> status: "+controllerData.status)
        console.debug("==> sort: "+controllerData.sort)
        console.debug("==> sortDirection: "+controllerData.sortDirection)
    }

    function runSearch() {
        //mpm.debugData();
        mpmController.search(controllerData);
    }

    function setStatusSelected(status) {
        statusFilter = statusFilter !== status ? status : ""
    }

    function isStatusSelected(status) {
        return statusFilter === "" || statusFilter === status
    }

    function statusEnabled(c) {
        if (c === "Not-Installed") {
            return mpm.statusFilterNotInstalledEnabled;
        }
        else if (c === "Installed") {
            return mpm.statusFilterInstalledEnabled;
        }
        else if (c === "Upgradable") {
            return mpm.statusFilterUpgradableEnabled;
        }
        else if (c === "In-Progress") {
            return mpm.statusFilterInProgressEnabled;
        }
        else {
            return false;
        }
    }

// FIXME: we need to use LayoutItem to limit resizing
    minimumSize: "800x550"
    preferredSize: "800x550"
    width: preferredSize.width
    height: preferredSize.height
//
// FIXME: - synchronize the limits with the upper layer.
//       - also, make the application headless
// LayoutItem seems to work only as hint to upperlayer done in cpp.
// So, we need to figure out how to deal with it.
//    onWidthChanged: {
//        if (width > maximumSize.width) {
//            width = maximumSize.width
//        }
//    }

    // Helper functions
    function rightEnd(element) {
        return element.x + element.width;
    }

    function bottomEnd(element) {
        return element.y + element.height;
    }

    // Helper Component
    Component {
        id: null_item
        Item {
        }
    }

    // Helper Model
    ListModel {
        id: null_model
    }

    Timer {
        id: search_timer
        interval: config._SEARCH_TIMER_INTERVAL
        onTriggered: mpm.reloadData();
    }

    SystemPalette {
        id: syspal
    }

    MPM.MainWindow {
        id: main_window
        anchors.fill: parent
    }

    MPM.Hint {
        id: hint
    }

    Component.onCompleted: {
        mpmController.setMinimumSize(minimumSize.width, minimumSize.height);
    }
}
