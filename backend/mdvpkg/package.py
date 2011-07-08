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

from PySide import QtCore

class Package(QtCore.QObject):
    def __init__(self, parent, index):
        super(Package, self).__init__(parent)
        self._index = index
        self._name = None
        self._version = None
        self._release = None
        self._arch = None
        self._status = None
        self._source = None
        self._category = None
        self._media = None
        self._group = None
        self._summary = None
        self._description = None
        self._size = None
        self._installtime = None
        self._distepoch = None
        self._action = None
        self._progress = 1.0
        self._nfy_name.connect(self._nfy_fullname)
        self._nfy_version.connect(self._nfy_fullname)
        self._nfy_release.connect(self._nfy_fullname)
        self._nfy_arch.connect(self._nfy_fullname)

    # Set attributes based on args -----
    def set_data(self, **kwargs):
        for key, value in kwargs.iteritems():
            if self.__dict__['_'+key] != value:
                self.__dict__['_'+key] = value
                eval('self._nfy_'+key+'.emit()')

    # index attribute ----------
    def _get_index(self):
        return self._index

    index = QtCore.Property(int, _get_index)

    # name attribute ------------
    def _set_name(self, value):
        if (self._name != value):
            self._name = value
            self._nfy_name.emit()

    def _get_name(self):
        return self._name

    _nfy_name = QtCore.Signal()

    name = QtCore.Property(unicode, _get_name, _set_name, notify=_nfy_name)

    # version attribute ------------
    def _set_version(self, value):
        if (self._version != value):
            self._version = value
            self._nfy_version.emit()

    def _get_version(self):
        return self._version

    _nfy_version = QtCore.Signal()

    version = QtCore.Property(unicode, _get_version, _set_version, notify=_nfy_version)

    # release attribute ------------
    def _set_release(self, value):
        if (self._release != value):
            self._release = value
            self._nfy_release.emit()

    def _get_release(self):
        return self._release

    _nfy_release = QtCore.Signal()

    release = QtCore.Property(unicode, _get_release, _set_release, notify=_nfy_release)

    # arch attribute ------------
    def _set_arch(self, value):
        if (self._arch != value):
            self._arch = value
            self._nfy_arch.emit()

    def _get_arch(self):
        return self._arch

    _nfy_arch = QtCore.Signal()

    arch = QtCore.Property(unicode, _get_arch, _set_arch, notify=_nfy_arch)

    # status attribute ------------
    def _set_status(self, value):
        if (self._status != value):
            self._status = value
            self._nfy_status.emit()

    def _get_status(self):
        return self._status

    _nfy_status = QtCore.Signal()

    status = QtCore.Property(unicode, _get_status, _set_status, notify=_nfy_status)

    # source attribute ------------
    def _set_source(self, value):
        if (self._source != value):
            self._source = value
            self._nfy_source.emit()

    def _get_source(self):
        return self._source

    _nfy_source = QtCore.Signal()

    source = QtCore.Property(unicode, _get_source, _set_source, notify=_nfy_source)

    # category attribute ------------
    def _set_category(self, value):
        if (self._category != value):
            self._category = value
            self._nfy_category.emit()

    def _get_category(self):
        return self._category

    _nfy_category = QtCore.Signal()

    category = QtCore.Property(unicode, _get_category, _set_category, notify=_nfy_category)

    # media attribute ------------
    def _set_media(self, value):
        if (self._media != value):
            self._media = value
            self._nfy_media.emit()

    def _get_media(self):
        return self._media

    _nfy_media = QtCore.Signal()

    media = QtCore.Property(unicode, _get_media, _set_media, notify=_nfy_media)

    # group attribute ------------
    def _set_group(self, value):
        if (self._group != value):
            self._group = value
            self._nfy_group.emit()

    def _get_group(self):
        return self._group

    _nfy_group = QtCore.Signal()

    group = QtCore.Property(unicode, _get_group, _set_group, notify=_nfy_group)

    # summary attribute ------------
    def _set_summary(self, value):
        if (self._summary != value):
            self._summary = value
            self._nfy_summary.emit()

    def _get_summary(self):
        return self._summary

    _nfy_summary = QtCore.Signal()

    summary = QtCore.Property(unicode, _get_summary, _set_summary, notify=_nfy_summary)

    # description attribute ------------
    def _set_description(self, value):
        if (self._description != value):
            self._description = value
            self._nfy_description.emit()

    def _get_description(self):
        return self._description

    _nfy_description = QtCore.Signal()

    description = QtCore.Property(unicode, _get_description, _set_description, notify=_nfy_description)

    # size attribute ------------
    def _set_size(self, value):
        if (self._size != value):
            self._size = value
            self._nfy_size.emit()

    def _get_size(self):
        return self._size

    _nfy_size = QtCore.Signal()

    size = QtCore.Property(unicode, _get_size, _set_size, notify=_nfy_size)

    # installtime attribute ------------
    def _set_installtime(self, value):
        if (self._installtime != value):
            self._installtime = value
            self._nfy_installtime.emit()

    def _get_installtime(self):
        return self._installtime

    _nfy_installtime = QtCore.Signal()

    installtime = QtCore.Property(unicode, _get_installtime, _set_installtime, notify=_nfy_installtime)

    # fullname attribute ----------
    def _get_fullname(self):
        return "%s-%s-%s.%s" % (self.name, self.version, self.release,
                                self.arch)

    _nfy_fullname = QtCore.Signal()

    fullname = QtCore.Property(unicode, _get_fullname, notify=_nfy_fullname)

    # distepoch attribute ------------
    def _set_distepoch(self, value):
        if (self._distepoch != value):
            self._distepoch = value
            self._nfy_distepoch.emit()

    def _get_distepoch(self):
        return self._distepoch

    _nfy_distepoch = QtCore.Signal()

    distepoch = QtCore.Property(unicode, _get_distepoch, _set_distepoch, notify=_nfy_distepoch)

    # action attribute ------------
    def _set_action(self, value):
        if (self._action != value):
            self._action = value
            self._nfy_action.emit()

    def _get_action(self):
        return self._action

    _nfy_action = QtCore.Signal()

    action = QtCore.Property(unicode, _get_action, _set_action, notify=_nfy_action)

    # progress attribute ------------
    def _set_progress(self, value):
        if (self._progress != value):
            self._progress = value
            self._nfy_progress.emit()

    def _get_progress(self):
        return self._progress

    _nfy_progress = QtCore.Signal()

    progress = QtCore.Property(float, _get_progress, _set_progress, notify=_nfy_progress)
