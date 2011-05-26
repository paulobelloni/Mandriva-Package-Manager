##
## Copyright (C) 2010-2011 Mandriva S.A <http://www.mandriva.com>
## All rights reserved
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU Lesser General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., or visit: http://www.gnu.org/.
##
## Author(s): Paulo Belloni <paulo@mandriva.com>
##
##
import sys
import os
import logging
from PySide import QtGui, QtCore
from PySide import QtDeclarative

import frontend
from model import packageModel

logger = logging.getLogger(__name__)

class MPMcontroller(QtCore.QObject):
    FILTER_MAP={
        'category': 'categories',
        'pattern': 'patterns',
        'sort': 'sort',
        'source': 'source',
        'statuses': 'statuses',
        'technical': 'includeTechnicalItems'
    }
    SORT_MAP={
        'Date': 'installtime',
        'Name': 'name',
        'Size': 'size'
    }

    def __init__(self, rootContext, window):
        super(MPMcontroller, self).__init__()
        self._window = window
        self._target_list = None
        self._model = packageModel(self)
        rootContext.setContextProperty('packageModel', self._model)

    @QtCore.Slot(QtCore.QObject)
    def search(self, rawData):
        filters = {}

        value = rawData.property('pattern')
        filters[MPMcontroller.FILTER_MAP['pattern']] = \
            [value] if value else None

        value = rawData.property('category')
        filters[MPMcontroller.FILTER_MAP['category']] = \
            [value] if value else None

        filters[MPMcontroller.FILTER_MAP['source']] = \
            rawData.property('source') or None

        filters[MPMcontroller.FILTER_MAP['statuses']] = \
            rawData.property('status').split('|')[:-1] or None

        filters[MPMcontroller.FILTER_MAP['technical']] = \
            rawData.property('technical') or None

        searchData = {
            'filters': filters,
            'sort'   : MPMcontroller.SORT_MAP.get(rawData.property('sort'))
        }
        self._model.search(searchData)

    def setRootObject(self, root):
        self._rootObj = root

    def _get_target_list(self):
        if not self._target_list:
            self._target_list = self._rootObj.findChild(QtCore.QObject, "target_list")
        return self._target_list

    @QtCore.Slot(int, int, int, int)
    def moveWindow(self, x, y, px, py):
        newPoint = self._window.mapToGlobal(QtCore.QPoint(x, y))
        newPoint.setX(newPoint.x() - px)
        newPoint.setY(newPoint.y() - py)
        self._window.move(newPoint)

    def _set_cursor(self, shape):
        if not shape:
            qt_shape = QtCore.Qt.ArrowCursor
        else:
            qt_shape = eval("QtCore." + shape)

        self._window.setCursor(QtGui.QCursor(qt_shape))
        self._cursor_changed.emit()

    _cursor_changed = QtCore.Signal()

    def _get_cursor(self):
        return self._window.cursor()

    @QtCore.Slot()
    def closeWindow(self):
        self._window.close()

    @QtCore.Slot()
    def minimizeWindow(self):
        self._window.showMinimized()

    @QtCore.Slot()
    def maximizeWindow(self):
        self._window.showMaximized()

    @QtCore.Slot()
    def restoreWindow(self):
        self._window.showNormal()

    def _toggleWindowFlag(self, flag):
        flags = self._window.windowFlags()
        flags ^= flag
        self._window.setWindowFlags(flags)
        self._window.show()

    @QtCore.Slot(QtCore.QPoint)
    def showSystemFrame(self, point):
        mouseY = self._window.mapToGlobal(point).y()
        pos = self._window.pos()
        frameY = self._window.frameGeometry().y()
        dif = (mouseY - pos.y())*3 # 3 is a heuristic adjust
        pos.setY(frameY - dif)
        self._window.move(pos)
        self._toggleWindowFlag(QtCore.Qt.FramelessWindowHint)

    @QtCore.Slot(QtCore.QPoint)
    def hideSystemFrame(self, point):
        self._toggleWindowFlag(QtCore.Qt.FramelessWindowHint)

    _nfy_frontendDir = QtCore.Signal()

    @QtCore.Slot()
    def _get_frontendDir(self):
        return frontend.MPM_FRONTEND_DIR

    cursor = QtCore.Property(str, _get_cursor,
                        _set_cursor, notify=_cursor_changed)

    frontendDir = QtCore.Property(str, _get_frontendDir, notify=_nfy_frontendDir)
    target_list = QtCore.Property(QtCore.QObject, _get_target_list)

def start():
    mainQML = '%s/%s' % (frontend.MPM_QML_DIR,
                        os.path.basename(__file__.replace('.py', '.qml')))
    if not os.path.exists(mainQML):
        logger.critical('QML file not found: "%s"' % mainQML)
        quit()

    app = QtGui.QApplication(sys.argv)
    window = QtGui.QMainWindow()
    view = QtDeclarative.QDeclarativeView()
    widget = QtGui.QWidget()
    view.setViewport(widget)
    window.setCentralWidget(view)
    view.setResizeMode(QtDeclarative.QDeclarativeView.SizeRootObjectToView)
    view.setWindowTitle("Mandriva Application Manager")

    rc = view.rootContext()
    mpm_controller = MPMcontroller(rc, window)
    rc.setContextProperty('mpmController', mpm_controller)

    view.setSource(mainQML)
    mpm_controller.setRootObject(view.rootObject())

    window.move(300,150)
    window.resize(900,600)
    window.setMinimumSize(900, 600)
    window.show()
    app.exec_()

if __name__ == '__main__':
    start()
