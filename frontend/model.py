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
from backend.mdvpkg.mdvpkgqt import Package, MdvPkgResult

logger = logging.getLogger(__name__)

class packageModel(QtCore.QAbstractListModel):
    COLUMNS = ('package',)
    DEFAULT_SEARCH = {'filters':{}, 'sort': None}
    NULL_PACKAGE=Package(None, 0)

    def __init__(self, controller):
        super(packageModel, self).__init__(controller)
        self.setRoleNames(dict(enumerate(packageModel.COLUMNS)))
        self._controller = controller
        self._count = 0
        self._searchData = None
        self._result = MdvPkgResult(self)
        self._result.result_ready.connect(self._on_result_ready)

    def search(self, searchData):
        if searchData == self._searchData:
            return
        self._searchData = searchData
        self._result.run_filters(**self._searchData['filters'])

    def _on_result_ready(self):
        self._count = self._result.count
        sort = self._searchData['sort']
        if  sort and sort[0]:
            self._result.sort(*sort)
        self._totalOfMatches_changed.emit()
        self.modelReset.emit()

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
