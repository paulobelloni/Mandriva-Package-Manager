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
logger = logging.getLogger(__name__)

import frontend
from backend.mdvpkg.mdvpkgqt import DaemonProxy

class TaskManager(QtCore.QObject):

    def __init__(self, parent):
        super(TaskManager, self).__init__(parent)
        self._processed = 0
        self._total = 0
        self._daemon = DaemonProxy(self)
        self._daemon.task_started.connect(self.taskStarted)
        self._daemon.task_progress.connect(self._onTaskProgress)
        self._daemon.task_done.connect(self.taskDone)

    taskStarted = QtCore.Signal(str)
    taskDone = QtCore.Signal(str)

    def release(self):
        self._daemon.release()

    @QtCore.Slot(str, int, int)
    def _onTaskProgress(self, task_id, count, total):
        self._total = total
        self._processed = count
        self._nfy_total.emit()
        self._nfy_processed.emit()

    # daemon (read-only, non-nfy) attribute ------------
    def _get_daemon(self):
        return self._daemon

    daemon = QtCore.Property(DaemonProxy, _get_daemon)

    # processed (read-only) attribute ------------
    def _get_processed(self):
        return self._processed

    _nfy_processed = QtCore.Signal()

    processed = QtCore.Property(int, _get_processed, notify=_nfy_processed)

    # total (read-only) attribute ------------
    def _get_total(self):
        return self._total

    _nfy_total = QtCore.Signal()

    total = QtCore.Property(int, _get_total, notify=_nfy_total)

    # progress (read-only) attribute ------------
    def _get_progress(self):
        if total > 0:
            return float(self._processed)/float(self._total)
        else:
            return 0.0

    _nfy_progress = QtCore.Signal()

    progress = QtCore.Property(float, _get_progress, notify=_nfy_progress)
