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
//      NOTE: This is based on the homonimous element defined on qt-components-desktop.
//            But there are so many modifications that it should not be used outside of
//            MPM as a substitute for the "official" one without a careful analysis.
//

/*
*
* TableView
*
* This component provides an item-view with resizable
* header sections.
*
* You can style the drawn delegate by overriding the itemDelegate
* property. The following properties are supported for custom
* delegates:
*
* Note: Currently only row selection is available for this component
*
* itemheight - default platform size of item
* itemwidth - default platform width of item
* itemselected - if the row is currently selected
* itemvalue - The text for this item
* itemforeground - The default text color for an item
*
* For example:
*   itemDelegate: Item {
*       Text {
*           anchors.verticalCenter: parent.verticalCenter
*           color: itemForeground
*           elide: Text.ElideRight
*           text: itemValue
*        }
*    }
*
* Data for each row is provided through a model:
*
* ListModel {
*    ListElement{ column1: "value 1"; column2: "value 2"}
*    ListElement{ column1: "value 3"; column2: "value 4"}
* }
*
* You provide title and size properties on TableColumns
* by setting the default header property :
*
* TableView {
*    TableColumn{ property: "column1" ; caption: "Column 1" ; width:100}
*    TableColumn{ property: "column2" ; caption: "Column 2" ; width:200}
*    model: datamodel
* }
*
* The header sections are attached to values in the datamodel by defining
* the listmodel property they attach to. Each property in the model, will
* then be shown in each column section.
*
* The view itself does not provide sorting. This has to
* be done on the model itself. However you can provide sorting
* on the model and enable sort indicators on headers.
*
* sortColumn - The index of the currently selected sort header
* sortIndicatorVisible - If sort indicators should be enabled
* sortIndicatorDirection - "up" or "down" depending on state
*
*/

import QtQuick 1.0
import components 1.0

FocusScope{
    id: root

    // PBelloni - custom properties - begin
    property alias spacing: tree.spacing
    property alias highlightFollowsCurrentItem: tree.highlightFollowsCurrentItem
    property alias highlightMoveDuration: tree.highlightMoveDuration
    property alias highlightMoveSpeed: tree.highlightMoveSpeed
    property alias interactive:  tree.interactive
    property alias highlight: tree.highlight
    property alias currentItem: tree.currentItem
    property alias maximumFlickVelocity: tree.maximumFlickVelocity
    property alias flickDeceleration: tree.flickDeceleration
    property alias itemHeight: tree.itemHeight
    property alias numItemsPerRow: tree.numItemsPerRow
    property variant itemModel
    property bool forceHscrollbarHiding: false
    property bool forceVscrollbarHiding: false
    property alias hscrollbarHeight: hscrollbar.height
    property alias vscrollbarWidth: vscrollbar.width
    property alias treeWidth: tree.width
    // PBelloni - custom properties - end

    property variant model
    property int frameWidth: frame ? styleitem.pixelMetric("defaultframewidth") : 0;
    property alias contentHeight : tree.contentHeight
    property alias contentWidth: tree.contentWidth
    property bool frame: true
    property bool highlightOnFocus: false
    property bool frameAroundContents: styleitem.styleHint("framearoundcontents")
    property int sortColumn // Index of currently selected sort column

    property bool sortIndicatorVisible: false // enables or disables sort indicator
    property string sortIndicatorDirection: "down" // "up" or "down" depending on current state

    property bool alternateRowColor: true
    property alias contentX: tree.contentX
    property alias contentY: tree.contentY

    property alias currentIndex: tree.currentIndex // Should this be currentRowIndex?

    property alias headerHeight: headerrow.height

    property Component itemDelegate: standardDelegate
    property Component rowDelegate: rowDelegate
    property Component headerDelegate: headerDelegate
    property alias cacheBuffer: tree.cacheBuffer

    property bool headerVisible: true

    default property alias header: tree.header

    signal activated

    Component {
        id: standardDelegate
        Item {
            property int implicitWidth: sizehint.paintedWidth + 4
            Text {
                width: parent.width
                anchors.margins: 4
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                elide: itemElideMode
                text: itemValue ? itemValue : ""
                color: itemForeground
            }
            Text {
                id: sizehint
                text: itemValue ? itemValue : ""
                visible:false
            }
        }
    }

    Component {
        id: nativeDelegate
        // This gives more native styling, but might be less performant
        QStyleItem {
            elementType: "item"
            text:   itemValue
            selected: itemSelected
        }
    }

    Component {
        id: headerDelegate
        QStyleItem {
            elementType: "header"
            activeControl: itemSort
            raised: true
            sunken: true//itemPressed
            text: itemValue
            hover: itemContainsMouse
        }
    }

    Component {
        id: rowDelegate
        QStyleItem {
            id: rowstyle
            elementType: "itemrow"
            activeControl: itemAlternateBackground ? "alternate" : ""
            selected: itemSelected ? "true" : "false"
        }
    }

    Rectangle {
        id: colorRect
        color: "white"
        anchors.fill: frameitem
        anchors.margins: frameWidth
        anchors.rightMargin: (!frameAroundContents && vscrollbar.visible ? vscrollbar.width : 0) + frameWidth
        anchors.bottomMargin: (!frameAroundContents && hscrollbar.visible ? hscrollbar.height : 0) +frameWidth
    }

    QStyleItem {
        id: frameitem
        elementType: "frame"
        onElementTypeChanged: scrollarea.frameWidth = styleitem.pixelMetric("defaultframewidth");
        sunken: true
        visible: frame
        anchors.fill: parent
        anchors.rightMargin: frame ? (frameAroundContents ? (vscrollbar.visible ? vscrollbar.width + 2 * frameMargins : 0) : -frameWidth) : 0
        anchors.bottomMargin: frame ? (frameAroundContents ? (hscrollbar.visible ? hscrollbar.height + 2 * frameMargins : 0) : -frameWidth) : 0
        anchors.topMargin: frame ? (frameAroundContents ? 0 : -frameWidth) : 0
        property int scrollbarspacing: styleitem.pixelMetric("scrollbarspacing");
        property int frameMargins : frame ? scrollbarspacing : 0
    }
    MouseArea {
        id: mousearea

        anchors.fill: tree

        property bool autoincrement: false
        property bool autodecrement: false

        onReleased: {
            autoincrement = false
            autodecrement = false
        }

        // Handle vertical scrolling whem dragging mouse outside boundraries

        Timer { running: mousearea.autoincrement; repeat: true; interval: 20 ; onTriggered: incrementCurrentIndex()}
        Timer { running: mousearea.autodecrement; repeat: true; interval: 20 ; onTriggered: decrementCurrentIndex()}

        onMousePositionChanged: {
            if (mouseY > tree.height && pressed) {
                if (autoincrement)return
                autodecrement = false
                autoincrement = true
            } else if (mouseY < 0 && pressed) {
                if (autodecrement)return
                autoincrement = false
                autodecrement = true
            } else  {
                autoincrement = false
                autodecrement = false
            }
            var y = Math.min(contentY + tree.height - 5, Math.max(mouseY + contentY, contentY))
            var newIndex = tree.indexAt(0, y)
            tree.currentIndex = tree.indexAt(0, y)
        }
        onPressed:  {
            tree.forceActiveFocus()
            var x = Math.min(contentWidth - 5, Math.max(mouseX + contentX, 0))
            var y = Math.min(contentHeight - 5, Math.max(mouseY + contentY, 0))
            tree.currentIndex = tree.indexAt(x, y)
        }

        onDoubleClicked: {
            parent.activated()
        }
    }

    function resetList() {
        vscrollbar.value = 0;
        hscrollbar.value = 0;
    }

    function changePosition(position, layout, lock) {
        position = position < 0 ? 0 : (position >= tree.count ? tree.count - 1: position);
//        if (position == tree.currentPosition)
//            return;
        if (lock) tree.blockUpdates = true
        tree.currentPosition = position;
        if (!layout) layout = ListView.Beginning;
        tree.positionViewAtIndex(tree.currentPosition, layout);
//        wheelarea.verticalValue = contentY/wheelarea.scale // FIXME
        if (lock) tree.blockUpdates = false
    }

    function changeIndex(index, layout, lock) {
        index = index < 0 ? 0 : (index >= tree.count ? tree.count - 1: index);
//        if (index == tree.currentIndex)
//            return;
        changePosition(index, layout, lock);
        tree.currentIndex = index;
    }

    ListView {
        id: tree
        property list<TableColumn> header
        property bool blockUpdates: false
        property int itemHeight: 0
        property int numItemsPerRow: Math.round(height/(itemHeight + spacing))
        property int currentPosition: 0

        focus: true
        clip: true
        highlightFollowsCurrentItem: true
        interactive: false
        model: root.model

        anchors.top: tableColumn.bottom
        anchors.topMargin: -frameWidth
        anchors.left: frameitem.left
        anchors.right: frameitem.right
        anchors.bottom: frameitem.bottom
        anchors.margins: frameWidth
        anchors.rightMargin: vscrollbar.visible ? vscrollbar.width : 0//(!frameAroundContents && vscrollbar.visible ? vscrollbar.width: 0) + frameWidth
        anchors.bottomMargin: hscrollbar.visible ? hscrollbar.height : 0//!frameAroundContents && hscrollbar.visible ? hscrollbar.height : 0)  + frameWidth

        Keys.onUpPressed: root.changeIndex(tree.currentIndex - 1, ListView.Contain)
        Keys.onDownPressed: root.changeIndex(tree.currentIndex + 1, ListView.Contain)
        Keys.onPressed: {
            if (event.key == Qt.Key_PageUp)
                root.changeIndex(tree.currentPosition - numItemsPerRow);
            else if (event.key == Qt.Key_PageDown)
                root.changeIndex(tree.currentPosition + numItemsPerRow);
            else if (event.key == Qt.Key_Home)
                root.changeIndex(0);
            else if (event.key == Qt.Key_End)
                root.changeIndex(tree.count - 1);
        }

        onContentYChanged:  {
            if (!blockUpdates) {
                vscrollbar.value = tree.currentIndex;
            }
        }

        delegate: Item {
            id: rowitem
            width: row.width
            height: row.height
            anchors.margins: frameWidth
            property int rowIndex: model.index
            property bool itemAlternateBackground: alternateRowColor && rowIndex % 2 == 1
            property variant itemModel: model
            Loader {
                id: rowstyle
                // row delegate
                sourceComponent: root.rowDelegate
                // Row fills the tree width regardless of item size
                // But scrollbar should not adjust to it
                width: frameitem.width
                height: row.height
                x: contentX

                property bool itemAlternateBackground: rowitem.itemAlternateBackground
                property bool itemSelected: rowitem.ListView.isCurrentItem
                property int rowIndex: rowitem.rowIndex

                onItemSelectedChanged: {
                    if (itemSelected) root.itemModel = rowitem.itemModel
                }
            }
            Row {
                id: row
                anchors.left: parent.left

                Repeater {
                    id: repeater
                    model: root.header.length
                    Loader {
                        id: itemDelegateLoader
                        visible: header[index].visible
                        sourceComponent: itemDelegate
                        property variant model: tree.model
                        property variant itemProperty: header[index].property

                        width: header[index].contentWidth
                        height: item.height

// height is discovered naturally by binding. Just need enough time to load.
//                        height: item ? item.height :  Math.max(16, styleitem.sizeFromContents(16, 16).height)

                        property variant itemValue: eval(header[index].property)
                        property bool itemSelected: rowitem.ListView.isCurrentItem
                        property color itemForeground: itemSelected ? rowstyleitem.highlightedTextColor : rowstyleitem.textColor
                        property int rowIndex: rowitem.rowIndex
                        property int columnIndex: index
                        property int itemElideMode: header[index].elideMode
                    }
                }
                onWidthChanged: tree.contentWidth = width
            }
        }
    }

    Text{ id:text }

    Item {
        id: tableColumn
        clip: true
        anchors.top: frameitem.top
        anchors.left: frameitem.left
        anchors.right: frameitem.right
        anchors.margins: frameWidth
        visible: headerVisible
        Behavior on height { NumberAnimation{duration:80}}
        height: headerVisible ? styleitem.sizeFromContents(text.font.pixelSize, styleitem.fontHeight).height : frameWidth

        Row {
            id: headerrow

            anchors.top: parent.top
            height:parent.height
            x: -tree.contentX

            Repeater {
                id: repeater
                model: header.length
                property int targetIndex: -1
                property int dragIndex: -1
                delegate: Item {
                    z:-index
                    width: header[index].width
                    visible: header[index].visible
                    height: headerrow.height

                    Loader {
                        sourceComponent: root.headerDelegate
                        anchors.fill: parent
                        property string itemValue: header[index].caption
                        property string itemSort:  (sortIndicatorVisible && index == sortColumn) ? (sortIndicatorDirection == "up" ? "up" : "down") : "";
                        property bool itemPressed: headerClickArea.pressed
                        property bool itemContainsMouse: headerClickArea.containsMouse
                    }
                    Rectangle{
                        id: targetmark
                        width: parent.width
                        height:parent.height
                        opacity: (index == repeater.targetIndex && repeater.targetIndex != repeater.dragIndex) ? 0.5 : 0
                        Behavior on opacity { NumberAnimation{duration:160}}
                        color: palette.highlight
                    }

                    MouseArea{
                        id: headerClickArea
                        enabled: header[index].dragEnabled
                        drag.axis: Qt.YAxis
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: {
                            if (sortColumn == index)
                                sortIndicatorDirection = sortIndicatorDirection === "up" ? "down" : "up"
                            sortColumn = index
                        }
                        // Here we handle moving header sections
                        onMousePositionChanged: {
                            if (pressed) { // only do this while dragging
                                for (var h = 0 ; h < header.length ; ++h) {
                                    if (drag.target.x > headerrow.children[h].x - 10) {
                                        repeater.targetIndex = header.length - h - 1
                                        break
                                    }
                                }
                            }
                        }

                        onPressed: {
                            repeater.dragIndex = index
                            draghandle.x = parent.x
                        }

                        onReleased: {
                            if (repeater.targetIndex >= 0 && repeater.targetIndex != index ) {
                                // Rearrange the header sections
                                var items = new Array
                                for (var i = 0 ; i< header.length ; ++i)
                                    items.push(header[i])
                                items.splice(index, 1);
                                items.splice(repeater.targetIndex, 0, header[index]);
                                header = items
                                if (sortColumn == index)
                                    sortColumn = repeater.targetIndex
                            }
                            repeater.targetIndex = -1
                        }
                        drag.maximumX: 1000
                        drag.minimumX: -1000
                        drag.target: draghandle
                    }

                    Loader {
                        id: draghandle
                        parent: tableColumn
                        sourceComponent: root.headerDelegate
                        width: header[index].width
                        height: parent.height
                        property string itemValue: header[index].caption
                        property string itemSort:  (sortIndicatorVisible && index == sortColumn) ? (sortIndicatorDirection == "up" ? "up" : "down") : "";
                        property bool itemPressed: headerClickArea.pressed
                        property bool itemContainsMouse: headerClickArea.containsMouse
                        visible: headerClickArea.pressed
                        opacity: 0.5
                    }


                    MouseArea {
                        id: headerResizeHandle
                        property int offset: 0
                        property int minimumSize: 20
                        enabled: header[index].resizeEnabled
                        anchors.rightMargin: -width/2
                        width: 16 ; height: parent.height
                        anchors.right: parent.right
                        onPositionChanged:  {
                            var newHeaderWidth = header[index].width + (mouseX - offset)
                            header[index].width = Math.max(minimumSize, newHeaderWidth)
                        }
                        property bool found:false

                        onDoubleClicked: {
                            var row
                            var minWidth =  0
                            var listdata = tree.children[0]
                            for (row = 0 ; row < listdata.children.length ; ++row){
                                var item = listdata.children[row+1]
                                if (item && item.children[1] && item.children[1].children[index] &&
                                        item.children[1].children[index].children[0].hasOwnProperty("implicitWidth"))
                                    minWidth = Math.max(minWidth, item.children[1].children[index].children[0].implicitWidth)
                            }
                            if (minWidth)
                                header[index].width = minWidth
                        }
                        onPressedChanged: if(pressed)offset=mouseX
                        QStyleItem {
                            visible: headerResizeHandle.visible
                            anchors.fill: parent
                            cursor: "splithcursor"
                        }
                    }
                }
            }
        }
        Loader {
            id: loader
            z:-1
            sourceComponent: root.headerDelegate
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: headerrow.bottom
            anchors.rightMargin: -2
            width: root.width - headerrow.width
            property string itemValue
            property string itemSort
            property bool itemPressed
            property bool itemContainsMouse
        }
    }

    WheelArea {
        id: wheelarea
        anchors.fill: parent
        property int scale: 5
        horizontalMinimumValue: hscrollbar.minimumValue/scale
        horizontalMaximumValue: hscrollbar.maximumValue/scale
        verticalMinimumValue: vscrollbar.minimumValue/scale
        verticalMaximumValue: vscrollbar.maximumValue/scale

        verticalValue: contentY/scale
        horizontalValue: contentX/scale

        onVerticalValueChanged: {
// FIXME
//            if(!tree.blockUpdates) {
//                contentY = verticalValue * scale
//                vscrollbar.value = contentY
//            }
        }

        onHorizontalValueChanged: {
            // FIXME
//            if(!tree.blockUpdates) {
//                contentX = horizontalValue * scale
//                hscrollbar.value = contentX
//            }
        }
    }

    ScrollBar {
        id: hscrollbar
        orientation: Qt.Horizontal
        property int availableWidth: root.width - vscrollbar.width
        visible: contentWidth > availableWidth && !root.forceHscrollbarHiding
        maximumValue: contentWidth > availableWidth ? tree.contentWidth - availableWidth : 0
        minimumValue: 0
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: frameWidth
        anchors.bottomMargin: styleitem.frameoffset
        anchors.rightMargin: vscrollbar.visible ? scrollbarExtent : (frame ? 1 : 0)
        onValueChanged: {
            if (!tree.blockUpdates)
                contentX = value;
        }
        property int scrollbarExtent : styleitem.pixelMetric("scrollbarExtent");
    }

    ScrollBar {
        id: vscrollbar
        property int oldValue: value
        orientation: Qt.Vertical
        // We cannot bind directly to tree.height due to binding loops so we have to redo the calculation here
        property int availableHeight : root.height - (hscrollbar.visible ? hscrollbar.height : 0) - tableColumn.height
        visible: !root.forceVscrollbarHiding// FIXME contentHeight > availableHeight && !root.forceVscrollbarHiding
        maximumValue: tree.count - 1//contentHeight > availableHeight ? tree.contentHeight - availableHeight : 0
        minimumValue: 0
        anchors.rightMargin: styleitem.frameoffset
        anchors.right: parent.right
        anchors.top: tableColumn.bottom//parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: styleitem.style == "mac" ? tableColumn.height : 0
        onValueChanged: {
            if(!tree.blockUpdates) {
                root.changePosition(value, ListView.Beginning, true);
            }
        }
        anchors.bottomMargin: hscrollbar.visible ? hscrollbar.height :  styleitem.frameoffset

//        Keys.onUpPressed: if (value > 0) value -= 1;
//        Keys.onDownPressed: if (value < maximumValue) value += 1;
    }

    QStyleItem {
        z: 2
        anchors.fill: parent
        anchors.margins: -4
        visible: highlightOnFocus && parent.activeFocus && styleitem.styleHint("focuswidget")
        elementType: "focusframe"
    }

    QStyleItem {
        id: styleitem
        elementType: "header"
        visible:false
        property int frameoffset: style === "mac" ? -1 : 0
    }
    QStyleItem {
        id: rowstyleitem
        elementType: "item"
        visible:false
        property color textColor: styleHint("textColor")
        property color highlightedTextColor: styleHint("highlightedTextColor")
    }
    SystemPalette{id:palette}
}
