/*
* Copyright (c) 2016, Alcatel-Lucent Inc
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the copyright holder nor the names of its contributors
*       may be used to endorse or promote products derived from this software without
*       specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

require("./Tools/config.jake");

BUILD_INFO["PROJECT_NAME"]                      = "NUKit";
BUILD_INFO["PROJECT_IDENTIFIER"]                = "net.nuagenetworks.nukit";
BUILD_INFO["PROJECT_VERSION"]                   = "1.0";
BUILD_INFO["PROJECT_AUTHOR"]                    = "Nuage Networks";
BUILD_INFO["PROJECT_CONTACT"]                   = "antoine@nuagenetworks.net";
BUILD_INFO["PROJECT_SOURCES"]                   = (new FILELIST("**/*.j")).exclude(FILE.join("Test", "*.j"), FILE.join("Tools", "**"), FILE.join("Example", "**"), FILE.join("StarterKit", "**"));
BUILD_INFO["PROJECT_FLATTEN_SOURCES"]           = true;
BUILD_INFO["PROJECT_TYPE"]                      = "FRAMEWORK";
BUILD_INFO["PROJECT_INCLUDE_COMPILER_FLAGS"]    = "--include \"NUKit.h\"";

require("./Tools/common.jake");
