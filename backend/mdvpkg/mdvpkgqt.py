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
##
## Author(s): J. Victor Martins <jvdm@mandriva.com>
##            Paulo Belloni <paulo@mandriva.com>
##
##
""" mdvpkg API for Mandriva Application Manager. """

import dbus
import dbus.mainloop.glib
from PySide import QtCore
import sys
from operator import attrgetter
from sets import Set
sys.path.append('/usr/share/mandriva/mdvpkg')
import mdvpkg
from exceptions import AsynchronousCallError
from package import Package

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

# Application status:
STATUS_NOT_INSTALLED = 'Not-Installed'
STATUS_INSTALLED = 'Installed'
STATUS_UPGRADABLE = 'Upgradable'
STATUS_IN_PROGRESS = 'In-Progress'

# Action step definitions:
ACTION_DOWNLOAD_STEP = 'DOWNLOAD'
ACTION_INSTALL_STEP = 'INSTALL'
ACTION_REMOVE_STEP = 'REMOVE'

# List of medias that are considered part of Mandriva's Software
# source:
MANDRIVA_MEDIAS = ('Main', 'Main Updates', 
                       'Main Testing', 'Main Backports')

# TODO The frontend should take only those details it needs on
# the different scenarios
PACKAGE_DETAIL_ATTRIBUTES = (
    'version',
    'release',
    'epoch',
    'size',
    'group',
    'summary',
    'media',
    'installtime',
    'distepoch',
    'disttag',
    'progress',
#    'requires',
#    'provides',
#    'conflict',
#    'obsoletes'
)


class DbusProxy:
    bus = None

    @staticmethod
    def initiateDbus(bus = dbus.SystemBus()):
        DbusProxy.bus = bus

    @staticmethod
    def createInterface(interface = mdvpkg.IFACE,
                        path = mdvpkg.PATH):
        obj = DbusProxy.bus.get_object(mdvpkg.SERVICE, path)
        return dbus.Interface(obj, interface)


class DaemonProxy(QtCore.QObject):

    def __init__(self, parent):
        super(DaemonProxy, self).__init__(parent)
        self.taskCount = 0
        self.currentTask = None
        self._mainIface = DbusProxy.createInterface()
        signals = {
            'TaskRunning': self._on_task_running,
            'TaskProgress': self._on_task_progress,
            'TaskDone': self._on_task_done,
        }
        for signal, slot in signals.iteritems():
            self._mainIface.connect_to_signal(signal, slot)

    task_started = QtCore.Signal(str)
    task_progress = QtCore.Signal(str, int, int)
    task_done = QtCore.Signal(str)

    def _on_task_running(self, task_id):
        self.currentTask = task_id
        self.task_started.emit(task_id)

    def _on_task_progress(self, task_id, count, total):
        self.task_progress.emit(task_id, int(count), int(total))

    def _on_task_done(self, task_id):
        self.taskCount -= 1
        self.task_done.emit(task_id)

    # This should be removed when mdvpkgd manages his life properly
    def release(self):
        try:
            #self._mainIface.Quit()
            pass
        except:
            pass   # Probably mdvpkgd is already dead

    def create_task(self, service, iface, *args):
        method = self._mainIface.get_dbus_method(service)
        try:
            path = method(args)
            return DbusProxy.createInterface(iface, path)
        except:
            raise


class PackageListProxy(QtCore.QObject):

    def __init__(self, parent, daemon):
        super(PackageListProxy, self).__init__(parent)
        self._count = None
        self._result = {}
        self._daemon = daemon
        self._proxy = daemon.create_task('GetList', mdvpkg.PACKAGE_LIST_IFACE)
        self._groups_map = None
        self._populate_groups()
        self._old_filters = {
            'name': lambda: None,
            'status': lambda: None,
            'media': lambda: None,
            'group': lambda: None,
        }
        signals = {
            'Error': self._on_error,
            'Package': self._on_package,
            'DownloadStart': self._on_download_start,
            'DownloadProgress': self._on_download_progress,
            'InstallProgress': self._on_install_progress,
            'RemoveStart': self._on_action_start,
            'RemoveProgress': self._on_remove_progress,
        }
        for signal, slot in signals.iteritems():
            self._proxy.connect_to_signal(signal, slot)

    def __iter__(self):
        for i in range(0, self.count):
            yield i, self.get_package(i)

    packages_removed = QtCore.Signal(int, int)
    action_started = QtCore.Signal(QtCore.QObject, str)
    download_progress = QtCore.Signal(QtCore.QObject, str, str, str, str, str)
    action_step_progress = QtCore.Signal(QtCore.QObject, str, str, str, str)

    def release(self):
        try:
            self._proxy.Delete()
        except:
            pass   # Probably mdvpkgd is already dead

    def run_filters(self,
                    patterns=[],
                    statuses=[],
                    sources=[],
                    categories=[]):
        filters = {
            'name': lambda: (patterns, []),
            'status': lambda: (statuses, []),
            'media': lambda: self._buildMediaFilter(sources),
            'group': lambda: self._buildGroupFilter(categories),
        }
        for f in filters:
            lists = filters[f]()
            olists = self._old_filters[f]()
            if (lists != olists):
                self._proxy.Filter(f, *lists)
            self._old_filters[f] = filters[f]
        self._refreshCount()

    def get_package(self, index):
        package = self._get_stored_package(index)
        if package is None:
            package = self._create_package(index)
        try:
            self._proxy.Get(index, PACKAGE_DETAIL_ATTRIBUTES)
        except IndexError:
            package = None  # Package was removed from list
        return package

    def install_package(self, index):
        return self._proxy.Install(index)

    def remove_package(self, index):
        return self._proxy.Remove(index)

    def cancel_action(self, index):
        self._proxy.NoAction(index,
                             reply_handler=lambda: None,
                             error_handler=self._on_async_error)

    def execute_action(self):
        try:
            self._proxy.ProcessActions()
            self._daemon.taskCount += 1
            return True
        except dbus.exceptions.DBusException as e:
            if e.get_dbus_name() == 'org.mandrivalinux.mdvpkg.AuthorizationFailed':
                return False
            else:
                raise e

    def sort(self, key, reverse=False):
        self._proxy.Sort(key, reverse)

    def _buildMediaFilter(self, sources):
        if not Set(sources).issubset(Set(('Mandriva', 'Community'))):
            raise ValueError('Unknown source: (%s)' % sources)
        filter_list = {True:[], False:[]}
        includeMandriva = 'Mandriva' in sources
        if sources:
            filter_list[includeMandriva] = MANDRIVA_MEDIAS
            filter_list[not includeMandriva] = []
        return filter_list[True], filter_list[False]

    def _buildGroupFilter(self, categories):
        filter_list = []
        if categories:
            cat = categories[0]
            if cat not in self._groups_map:
                raise ValueError, 'Unknown category: (%s)' % cat
            filter_list = list(self._groups_map[cat])
        return filter_list, []

    def _create_package(self, index):
        self._result[index] = Package(self, index)
        return self._result[index]

    def _store_package_data(self, index, data):
        for key in data:
            data[key] = unicode(data[key])
        self._result[index].set_data(**data)

    def _get_stored_package(self, index):
        return self._result.get(index)

    def _on_error(self, code, message):
        raise ValueError, "===> ERROR RECEIVED: Code=%s Message=%s" % (code, message)

    def _on_package(self, index, name, arch, mdvpkg_status, action, details):
        status = self._convert_status(mdvpkg_status)
        if details['media'] in MANDRIVA_MEDIAS:
            source = 'Mandriva'
        else:
            source = 'Community'
        group_folder = details['group'].split('/')[0]
        for (category, folders_set) in self._groups_map.iteritems():
            if group_folder in folders_set:
                break
            else:
                category = 'System'
        data = {
            'name' : name,
            'version' : details['version'],
            'release' : details['release'],
            'arch' : arch,
            'summary' : details['summary'],
            'category' : category,
            'source' : source,
            'group' : details['group'],
            'media' : details['media'],
            'status' : status,
#            'description' : details['description'],
            'size' : details['size'],
            'installtime' : details['installtime'],
            'distepoch' : details['distepoch'],
            'disttag' : details['disttag'],
            'action' : action,
            'action_progress' : details['progress'],
        }
        self._store_package_data(int(index), data)

    def _check_valid_signal(self, task_id, index):
        if not self._valid_pa_signal(task_id):
            return None
        if isinstance(index, int):
            package = self._result.get(index)
        else:
            package = self._create_package(None)
            package.name = index[0]    # name
            package.version = index[1] # version
            package.release = index[2] # release
            package.arch = index[3]    # arch
        return package

    def _on_download_start(self, task_id, index):
        self._on_action_start(task_id, index, None, None)

    def _on_download_progress(self, task_id, index, percent, total, eta, speed):
        package = self._check_valid_signal(task_id, index)
        if not package:
            return
        package.action_progress = float(percent)/100 * 0.5
        self.download_progress.emit(package, ACTION_DOWNLOAD_STEP, task_id, total, eta, speed)

    def _on_install_progress(self, *args):
        progress_calc = lambda progress: 0.5 * (1.0 + progress)
        self._on_action_progress(ACTION_INSTALL_STEP, progress_calc, *args)

    def _on_remove_progress(self, *args):
        self._on_action_progress(ACTION_REMOVE_STEP, lambda progress: progress, *args)

    def _on_action_start(self, task_id, index, total, count):
        package = self._check_valid_signal(task_id, index)
        if not package:
            return
        self.action_started.emit(package, task_id)

    def _on_action_progress(self, step, progress_calc, task_id, index, amount, total):
        package = self._check_valid_signal(task_id, index)
        if not package:
            return
        old_progress = package.action_progress
        package.action_progress = progress_calc(float(amount)/float(total))
        self.action_step_progress.emit(package, step, task_id, amount, total)

    def _convert_status(self, mdvpkg_status):
        if mdvpkg_status == 'new':
            return STATUS_NOT_INSTALLED
        elif mdvpkg_status == 'installed':
            return STATUS_INSTALLED
        elif mdvpkg_status == 'upgrade':
            return STATUS_UPGRADABLE
        else:
            return STATUS_IN_PROGRESS

    def _populate_groups(self):
        self._groups_map = {
            'Accessories': set(('Accessibility',
                               'Archiving',
                               'Editors',
                               'File tools',
                               'Text tools')),
            'Development': set(('Development',)),
            'Education': set(('Education',)),
            'Games': set(('Games', 'Toys')),
            'Internet': set(('Networking', 'Communications')),
            'Office': set(('Office', 'Publishing')),
            'Multimedia': set(('Video', 'Sound', 'Graphics')),
            'Sciences': set(('Sciences',)),
            'System': set()
        }
        self._proxy.connect_to_signal('Group', self._on_group)
        self._proxy.GetAllGroups()

    def _on_group(self, group, count):
        folder = group.split('/')[0]
        for folder_set in self._groups_map.values():
            if folder in folder_set:
                return
        self._groups_map['System'].add(folder)

    def _on_async_error(self, error):
        raise AsynchronousCallError(-1, 'Error on calling Process Actions: (%s)' % str(error))

    def _valid_pa_signal(self, pa_id):
        return pa_id == self._daemon.currentTask

    # count property ---------------------------------------------
    def _refreshCount(self):
        self._count = int(self._proxy.Size())

    def _get_count(self):
        if not self._count or self._daemon.taskCount > 0:
            self._refreshCount()
        return self._count

    count = QtCore.Property(int, _get_count)
