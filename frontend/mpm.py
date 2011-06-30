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
import os, errno
import logging
import locale
locale.setlocale(locale.LC_ALL, '')

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
        'statuses': 'statuses'
    }
    SORT_MAP={
        'Date': 'installtime',
        'Name': 'name',
        'Size': 'size'
    }

    def __init__(self, rootContext, window):
        super(MPMcontroller, self).__init__()
        self._window = window
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

        status = rawData.property('status')
        if  status and status[0] == '|':
            filters[MPMcontroller.FILTER_MAP['statuses']] = \
                status.split('|')[:-1] or None
        else:
            filters[MPMcontroller.FILTER_MAP['statuses']] = \
                (status,) or None

        sort = (MPMcontroller.SORT_MAP.get(rawData.property('sort')),
                rawData.property('sortDirection') == 'up')

        searchData = {
            'filters': filters,
            'sort'   : sort
        }
        self._model.search(searchData)

    def setRootObject(self, root):
        self._rootObj = root

    @QtCore.Slot(str, str)
    def store_config(self, file, data):
        try:
            os.makedirs(frontend.MPM_USER_CONFIG_DIR)
        except OSError, e:
            if e.errno != errno.EEXIST:
                raise

        with open(frontend.MPM_USER_CONFIG_DIR + file, 'w') as f:
            f.write(data);

    @QtCore.Slot(str, result=str)
    def restore_config(self, file):
        try:
            with open(frontend.MPM_USER_CONFIG_DIR + file, 'r') as f:
                return f.read();
        except:
            return ""

    @QtCore.Slot(int, result=str)
    def pretty_value(self, value):
        """Based on a recipe from Eugeni. Tks! :) """
        return locale.format("%d", value, grouping=True)

    @QtCore.Slot(int, int, result=str)
    def humanize_size(self, size, precision=1):
        """Return a humanized string representation of a number of size.
           Based on Doug Latornell's humanize_bytes recipes. Tks! :) """
        abbrevs = (
            (1<<50L, 'PB'),
            (1<<40L, 'TB'),
            (1<<30L, 'GB'),
            (1<<20L, 'MB'),
            (1<<10L, 'kB'),
            (1, 'bytes')
        )
        if size == 1L:
            return '1 byte'
        for factor, suffix in abbrevs:
            if size >= factor:
                break
        return '%.*f %s' % (precision, float(size) / factor, suffix)

    @QtCore.Slot(int, int, int, int)
    def moveWindow(self, x, y, px, py):
        newPoint = self._window.mapToGlobal(QtCore.QPoint(x, y))
        newPoint.setX(newPoint.x() - px)
        newPoint.setY(newPoint.y() - py)
        self._window.move(newPoint)

    @QtCore.Slot(int)
    def installPackage(self, index):
        self._model.installPackage(index)

    @QtCore.Slot(int)
    def upgradePackage(self, index):
        self._model.upgradePackage(index)

    @QtCore.Slot(int)
    def removePackage(self, index):
        self._model.removePackage(index)

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

    @QtCore.Slot(int, int)
    def setMinimumSize(self, width, height):
        self._window.setMinimumSize(width, height)

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

    @QtCore.Slot(result=str)
    def getRootDir(self):
        return frontend.MPM_FRONTEND_DIR

    cursor = QtCore.Property(str, _get_cursor,
                        _set_cursor, notify=_cursor_changed)


def start():
    mainQML = '%s/%s' % (frontend.MPM_QML_DIR,
                        os.path.basename(__file__.replace('.py', '.qml')))
    if not os.path.exists(mainQML):
        logger.critical('%s: "%s"' % (qsTr('QML file not found'), mainQML))
        quit()

    app = QtGui.QApplication(sys.argv)
    lang = locale.getlocale()[0]
    if lang != frontend.MPM_DEFAULT_LANG:
        translator = QtCore.QTranslator()
        idir = "%s/i18n" % frontend.MPM_FRONTEND_DIR
        ifile = "%s/mpm.%s" % (idir, lang)
        if translator.load(ifile, ":/"):
            app.installTranslator(translator)
        else:
            logger.warning("No translation for '%s' has been found." % lang)
    view = QtDeclarative.QDeclarativeView()
    view.setResizeMode(QtDeclarative.QDeclarativeView.SizeRootObjectToView)
    view.setWindowTitle("Mandriva Package Manager")

    rc = view.rootContext()
    mpm_controller = MPMcontroller(rc, view)
    rc.setContextProperty('mpmController', mpm_controller)
    view.setSource(mainQML)
    mpm_controller.setRootObject(view.rootObject())

    view.show()
    app.exec_()

if __name__ == '__main__':
    start()
