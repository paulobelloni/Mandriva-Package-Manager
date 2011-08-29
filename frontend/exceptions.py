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

import sys, traceback
from PySide import QtCore, QtGui

class ExceptionQtWrapper(QtCore.QObject):

    def __init__(self, parent, exception):
        super(ExceptionWrapper, self).__init__(parent)
        self._exception = exception

    _nfy_change = QtCore.Signal()

    # name attribute ------------
    def _get_name(self):
        return self._exception.name

    name = QtCore.Property(unicode, _get_name, notify=_nfy_change)

    # message attribute ------------
    def _get_message(self):
        return self._exception.message

    message = QtCore.Property(unicode, _get_message, notify=_nfy_change)


class MPMException(Exception):
    """ Exception for mdvpkg errors. """

    def __init__(self, name, message = None):
        super(MPMException, self).__init__()
        self.name = name
        self.message = message

class AuthorizationFailed(MPMException):
    """ Exception to indicate when authorization via PolicyKit has failed. """

class FinalException(MPMException):
    """ Exception for mdvpkg errors. """

    def __init__(self, name, message = None):
        super(FinalException, self).__init__(name, message)
        self.showException()

    def showException(self):
        details = repr(traceback.format_exception(*sys.exc_info()))
        msgBox = QtGui.QMessageBox()
        try:
            raise self
        except NoServerResponse as e:
            msgBox.setText("mdvpkgd is not responding! (%s)" % e.name)
            details = "Exception Name:  '%s'\n\nMessage:  '%s'\n\n%s" % \
                        (e.name, str(e.message), details)
        except FinalException as e:
            msgBox.setText("A mpm/mdvpkg error was found! (%s)" % e.name)
            details = "Exception Name:  '%s'\n\nMessage:  '%s'\n\n%s" % \
                        (e.name, str(e.message), details)
        except:
            msgBox.setText("An error was found!")
        finally:
            msgBox.setInformativeText("MPM needs to be closed.")
            msgBox.setDetailedText(details)
            msgBox.exec_()
            quit()

class ExceptionWrapper(FinalException):
    def __init__(self, e):
        super(ExceptionWrapper, self).__init__(sys.exc_info()[0], sys.exc_info()[1])

class DBusExceptionWrapper(FinalException):
    def __init__(self, e):
        if isinstance(e, tuple):
            super(DBusExceptionWrapper, self).__init__(e[0], e[1])
        else:
            super(DBusExceptionWrapper, self).__init__(e.get_dbus_name(), e.get_dbus_message())

class SynchronousCallError(DBusExceptionWrapper):
    """ Exception to indicate error during DBUS synchronous method calls. """

class AsynchronousCallError(DBusExceptionWrapper):
    """ Exception to indicate error during DBUS asynchronous method calls. """

class SignalError(DBusExceptionWrapper):
    """ Exception to indicate when mdvpkgd sends a signal error . """

class NoServerResponse(DBusExceptionWrapper):
    """ Exception to indicate when mdvpkgd is not responding . """

