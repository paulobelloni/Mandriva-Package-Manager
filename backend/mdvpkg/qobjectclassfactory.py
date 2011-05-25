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
## Author(s): Paulo Belloni <paulo@mandriva.com>
##
## NOTE: Based on the AutoQObject code found at:
##       http://developer.qt.nokia.com/wiki/Auto-generating_QObject_from_template_in_PySide
##       Adds: parent parameter
##

from PySide import QtCore
from PySide.QtCore import QMutex, QMutexLocker

def QObjectClassFactory(*class_def, **kwargs):
    class QObject_(QtCore.QObject):
        def __init__(self, parent, **kwargs):
            super(QObject_, self).__init__(parent)
            for key, val in class_def:
                self.__dict__['_'+key] = kwargs.get(key, val())

        def __repr__(self):
            values = ('%s=%r' % (key, self.__dict__['_'+key]) \
                    for key, value in class_def)
            return '<%s (%s)>' % (kwargs.get('name', 'QObject'), ', '.join(values))

        for key, value in class_def:
            def _get(key):
                def f(self):
                    return self.__dict__['_'+key]
                return f

            def _set(key):
                def f(self, value):
                    self.__dict__['_'+key] = value
                    self.__dict__['_nfy_'+key].emit()
                return f

            get = locals()['_get_'+key] = _get(key)
            set = locals()['_set_'+key] = _set(key)
            nfy = locals()['_nfy_'+key] = QtCore.Signal()

            locals()[key] = QtCore.Property(value, get, set, notify=nfy)

    return QObject_

