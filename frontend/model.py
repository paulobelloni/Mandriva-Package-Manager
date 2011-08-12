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
from backend.mdvpkg.mdvpkgqt import Package, PackageListProxy

logger = logging.getLogger(__name__)

class PackageModel(QtCore.QAbstractListModel):
    COLUMNS = ('package',)
    DEFAULT_SEARCH = {'filters':{}, 'sort': None}
    NULL_PACKAGE=Package(None, 0)

    def __init__(self, parent, taskMgr):
        super(PackageModel, self).__init__(parent)
        self.setRoleNames(dict(enumerate(PackageModel.COLUMNS)))
        self._last_count = 0
        self._searchData = None
        self._packageList = PackageListProxy(self, taskMgr)
        self._packageList.action_started.connect(self.actionStarted)
        self._packageList.download_progress.connect(self.downloadProgress)
        self._packageList.action_step_progress.connect(self.actionStepProgress)

    actionStarted = QtCore.Signal(QtCore.QObject, str)
    downloadProgress = QtCore.Signal(QtCore.QObject, str, str, str, str, str)
    actionStepProgress = QtCore.Signal(QtCore.QObject, str, str, str, str)

    def release(self):
        self._packageList.release()

    def search(self, searchData):
        if searchData == self._searchData:
            return
        self.beginResetModel()
        self._searchData = searchData
        self._packageList.run_filters(**self._searchData['filters'])
        sort = self._searchData['sort']
        if  sort and sort[0]:
            self._packageList.sort(*sort)
        self.endResetModel()

    def installPackage(self, index):
        return self._packageList.install_package(index)

    def removePackage(self, index):
        return self._packageList.remove_package(index)

    def cancelAction(self, index):
        self._packageList.cancel_action(index)

    def executeAction(self, index):
        if self._packageList.execute_action():
            self.refreshModel(index)
            return True
        else:
            return False

    def refreshModel(self, index = None):
        if self._last_count < self._packageList.count:
            self.modelReset.emit()
        elif index >= 0:
            if self._last_count > self._packageList.count:
                self.beginRemoveRows(QtCore.QModelIndex(), index, self._last_count - 1)
                self.endRemoveRows()
            elif index < self._last_count:
                self._packageList.get_package(index)

    def rowCount(self, parent=QtCore.QModelIndex()):
        count = self._packageList.count
        if count != self._last_count:
            self._last_count = count
            self._nfy_count.emit()
        return count

    def data(self, index, role):
        if index.isValid() and role == PackageModel.COLUMNS.index('package'):
            idx = index.row()
            return self._packageList.get_package(idx) or PackageModel.NULL_PACKAGE
        return None

    _nfy_count = QtCore.Signal()

    count = QtCore.Property(int, rowCount, notify=_nfy_count)


