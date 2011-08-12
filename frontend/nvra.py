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

logger = logging.getLogger(__name__)

class NVRA(QtCore.QObject):

    def __init__(self, parent, name, version, release, arch):
        super(NVRA, self).__init__(parent)
        self._name = name
        self._version = version
        self._release = release
        self._arch = arch

    _nfy_nvra_change = QtCore.Signal()

    # name attribute ------------
    def _get_name(self):
        return self._name

    name = QtCore.Property(unicode, _get_name, notify=_nfy_nvra_change)

    # version attribute ------------
    def _get_version(self):
        return self._version

    version = QtCore.Property(unicode, _get_version, notify=_nfy_nvra_change)

    # release attribute ------------
    def _get_release(self):
        return self._release

    release = QtCore.Property(unicode, _get_release, notify=_nfy_nvra_change)

    # arch attribute ------------
    def _get_arch(self):
        return self._arch

    arch = QtCore.Property(unicode, _get_arch, notify=_nfy_nvra_change)
