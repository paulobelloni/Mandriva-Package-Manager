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
## Changelog:
## (PBelloni) - Refactory to make it more QT oriented.
##              Added DbusProxy, MdvPkgProxy and MdvPkgGroups
##              classes. get_package is now asynchronous.
##              Added qtobjectfactory and class package
##              hierarchy. Results is now kept on a
##              dict, while still acquiring new data.
##              Added excludeTechnicalItems.
##
""" mdvpkg API for Mandriva Application Manager. """


import dbus
import dbus.mainloop.glib
from PySide import QtCore
import sys
from operator import attrgetter
sys.path.append('/usr/share/mandriva/mdvpkg')
import mdvpkg
import exceptions
from qobjectclassfactory import QObjectClassFactory

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

# Application status:
STATUS_NOT_INSTALLED = 'N'
STATUS_INSTALLED = 'I'
STATUS_UPGRADE = 'U'

# List of medias that are considered part of Mandriva's Software
# source:
MANDRIVA_MEDIAS = ('Main', 'Main Updates', 
                       'Main Testing', 'Main Backports')

# Groups chosen to be considered technicals
TECHNICAL_GROUPS = ('System/Libraries',)

class DbusProxy:
    bus = None

    @staticmethod
    def initiateDbus(bus = dbus.SystemBus()):
        DbusProxy.bus = bus

    @staticmethod
    def createInterface(interface = mdvpkg.DBUS_INTERFACE,
                        path = mdvpkg.DBUS_PATH):
        obj = DbusProxy.bus.get_object(mdvpkg.DBUS_SERVICE, path)
        return dbus.Interface(obj, interface)


PackageBase = QObjectClassFactory(
    ('name', str),
    ('version', str),
    ('release', str),
    ('arch', str),
    ('status', str),
    ('source', str),
    ('category', str),
    ('summary', str),
    ('description', str),
    ('size', str),
    ('install_time', str)
)

class Package(PackageBase):

    def __init__(self, parent, index):
        super(Package, self).__init__(parent)
        self._index = index
        self._nfy_name.connect(self._nfy_fullname)
        self._nfy_version.connect(self._nfy_fullname)
        self._nfy_release.connect(self._nfy_fullname)
        self._nfy_arch.connect(self._nfy_fullname)

    def set_data(self, **kwargs):
        for key, value in kwargs.iteritems():
            if self.__dict__['_'+key] != value:
                self.__dict__['_'+key] = value
                eval('self._nfy_'+key+'.emit()')

    def _get_index(self):
        return self._index

    def _get_fullname(self):
        return "%s-%s-%s.%s" % (self.name, self.version, self.release,
                                self.arch)

    _nfy_fullname = QtCore.Signal()

    index = QtCore.Property(int, _get_index)
    fullname = QtCore.Property(unicode, _get_fullname, notify=_nfy_fullname)


class MdvPkgResult(QtCore.QObject):
    """ A result class for mdvpkg calls. """

    def __init__(self, parent, task, useServerCache):
        QtCore.QObject.__init__(self, parent)
        self.count = 0
        self.error = None
        self.ready = False
        self._task = task
        self._useServerCache = useServerCache
        if not self._useServerCache:
            self._result = []
        else:
            self._result = {}

    def __del__(self):
        self.release()

    def __iter__(self):
        for i in range(0, self.count):
            yield i, self.get_package(i)

    result_ready = QtCore.Signal()
    result_finished = QtCore.Signal()

    def run(self):
        self._on_threadLoop_started()

    def release(self):
        """ Signal daemon we won't use the task anymore so it can
        release cache and remove task from bus.
        """
        self._task.Cancel()

    def get_package(self, idx):
        """ Returns the result at idx. """
        if not self.ready or idx >= self.count:
            return None
        if idx < 0:
            raise ValueError, "Got negative index:" + idx
        if self._useServerCache:
            package = self._get_stored_package(idx)
            if package is None:
                package = self._create_package(idx)
                self._store_package(package)
            self._task.Get(idx)
            return package
        else:
            return self._result[idx]
        
    def get_package_details(self, idx):
        """ If it's a cached list_packages result call GetDetails at
        idx.
        """
        if not self.ready or idx >= self.count:
            return None
        if idx < 0:
            raise ValueError, "Got negative index:" + idx
        if not self._useServerCache:
            raise ValueError, \
                "Can't use get_package_details in non-cached result."
        self._task.GetDetails(idx)

    def sort(self, key, reverse=False):
        """ Ask mdvpkg to sort packages and returns iterator. """
        self._task.Sort(key, reverse)
        if not self._useServerCache:
            return self.__iter__()

    def _create_package(self, idx):
        return Package(self, idx)

    def _store_package(self, package):
        if self._useServerCache:
            self._result[package.index] = package
        else:
            self._result.append(package)

    def _store_package_data(self, index, data):
        if not self._useServerCache:
            raise ValueError, \
                "Can't use _store_package_data in non-cached result."
        self._result[index].set_data(**data)

    def _get_stored_package(self, idx):
        if not self._useServerCache:
            raise ValueError, \
                "Can't use _get_stored_package in non-cached result."
        return self._result.get(idx)

    def _check_error(self):
        if self.error:
            raise MdvPkgError(self.error)

    def _on_threadLoop_started(self):
        signals = { 'Package': self._on_package,
                    'PackageDetails': self._on_package_details,
                    'Ready': self._on_ready,
                    'Error': self._on_error,
                    'Finished': self._on_finished,
                    'StatusChanged' : self._on_status_changed}
        for signal, slot in signals.iteritems():
            self._task.connect_to_signal(signal, slot)
        self._task.Run()

    #FIXME - have to verify status
    def _on_status_changed(self, status):
        self._check_error()

    #FIXME - have to verify status
    def _on_finished(self, status):
        self._check_error()
        self.count = len(self._result)
        self.result_finished.emit()

    def _on_ready(self, count):
        self._check_error()
        self.count = count
        self.ready = True
        self.result_ready.emit()

    def _on_package(self, index, nvra, summary, status, media, group, updates):
        self._check_error()
        name, version, release, arch = nvra
        has_upgrades, has_downgrades = updates
        if media in MANDRIVA_MEDIAS:
            source = 'Mandriva'
        else:
            source = 'Community'
        group_folder = group.split('/')[0]
        for (category, folders_set) in MdvPkgQt.groups:
            if group_folder in folders_set:
                category = category
                break
            else:
                category = 'System'
        data = {
            'name' : name,
            'version' : version,
            'release' : release,
            'arch' : arch,
            'summary' : summary,
            'category' : category,
            'source' : source,
            'status' : self._get_status(status, has_upgrades)
        }
        self._store_package_data(index, data)

    def _on_package_details(self, index, details):
        self._check_error()
        if details['media'] in MANDRIVA_MEDIAS:
            source = 'Mandriva'
        else:
            source = 'Community'
        group_folder = details['group'].split('/')[0]
        for (category, folders_set) in MdvPkgQt.groups:
            if group_folder in folders_set:
                category = category
                break
            else:
                category = 'System'
        status = self._get_status(details['status'],
                                  details['has_upgrades'])
        data = {
            'status' : status,
            'source' : source,
            'category' : category,
            'description' : details['description'],
            'size' : details['size'],
            'install_time' : details['installtime']
        }
        self._store_package_data(index, data)

    def _on_error(self, code, message):
        self.error = (code, message)

    def _get_status(self, mdvpkg_status, has_upgrades):
        if mdvpkg_status == 'new':
            return STATUS_NOT_INSTALLED
        else:
            if has_upgrades:
                return STATUS_UPGRADE
            else:
                return STATUS_INSTALLED


class MdvPkgProxy(QtCore.QObject):
    taskFactory = None

    class MdvTaskFactory():

        def __init__(self):
            self.mainIface = DbusProxy.createInterface()

        def getTaskIface(self, taskName, *args):
            """ Returns the d-bus interface object for the task. """
            method = self.mainIface.get_dbus_method(taskName)
            try:
                task_path = method(*args)
                return DbusProxy.createInterface(mdvpkg.DBUS_TASK_INTERFACE, task_path)
            except:
                raise

    def __init__(self, parent):
        super(MdvPkgProxy, self).__init__(parent)
        self.error = None
        if MdvPkgProxy.taskFactory is None:
            MdvPkgProxy.taskFactory = MdvPkgProxy.MdvTaskFactory()
        MdvPkgProxy.taskFactory.mainIface.connect_to_signal('Error', self._on_error)

    def create_task(self, taskName, *args):
        return MdvPkgProxy.taskFactory.getTaskIface(taskName, *args)

    def _on_error(self, msg):
        self.error = msg
     

class MdvPkgQt(MdvPkgProxy):
    groups = None

    class MdvPkgGroups(MdvPkgProxy):

        def __init__(self, parent):
            """ Returns a new instance. """
            super(MdvPkgQt.MdvPkgGroups, self).__init__(parent)
            self.groups_map = {
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
            self._task = self.create_task('ListGroups')
            self._task.connect_to_signal('Group', self._on_group)
            self._task.connect_to_signal('Finished', self._on_finished)

        def __iter__(self):
            for m in self.groups_map.iteritems():
                yield m

        def run(self):
            self._task.Run()

        groups_ready = QtCore.Signal()

        def _on_group(self, group, count):
            folder = group.split('/')[0]
            for folder_set in self.groups_map.values():
                if folder in folder_set:
                    return
            self.groups_map['System'].add(folder)

        #FIXME: We need to verify status
        def _on_finished(self, status):
            if self.error:
                raise MdvPkgError(self.error)
            self.groups_ready.emit()

    def __init__(self, parent):
        super(MdvPkgQt, self).__init__(parent)
        if MdvPkgQt.groups is None:
            MdvPkgQt.groups = MdvPkgQt.MdvPkgGroups(self)
        MdvPkgQt.groups.groups_ready.connect(self._on_groups_ready)

    mdvpkgqt_ready = QtCore.Signal()

    @QtCore.Slot()
    def _on_groups_ready(self):
        self.mdvpkgqt_ready.emit()

    def _create_result(self, task, useServerCache):
        return MdvPkgResult(self, task, useServerCache)

    def start(self):
        MdvPkgQt.groups.run()

    def list_packages(self,
                        patterns=None,
                        statuses=None,
                        source=None,
                        categories=None,
                        includeTechnicalItems=None,
                        useServerCache=False):
        task = self.create_task('ListPackages')
        if useServerCache:
            task.SetCached()
        if patterns:
            task.FilterName(patterns, False)
        if statuses:
            for status in statuses:
                if status == STATUS_INSTALLED:
                    task.FilterInstalled(False)
                if status == STATUS_NOT_INSTALLED:
                    task.FilterNew(False)
                if status == STATUS_UPGRADE:
                    task.FilterUpgrade(False)                
        if source:
            if source not in ('Mandriva', 'Community'):
                raise ValueError('Unknown source: (%s)' % source)
            task.FilterMedia(MANDRIVA_MEDIAS, source != 'Mandriva')
        if categories:
            for cat in categories:
                if cat not in MdvPkgQt.groups.groups_map:
                    raise ValueError, 'Unknown category: (%s)' % cat
                filter_list = list(MdvPkgQt.groups.groups_map[cat])
                task.FilterGroup(filter_list, False)
        if not includeTechnicalItems:
            task.FilterGroup(TECHNICAL_GROUPS, True)
        return self._create_result(task, useServerCache)
