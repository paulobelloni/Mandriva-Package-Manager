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
##     NOTES:
## (PBelloni) - Refactory to make it more QT oriented.
##              Added DbusProxy, MdvPkgProxy and MdvPkgGroups
##              classes. get_package is now asynchronous.
##              Added qtobjectfactory (*) and class package
##              hierarchy. Results is now kept on a
##              dict, while still acquiring new data.
##              Added excludeTechnicalItems.
##              (*) It is substituted by package module
##              due to some issues about inheritance we
##              have found. It is under investigation.
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
import exceptions
from package import Package

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

# Application status:
STATUS_NOT_INSTALLED = 'Not-Installed'
STATUS_INSTALLED = 'Installed'
STATUS_UPGRADABLE = 'Upgradable'
STATUS_IN_PROGRESS = 'In-Progress'

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


class MdvPkgResult(QtCore.QObject):
    """ A result class for mdvpkg calls. """

    def __init__(self, parent):
        super(MdvPkgResult, self).__init__(parent)
        self._result = {}
        self.count = None
        self._pkg_list = PackageList(self)
        signals = {
            'Package': self._on_package,
        }
        for signal, slot in signals.iteritems():
            self._pkg_list.proxy.connect_to_signal(signal, slot)

    def __del__(self):
        self.release()

    def __iter__(self):
        for i in range(0, self.count):
            yield i, self.get_package(i)

    result_ready = QtCore.Signal()

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
            if cat not in PackageList.groups.groups_map:
                raise ValueError, 'Unknown category: (%s)' % cat
            filter_list = list(PackageList.groups.groups_map[cat])
        return filter_list, []

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
            self._pkg_list.proxy.Filter(f, *lists)
        self._pkg_list.proxy.Size(reply_handler=self._on_size_reply,
                                  error_handler=self._on_size_error)

    def release(self):
        self._pkg_list.proxy.Delete()

    def _check_valid_request(self, action, idx):
        if idx < 0 or idx >= self.count:
            raise ValueError, "Got invalid index (%d) for %s request" % (idx, action)

    def install_package(self, idx):
        """ Install package at idx. """
        self._check_valid_request('install', idx)
#        self._pkg_list.proxy.Install(idx)

    def upgrade_package(self, idx):
        """ Upgrade package at idx. """
        self._check_valid_request('upgrade', idx)
#        self._pkg_list.proxy.Upgrade(idx)

    def remove_package(self, idx):
        """ Remove package at idx. """
        self._check_valid_request('remove', idx)
#        self._pkg_list.proxy.Remove(idx)

    def get_package(self, idx):
        """ Returns the result at idx. """
        self._check_valid_request('get', idx)
        package = self._get_stored_package(idx)
        if package is None:
            package = self._create_package(idx)
            self._store_package(package)
        self._pkg_list.proxy.Get(idx, PACKAGE_DETAIL_ATTRIBUTES)
        return package
        
    def sort(self, key, reverse=False):
        """ Ask mdvpkg to sort packages and returns iterator. """
        self._pkg_list.proxy.Sort(key, reverse)

    def _create_package(self, idx):
        return Package(self, idx)

    def _store_package(self, package):
        self._result[package.index] = package

    def _store_package_data(self, index, data):
        self._result[index].set_data(**data)

    def _get_stored_package(self, idx):
        return self._result.get(idx)

    def _on_package(self, index, name, arch, mdvpkg_status, action, details):
        status = self._convert_status(mdvpkg_status)
        if details['media'] in MANDRIVA_MEDIAS:
            source = 'Mandriva'
        else:
            source = 'Community'
        group_folder = details['group'].split('/')[0]
        for (category, folders_set) in PackageList.groups:
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
        }
        for key in data:
            data[key] = unicode(data[key])
        self._store_package_data(index, data)

    def _convert_status(self, mdvpkg_status):
        if mdvpkg_status == 'new':
            return STATUS_NOT_INSTALLED
        elif mdvpkg_status == 'installed':
            return STATUS_INSTALLED
        elif mdvpkg_status == 'upgrade':
            return STATUS_UPGRADABLE
        else:
            return STATUS_IN_PROGRESS

    def _on_size_reply(self, size):
        self.count = int(size)
        self.result_ready.emit()

    def _on_size_error(self, error):
        raise ValueError('Fail to get package list size: (%s)' % str(error))


class MdvPkgProxy(QtCore.QObject):
    taskFactory = None

    class MdvTaskFactory():

        def __init__(self):
            self.mainIface = DbusProxy.createInterface()

        def getIface(self, service, iface, *args):
            """ Returns the d-bus interface object. """
            method = self.mainIface.get_dbus_method(service)
            try:
                path = method(args)
                return DbusProxy.createInterface(iface, path), path
            except:
                raise

    def __init__(self, parent):
        super(MdvPkgProxy, self).__init__(parent)
        if MdvPkgProxy.taskFactory is None:
            MdvPkgProxy.taskFactory = MdvPkgProxy.MdvTaskFactory()

    def create_task(self, service, *args):
        return MdvPkgProxy.taskFactory.getIface(service, mdvpkg.TASK_IFACE, *args)

    def create_package_list(self, *args):
        return MdvPkgProxy.taskFactory.getIface('GetList', mdvpkg.PACKAGE_LIST_IFACE, *args)

class PackageList(MdvPkgProxy):
    groups = None

    class MdvPkgGroups():

        def __init__(self, proxy):
            """ Returns a new instance. """
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
            proxy.connect_to_signal('Group', self._on_group)
            proxy.GetAllGroups()

        def __iter__(self):
            for m in self.groups_map.iteritems():
                yield m

        def _on_group(self, group, count):
            folder = group.split('/')[0]
            for folder_set in self.groups_map.values():
                if folder in folder_set:
                    return
            self.groups_map['System'].add(folder)

    def __init__(self, parent, **filters):
        super(PackageList, self).__init__(parent)
        self.proxy, path = self.create_package_list()
        self.uuid = path.split('/')[-1]
        if PackageList.groups is None:
            PackageList.groups = PackageList.MdvPkgGroups(self.proxy)
