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
import logging

__author__  = "Paulo Belloni <paulo@mandriva.com>"
__state__   = "development"
__version__ = "0.1.0"

MANDRIVA_DATA_DIR = '/usr/share/mandriva'
DEFAULT_MAM_DIR = '%s/mam' % MANDRIVA_DATA_DIR

if os.environ['MAM_ROOT_DIR']:
    MAM_ROOT_DIR = os.environ['MAM_ROOT_DIR']
else:
    MAM_ROOT_DIR = DEFAULT_MAM_DIR

MAM_BACKEND_DIR = '%s/backend' % MAM_ROOT_DIR
MAM_COMPONENTS_DIR = '%s/components' % MAM_ROOT_DIR
MAM_FRONTEND_DIR = '%s/frontend' % MAM_ROOT_DIR
MAM_QML_DIR = '%s/qml' % MAM_FRONTEND_DIR
MAM_IMAGES_DIR = '%s/images' % MAM_FRONTEND_DIR
MAM_CONFIG_DIR = '%s/config' % MAM_FRONTEND_DIR

logger = logging.getLogger(__name__)
#try:
#    _syslog = logging.handlers.SysLogHandler(
#                  address="/dev/log",
#                  facility=logging.handlers.SysLogHandler.LOG_DAEMON
#              )
#    _syslog.setLevel(logging.INFO)
#    _formatter = logging.Formatter("%(name)s: %(levelname)s: "
#                                       "%(message)s")
#    _syslog.setFormatter(_formatter)
#except:
#    pass
#else:
#    logger.addHandler(_syslog)

_console = logging.StreamHandler()
_formatter = logging.Formatter("%(asctime)s %(name)s [%(levelname)s]: "
                                   "%(message)s",
                               "%T")
_console.setFormatter(_formatter)
logger.addHandler(_console)
