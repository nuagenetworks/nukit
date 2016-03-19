/*
*   Filename:         Jakefile
*   Created:          Wed Apr 22 19:07:16 PDT 2015
*   Author:           Antoine Mercadal <antoine.mercadal@alcatel-lucent.com>
*   Description:      VSA
*   Project:          VSD - Nuage - Data Center Service Delivery - IPD
*
* Copyright (c) 2011-2012 Alcatel, Alcatel-Lucent, Inc. All Rights Reserved.
*
* This source code contains confidential information which is proprietary to Alcatel.
* No part of its contents may be used, copied, disclosed or conveyed to any party
* in any manner whatsoever without prior written permission from Alcatel.
*
* Alcatel-Lucent is a trademark of Alcatel-Lucent, Inc.
*
*/

require("./Libraries/NUKit/Tools/config.jake");

BUILD_INFO["PROJECT_NAME"]       = "{{app_name}}";
BUILD_INFO["PROJECT_IDENTIFIER"] = "";
BUILD_INFO["PROJECT_VERSION"]    = "";
BUILD_INFO["PROJECT_AUTHOR"]     = "Nuage Networks";
BUILD_INFO["PROJECT_CONTACT"]    = "antoine@nuagenetworks.net";
BUILD_INFO["PROJECT_SOURCES"]    = new FILELIST("*.j", "Associators/**/*.j", "DataViews/**/*.j", "Models/**/*.j", "Transformers/*.j", "ViewControllers/**/*.j")
BUILD_INFO["PROJECT_FRAMEWORKS"] = ["TNKit", "NUKit", "Bambou"];
BUILD_INFO["PROJECT_TYPE"]       = "APPLICATION";

require("./Libraries/NUKit/Tools/common.jake");


function generate_war(project_name, target, build_type)
{
    OS.system(["rm", "-rf", "webapp/Browser.environment"]);
    OS.system(["rm", "-rf", "webapp/CommonJS.environment"]);
    OS.system(["rm", "-rf", "webapp/Frameworks"]);
    OS.system(["rm", "-rf", "webapp/Resources"]);
    OS.system(["rm", "-rf", "webapp/index.html"]);
    OS.system(["rm", "-rf", "webapp/index.html"]);
    OS.system(["rm", "-rf", "webapp/Info.plist"]);
    OS.system(["rm", "-rf", "webapp/Application.js"]);
    OS.system(["rm", "-rf", "webapp/app.manifest"]);
    OS.system(["rm", "-rf", "webapp/Application.js"]);

    OS.system(["cp", "-a", "./Build/" + target + "/" + project_name + build_type + "/Browser.environment", "webapp/"]);
    OS.system(["cp", "-a", "./Build/" + target + "/" + project_name + build_type + "/Frameworks", "webapp/"]);
    OS.system(["cp", "-a", "./Build/" + target + "/" + project_name + build_type + "/Resources", "webapp/"]);
    OS.system(["cp", "-a", "./Build/" + target + "/" + project_name + build_type + "/index.html", "webapp/"]);
    OS.system(["cp", "-a", "./Build/" + target + "/" + project_name + build_type + "/Info.plist", "webapp/"]);
    OS.system(["cp", "-a", "./Build/" + target + "/" + project_name + build_type + "/Application.js", "webapp/"]);
}


TASK ("deploy", ["predeploy"], function()
{
    generate_war(BUILD_INFO["PROJECT_NAME"], "Deployment", ".ready");
});

TASK ("devdeploy", ["debug"], function(){
    generate_war(BUILD_INFO["PROJECT_NAME"], "Debug", "");
});
