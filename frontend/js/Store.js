//
// Copyright (C) 2010-2011 Mandriva S.A <http://www.mandriva.com>
// All rights reserved
//
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
//      NOTE: This code is based on the homonymous library
//            found at the Nokia examples site, see:
//            https://projects.developer.nokia.com/QMLRestaurantApp
//
.pragma library

Qt.include("Util.js")

function modelTOjson(model) {
    var json = "";
    for (var i=0; i < model.count; i++) {
        if (i > 0) {
            json += ',';
        }
        json += model.stringify(model.get(i));
    }

    json = '{"version":"' + model.version + '",'
         + '"attributes":[' + json + ']'
         + '}\n';

    return json;
}

function jsonTOmodel(version, json) {
    var data = JSON.parse(json);
    if (data.version == version)
        return data.attributes;
    else
        return null;
}

function storeModel(model, jsonSetter) {
    jsonSetter(modelTOjson(model));
}

function restoreModel(model, jsonGetter) {
    var json = jsonGetter();
    if (json != "") {
        var attributes = jsonTOmodel(model.version, json);
        if (attributes) {
            model.clear();
            for (var i = 0; i < attributes.length; i++) {
                model.append(attributes[i]);
            }
        }
    }
}

