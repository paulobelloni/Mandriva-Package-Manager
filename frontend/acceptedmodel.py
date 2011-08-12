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

class AcceptedPackageModel(QtCore.QAbstractListModel):
    COLUMNS = ('package',)

    def __init__(self, parent, acceptedList):
        super(AcceptedPackageModel, self).__init__(parent)
        self.setRoleNames(dict(enumerate(AcceptedPackageModel.COLUMNS)))
        self._acceptedList = sorted([ NVRA(self, *pkg) for pkg in acceptedList if pkg ],
                                    key=lambda pkg: pkg.name)

    def rowCount(self, parent=QtCore.QModelIndex()):
        return len(self._acceptedList)

    def data(self, index, role):
        if index.isValid() and role == AcceptedPackageModel.COLUMNS.index('package'):
            return self._acceptedList[index.row()]
        return None

    _nfy_count = QtCore.Signal()

    count = QtCore.Property(int, rowCount, notify=_nfy_count)
