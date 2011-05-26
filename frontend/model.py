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
import os
import sys
import logging
from PySide import QtCore

import exceptions
import frontend
from backend.mdvpkg.mdvpkgqt import Package, MdvPkgResult, MdvPkgQt

logger = logging.getLogger(__name__)

class MpmPackage(Package):

    def __init__(self, parent, index):
        super(MpmPackage, self).__init__(parent, index)
        self._nfy_name.connect(self._nfy_icon)

    #FIXME: we need a better source for icons !!!!
    def _get_icon(self):
        iconName = self.name
        if not iconName or not os.path.exists(frontend.MPM_IMAGES_DIR + iconName):
            iconName = "default-icon.png"
        return iconName

    _nfy_icon = QtCore.Signal()

    icon = QtCore.Property(unicode, _get_icon, notify=_nfy_icon)


class MpmPkgResult(MdvPkgResult):
    def __init__(self, parent, task, useServerCache):
        super(MpmPkgResult, self).__init__(parent, task, useServerCache)

    def _create_package(self, idx):
        return MpmPackage(self, idx)


class MpmPkgQt(MdvPkgQt):
    def __init__(self, parent):
        super(MpmPkgQt, self).__init__(parent)

    def _create_result(self, task, useServerCache):
        return MpmPkgResult(self, task, useServerCache)


class packageModel(QtCore.QAbstractListModel):
    COLUMNS = ('package',)
    DEFAULT_SEARCH = {'filters':{}, 'sort': None}
    NULL_PACKAGE=MpmPackage(None, 0)

    def __init__(self, controller):
        super(packageModel, self).__init__(controller)
        self.setRoleNames(dict(enumerate(packageModel.COLUMNS)))
        self._controller = controller
        self._result = None
        self._count = 0
        self._searchData = packageModel.DEFAULT_SEARCH
        self._initiatePackageSource()

    def _initiatePackageSource(self):
        self._packageSource = MpmPkgQt(self)
        self._packageSource.mdvpkgqt_ready.connect(self._on_mdvpkgqt_ready)
        self._packageSource.start()

    @QtCore.Slot()
    def _on_mdvpkgqt_ready(self):
        self._getResult()

    @QtCore.Slot()
    def _on_result_ready(self):
        self._count = self._result.count
        if self._searchData['sort']:
            self._result.sort(self._searchData['sort'])
        self._totalOfMatches_changed.emit()
        self.modelReset.emit()
        self._controller.target_list.resetList()

    def search(self, searchData):
        if searchData == self._searchData:
            return
        self._controller.target_list.resetList() # reinforcing the reset, but still getting frozen window
        self._result.result_ready.disconnect()
        self._result.release()
        self._searchData = searchData
        self._getResult()

    def _getResult(self):
        self._result = \
            self._packageSource.list_packages(useServerCache=True,
                                                **self._searchData['filters'])
        self._result.result_ready.connect(self._on_result_ready)
        self._result.run()

    _totalOfMatches_changed = QtCore.Signal()

    def _get_totalOfMatches(self):
        return self._count

    def rowCount(self, parent=QtCore.QModelIndex()):
        return self._count

    def data(self, index, role):
        if index.isValid() and role == packageModel.COLUMNS.index('package'):
            idx = index.row()
            return self._result.get_package(idx) or packageModel.NULL_PACKAGE
        return None

    totalOfMatches = QtCore.Property(int, _get_totalOfMatches,
                                        notify=_totalOfMatches_changed)
