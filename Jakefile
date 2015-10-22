/*
 * Jakefile
 *
 * Copyright (C) 2010  Antoine Mercadal <antoine.mercadal@inframonde.eu>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

require("./Tools/config.jake");

BUILD_INFO["PROJECT_NAME"]                      = "NUKit";
BUILD_INFO["PROJECT_IDENTIFIER"]                = "net.nuagenetworks.nukit";
BUILD_INFO["PROJECT_VERSION"]                   = "1.0";
BUILD_INFO["PROJECT_AUTHOR"]                    = "Nuage Networks";
BUILD_INFO["PROJECT_CONTACT"]                   = "antoine@nuagenetworks.net";
BUILD_INFO["PROJECT_SOURCES"]                   = (new FILELIST("**/*.j")).exclude(FILE.join("Test", "*.j"));
BUILD_INFO["PROJECT_FLATTEN_SOURCES"]           = true;
BUILD_INFO["PROJECT_TYPE"]                      = "FRAMEWORK";
BUILD_INFO["PROJECT_INCLUDE_COMPILER_FLAGS"]    = "--include \"NUKit.h\"";

require("./Tools/common.jake");