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
from PySide import QtCore

import logging
logger = logging.getLogger(__name__)

import exceptions
import frontend
from nvra import NVRA

INSTALL_UNSATISFIED = 'reject-install-unsatisfied'
INSTALL_CONFLICT = 'reject-install-conflict'
INSTALL_REJECTED_DEPENDENCY = 'reject-install-rejected-dependency'
REMOVE_DEPENDS = 'reject-remove-depends'
REMOVE_BASESYSTEM = 'reject-remove-basesystem'

# pyside/QML seems to not work well with model properties that present inheritance

class RejectionDetail(QtCore.QAbstractListModel):
    COLUMNS = ('detail',)

    def __init__(self, parent, _type, detail):
        super(RejectionDetail, self).__init__(parent)
        self.setRoleNames(dict(enumerate(RejectionDetail.COLUMNS)))
        if _type == INSTALL_UNSATISFIED:
            self._detailList = sorted([ str(cap) for cap in detail ])
        else:
            self._detailList = sorted([ NVRA(self, *pkg) for pkg in detail ],
                                        key=lambda pkg: pkg.name)

    def rowCount(self, parent=QtCore.QModelIndex()):
        return len(self._detailList)

    def data(self, index, role):
        if index.isValid() and role == RejectionDetail.COLUMNS.index('detail'):
            return self._detailList[index.row()]
        return None

    _nfy_count = QtCore.Signal()

    count = QtCore.Property(int, rowCount, notify=_nfy_count)


class Rejection(QtCore.QObject):

    def __init__(self, parent, rejected, _type, detail):
        super(Rejection, self).__init__(parent)
        self._package = NVRA(self, *rejected)
        self._type = str(_type)
        self._detail = RejectionDetail(self, _type, detail)

    _nfy_data_change = QtCore.Signal()

    # package attribute ------------
    def _get_package(self):
        return self._package

    package = QtCore.Property(QtCore.QObject, _get_package, notify=_nfy_data_change)

    # type attribute ------------
    def _get_type(self):
        return self._type

    type = QtCore.Property(str, _get_type, notify=_nfy_data_change)

    # detail attribute ------------
    def _get_detail(self):
        return self._detail

    detail = QtCore.Property(QtCore.QObject, _get_detail, notify=_nfy_data_change)


class RejectedPackageModel(QtCore.QAbstractListModel):
    COLUMNS = ('rejection',)

    def __init__(self, parent, rejectedList):
        super(RejectedPackageModel, self).__init__(parent)
        self.setRoleNames(dict(enumerate(RejectedPackageModel.COLUMNS)))
        self._rejectedList = sorted([ Rejection(self, *rej) for rej in rejectedList if rej ],
                                    key=lambda rej: rej.package.name)

    def rowCount(self, parent=QtCore.QModelIndex()):
        return len(self._rejectedList)

    def data(self, index, role):
        if index.isValid() and role == RejectedPackageModel.COLUMNS.index('rejection'):
            return self._rejectedList[index.row()]
        return None

    _nfy_count = QtCore.Signal()

    count = QtCore.Property(int, rowCount, notify=_nfy_count)
