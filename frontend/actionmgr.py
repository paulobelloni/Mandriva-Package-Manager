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

from taskmgr import TaskManager
from model import PackageModel
from acceptedmodel import AcceptedPackageModel
from rejectedmodel import RejectedPackageModel

class ActionManager(QtCore.QObject):
    FILTER_MAP={
        'category': 'categories',
        'pattern': 'patterns',
        'sort': 'sort',
        'source': 'sources',
        'statuses': 'statuses',
    }
    STATUS_MAP={
        'Installed': ['installed'],
        'Not installed': ['new'],
        'Upgradable': ['upgrade'],
        'In progress': ['installing', 'removing'],
    }
    SORT_MAP={
        'Date': 'installtime',
        'Name': 'name',
        'Size': 'size',
    }

    def __init__(self, controller):
        super(ActionManager, self).__init__(controller)
        self._actionsAllowed = True
        self._type = None
        self._target = None
        self._toInstall = None
        self._toRemove = None
        self._notInstallable = None
        self._notRemovable = None
        self._rejection = False
        self._progress_step = None
        self._progress_package = None
        self._progress_amount = None
        self._progress_total = None
        self._progress_eta = None
        self._progress_speed = None
        self._taskMgr = TaskManager(self)
        self._taskMgr.taskStarted.connect(self._onTaskStarted)
        self._taskMgr.taskDone.connect(self._onTaskDone)
        self._model = PackageModel(self, self._taskMgr.daemon)
        self._model.actionStarted.connect(self._onActionStarted)
        self._model.downloadProgress.connect(self._onDownloadProgress)
        self._model.actionStepProgress.connect(self._onActionStepProgress)
        self._model.search(PackageModel.DEFAULT_SEARCH)

    def release(self):
        self._taskMgr.release()
        self._model.release()

    @QtCore.Slot(QtCore.QObject)
    def search(self, rawData):
        filters = {}

        value = rawData.property('pattern')
        filters[ActionManager.FILTER_MAP['pattern']] = \
            [value] if value else []

        value = rawData.property('category')
        filters[ActionManager.FILTER_MAP['category']] = \
            [value] if value else []

        value = rawData.property('source')
        filters[ActionManager.FILTER_MAP['source']] = \
            [value] if value else []

        value = rawData.property('status')
        value = ActionManager.STATUS_MAP.get(value)
        filters[ActionManager.FILTER_MAP['statuses']] = \
            value if value else []

        value = rawData.property('sort')
        value = ActionManager.SORT_MAP.get(value)
        sort = (value, rawData.property('sortDirection') == 'up')

        searchData = {
            'filters': filters,
            'sort'   : sort
        }
        self._model.search(searchData)

    @QtCore.Slot(QtCore.QObject, result=bool)
    def installPackage(self, target):
        return self._processActionRequest(target, 'INSTALL',
                                self._model.installPackage)

    @QtCore.Slot(QtCore.QObject, result=bool)
    def upgradePackage(self, target):
        return self._processActionRequest(target, 'UPGRADE',
                                self._model.installPackage)

    @QtCore.Slot(QtCore.QObject, result=bool)
    def removePackage(self, target):
        return self._processActionRequest(target, 'REMOVE',
                                self._model.removePackage)

    @QtCore.Slot()
    def cancelAction(self):
        self._model.cancelAction(self._target.index)

    @QtCore.Slot()
    def executeAction(self):
        self._model.executeAction(self._target.index)

    def _processActionRequest(self, target, actionType, request):
        if self._actionsAllowed:
            self._type = actionType
            self._target = target
            result = request(target.index)
            self._toInstall, self._toRemove = \
                    [ AcceptedPackageModel(self, pkg) for pkg in result[:2] ]
            self._notInstallable, self._notRemovable = \
                    [ RejectedPackageModel(self, pkg) for pkg in result[2:] ]
            self._rejection = self._notInstallable.count + self._notRemovable.count > 0
            return not self._rejection
        return True

    _nfy_data_changed = QtCore.Signal()

    @QtCore.Slot(QtCore.QObject, str)
    def _onActionStarted(self, package, task_id):
        self._model.refreshModel(package.index)

    @QtCore.Slot(QtCore.QObject, str, str, str, str, str)
    def _onDownloadProgress(self, package, step, task_id, total, eta, speed):
        self._setProgressData(package=package, step=step, total=total, eta=eta, speed=speed)

    @QtCore.Slot(QtCore.QObject, str, str, str, str)
    def _onActionStepProgress(self, package, step, task_id, amount, total):
        self._setProgressData(package=package, step=step, amount=amount, total=total)
        if package.action_progress == 1.0:
            self._model.refreshModel(package.index)

    def _setProgressData(self, **data):
        self._progress_step = data['step']
        self._progress_package = data['package']
        self._progress_amount = data.get('amount')
        self._progress_total = data['total']
        self._progress_eta = data.get('eta')
        self._progress_speed = data.get('speed')
        self._nfy_progress_changed.emit()

    # actionsAllowed is an artificial and temporary mesure
    # till mdvpkg treat properly rejection. So, get rid of it
    # and those treatments when time comes or make use of a
    # customizable sequential configuration parameter.
    @QtCore.Slot(str)
    def _onTaskStarted(self, task_id):
        self.actionsAllowed = False

    @QtCore.Slot(str)
    def _onTaskDone(self, task_id):
        self.actionsAllowed = True
        self._model.refreshModel()

    # actionsAllowed (used to ensure sequential actions) attribute ------------
    def _get_actionsAllowed(self):
        return self._actionsAllowed

    def _set_actionsAllowed(self, value):
        if (self._actionsAllowed != value):
            self._actionsAllowed = value
            self._nfy_actionsAllowed.emit()

    _nfy_actionsAllowed = QtCore.Signal()

    actionsAllowed = QtCore.Property(bool, _get_actionsAllowed,
                        _set_actionsAllowed, notify=_nfy_actionsAllowed)

    # model attribute ------------
    def _get_model(self):
        return self._model

    _nfy_model = QtCore.Signal()

    model = QtCore.Property(QtCore.QObject, _get_model, notify=_nfy_model)

    # taskMgr attribute ------------
    def _get_taskMgr(self):
        return self._taskMgr

    _nfy_taskMgr = QtCore.Signal()

    taskMgr = QtCore.Property(QtCore.QObject, _get_taskMgr, notify=_nfy_taskMgr)

    # type (Action's type) attribute ------------
    def _get_type(self):
        return self._type

    type = QtCore.Property(str, _get_type, notify=_nfy_data_changed)

    # target (Action's target package) attribute ------------
    def _get_target(self):
        return self._target

    target = QtCore.Property(QtCore.QObject, _get_target, notify=_nfy_data_changed)

    # toInstall (Packages to be installed with the action) attribute ------------
    def _get_toInstall(self):
        return self._toInstall

    toInstall = QtCore.Property(QtCore.QObject, _get_toInstall, notify=_nfy_data_changed)

    # toRemove (Packages to be removed with the action) attribute ------------
    def _get_toRemove(self):
        return self._toRemove

    toRemove = QtCore.Property(QtCore.QObject, _get_toRemove, notify=_nfy_data_changed)

    # notInstallable (Packages not installable due to rejection with the action) attribute ------------
    def _get_notInstallable(self):
        return self._notInstallable

    notInstallable = QtCore.Property(QtCore.QObject, _get_notInstallable, notify=_nfy_data_changed)

    # notRemovable (Packages not removable due to rejection with the action) attribute ------------
    def _get_notRemovable(self):
        return self._notRemovable

    notRemovable = QtCore.Property(QtCore.QObject, _get_notRemovable, notify=_nfy_data_changed)

    # rejection (Indicates if there are rejection for the action) attribute ------------
    def _get_rejection(self):
        return self._rejection

    rejection = QtCore.Property(bool, _get_rejection, notify=_nfy_data_changed)

    # progress_step (Gives the current step being being executed for the action) attribute ------------
    def _get_progress_step(self):
        return self._progress_step

    _nfy_progress_changed = QtCore.Signal()

    progress_step = QtCore.Property(str, _get_progress_step, notify=_nfy_progress_changed)

    # progress_package (Gives the Package being processed for the current step) attribute ------------
    def _get_progress_package(self):
        return self._progress_package

    progress_package = QtCore.Property(QtCore.QObject, _get_progress_package, notify=_nfy_progress_changed)

    # progress_amount (Gives the progressed amount of bytes for the current step) attribute ------------
    def _get_progress_amount(self):
        return self._progress_amount

    progress_amount = QtCore.Property(str, _get_progress_amount, notify=_nfy_progress_changed)

    # progress_total (Gives the total of bytes for the current step) attribute ------------
    def _get_progress_total(self):
        return self._progress_total

    progress_total = QtCore.Property(str, _get_progress_total, notify=_nfy_progress_changed)

    # progress_eta (Gives the 'Estimated Time to Arrive' for current step) attribute ------------
    def _get_progress_eta(self):
        return self._progress_eta

    progress_eta = QtCore.Property(str, _get_progress_eta, notify=_nfy_progress_changed)

    # progress_speed (Gives the speed for the current step) attribute ------------
    def _get_progress_speed(self):
        return self._progress_speed

    progress_speed = QtCore.Property(str, _get_progress_speed, notify=_nfy_progress_changed)
