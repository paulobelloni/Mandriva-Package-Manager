// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., or visit: http://www.gnu.org/.
//
// Author(s): Paulo Belloni <paulo@mandriva.com>
//
//
import QtQuick 1.0

Item {
    property ListModel model: ListModel {
        ListElement {
            title: QT_TR_NOOP("Accessories")
            icon: "category-accessories.png"
        }
        ListElement {
            title: QT_TR_NOOP("Development")
            icon: "category-development.png"
        }
        ListElement {
            title: QT_TR_NOOP("Education")
            icon: "category-education.png"
        }
        ListElement {
            title: QT_TR_NOOP("Games")
            icon: "category-games.png"
        }
        ListElement {
            title: QT_TR_NOOP("Internet")
            icon: "category-internet.png"
        }
        ListElement {
            title: QT_TR_NOOP("Multimedia")
            icon: "category-multimedia.png"
        }
        ListElement {
            title: QT_TR_NOOP("Office")
            icon: "category-office.png"
        }
        ListElement {
            title: QT_TR_NOOP("Sciences")
            icon: "category-sciences.png"
        }
        ListElement {
            title: QT_TR_NOOP("System")
            icon: "category-system.png"
        }
    }
}
