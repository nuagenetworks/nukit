/*
*   Filename:         common.jake
*   Created:          Wed Apr 22 17:57:33 PDT 2015
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


/*
    Helper Functions
*/
color_print = function(message, color)
{
    STREAM.print("\0" + color + "(" + message + "\0)");
}

exit = function (message, code)
{
    color_print("FATAL ERROR: unable to run flatten correctly.", "red");
    OS.exit(code || 1);
}

press_app = function(project_name)
{
    color_print("* Pressing the application...", "blue");

    FILE.mkdirs(FILE.join("Build", "Deployment", project_name));

    if (OS.system(["press", "-f", FILE.join("Build", "Release", project_name), FILE.join("Build", "Deployment", project_name + ".pressed")]))
        exit("unable to run press correctly.");

    color_print("SUCCESS: Application successfuly pressed", "green");
}

flatten_app = function(project_name, additional_frameworks)
{
    var frameworks = additional_frameworks.slice();

    color_print("* Flattening the application...", "blue");

    var flatten_command    = ["flatten"],
        pressed_app_path   = FILE.join("Build", "Deployment", project_name + ".pressed"),
        flattened_app_path = FILE.join("Build", "Deployment", project_name + ".ready"),
        app_resources_path = FILE.join(pressed_app_path, "Resources"),
        app_cibs           = new FILELIST(FILE.join(app_resources_path, "*.cib"));

    while (cib = app_cibs.pop())
    {
        cib = cib.replace(pressed_app_path, "");
        flatten_command.push("-P");
        flatten_command.push(cib);
    }

    while (framework = frameworks.pop())
    {
        var framework_resources_path = FILE.join(pressed_app_path, "Frameworks", framework, "Resources"),
            frameworks_cibs          = new FILELIST(FILE.join(framework_resources_path, "*.cib"));

        while (cib = frameworks_cibs.pop())
        {
            cib = cib.replace(pressed_app_path, "");
            flatten_command.push("-P");
            flatten_command.push(cib);
        }
    }

    if (ENV["CAPP_NOMANIFEST"] != "1")
        flatten_command.push("--manifest");

    flatten_command.push("-c");
    flatten_command.push("none");
    flatten_command.push("--index");
    flatten_command.push("index.html");
    flatten_command.push("-f");
    flatten_command.push(pressed_app_path);
    flatten_command.push(flattened_app_path);

    if (OS.system(flatten_command))
        exit("unable to run flatten correctly.");

    color_print("SUCCESS: Application successfuly flattened", "green");
}

cleanup_app = function(project_name, additional_frameworks)
{
    var frameworks = additional_frameworks.slice();

    color_print("* Cleaning Application Build", "blue");
    var application_path = FILE.join("Build", "Deployment", project_name + ".ready");
    OS.system("rm -rf " + FILE.join(application_path, "CommonJS.environment"))
    OS.system("rm -f " + FILE.join(application_path, "Resources", "*.cib"))
    OS.system("rm -f " + FILE.join(application_path, "Resources", "*.png"));
    OS.system("rm -f " + FILE.join(application_path, "Resources", "*.jpg"));
    OS.system("rm -f " + FILE.join(application_path, "Resources", "*.gif"));
    color_print("SUCCESS: Application successfuly cleaned up", "green");

    color_print("* Cleaning Frameworks", "blue");
    var frameworks_path = FILE.join(application_path, "Frameworks");
    OS.system("rm -rf " + FILE.join(frameworks_path, "Debug"));

    frameworks.push("AppKit", "Objective-J");
    while (framework_name= frameworks.pop())
    {
        color_print(" - Cleaning up " + framework_name, "cyan");

        OS.system("rm -rf " + FILE.join(frameworks_path, framework_name, "CommonJS.environment"));
        OS.system("rm -f  " + FILE.join(frameworks_path, framework_name, "Resources", "*.cib"));
        OS.system("rm -f  " + FILE.join(frameworks_path, framework_name, "Resources", "*.png"));
        OS.system("rm -f  " + FILE.join(frameworks_path, framework_name, "Resources", "*.jpg"));
        OS.system("rm -f  " + FILE.join(frameworks_path, framework_name, "Resources", "*.gif"));

        if (framework_name == "AppKit")
            OS.system("rm -rf " + FILE.join(frameworks_path, framework_name, "Resources", "*.blend"));
    }

    color_print("SUCCESS: Frameworks successfuly cleaned up", "green");
}

compress_app = function(project_name)
{
    color_print("* Compressing the application with yui compressor...", "blue");

    var application_js     = FILE.join("Build", "Deployment", project_name + ".ready", "Application.js"),
        compressor_command = "java -Xmx512M -jar Libraries/NUKit/Tools/yuicompressor-2.4.8.jar --type js --charset UTF-8 '" + application_js +  "' > '" +  application_js + ".compiled'";

     if (OS.system(compressor_command + " && " + "mv '" + application_js + ".compiled' '" + application_js + "'"))
         exit("unable to run flatten correctly.");

    color_print("SUCCESS: Application successfuly compressed", "green");
}

print_result = function(configuration)
{
    print("----------------------------");
    print(configuration + " app built at path: " + FILE.join("Build", configuration, BUILD_INFO["PROJECT_NAME"]));
    print("----------------------------");
}

update_app_size = function()
{
    print("Calculating application file sizes...");

    var contents = FILE.read(FILE.join("Build", CONFIGURATION, BUILD_INFO["PROJECT_NAME"], "Info.plist"), { charset:"UTF-8" }),
        format = CFPropertyList.sniffedFormatOfString(contents),
        plist = CFPropertyList.propertyListFromString(contents),
        totalBytes = {executable:0, data:0, mhtml:0};

    // Get the size of all framework executables and sprite data
    var frameworksDir = "Frameworks";

    if (CONFIGURATION === "Debug")
        frameworksDir = FILE.join(frameworksDir, "Debug");

    var frameworks = FILE.list(frameworksDir);

    frameworks.forEach(function(framework)
    {
        if (framework !== "Source")
            add_bundle_files_size(FILE.join(frameworksDir, framework), totalBytes);
    });

    // Read in the default theme name, and attempt to get its size
    var themeName = plist.valueForKey("CPDefaultTheme") || "Aristo2",
        themePath = nil;

    if (themeName === "Aristo" || themeName === "Aristo2")
        themePath = FILE.join(frameworksDir, "AppKit", "Resources", themeName + ".blend");
    else
        themePath = FILE.join("Frameworks", "Resources", themeName + ".blend");

    if (FILE.isDirectory(themePath))
        add_bundle_files_size(themePath, totalBytes);

    // Add sizes for the app
    add_bundle_files_size(FILE.join("Build", CONFIGURATION, BUILD_INFO["PROJECT_NAME"]), totalBytes);

    print("Executables: " + totalBytes.executable + ", sprite data: " + totalBytes.data + ", total: " + (totalBytes.executable + totalBytes.data));

    var dict = new CFMutableDictionary();

    dict.setValueForKey("executable", totalBytes.executable);
    dict.setValueForKey("data", totalBytes.data);
    dict.setValueForKey("mhtml", totalBytes.mhtml);

    plist.setValueForKey("CPApplicationSize", dict);

    FILE.write(FILE.join("Build", CONFIGURATION, BUILD_INFO["PROJECT_NAME"], "Info.plist"), CFPropertyList.stringFromPropertyList(plist, format), { charset:"UTF-8" });
}

add_bundle_files_size = function(bundlePath, totalBytes)
{
    var bundleName = FILE.basename(bundlePath),
        environment = bundleName === "Foundation" ? "Objj" : "Browser",
        bundlePath = FILE.join(bundlePath, environment + ".environment");

    if (FILE.isDirectory(bundlePath))
    {
        var filename = bundleName + ".sj",
            filePath = new FILE.Path(FILE.join(bundlePath, filename));

        if (filePath.exists())
            totalBytes.executable += filePath.size();

        filePath = new FILE.Path(FILE.join(bundlePath, "dataURLs.txt"));

        if (filePath.exists())
            totalBytes.data += filePath.size();

        filePath = new FILE.Path(FILE.join(bundlePath, "MHTMLData.txt"));

        if (filePath.exists())
            totalBytes.mhtml += filePath.size();

        filePath = new FILE.Path(FILE.join(bundlePath, "MHTMLPaths.txt"));

        if (filePath.exists())
            totalBytes.mhtml += filePath.size();
    }
}


/*
    Tasks
*/

BUILDER = BUILD_INFO["PROJECT_TYPE"] == "APPLICATION" ? APP : FRAMEWORK;

BUILDER ("BUILDER", function(task)
{
    color_print("* Using builder: " + BUILD_INFO["PROJECT_TYPE"], "green");

    if (BUILD_INFO["PROJECT_TYPE"] == "APPLICATION")
    {
        task.setIndexFilePath("index.html");
        task.setEnvironments([ENVIRONMENT.Browser]);

        ENV["OBJJ_INCLUDE_PATHS"] = "Frameworks";
        ENV["CAPP_BUILD"] = "./Build"
        if (CONFIGURATION === "Debug")
            ENV["OBJJ_INCLUDE_PATHS"] = FILE.join(ENV["OBJJ_INCLUDE_PATHS"], CONFIGURATION);
    }

    task.setAuthor(BUILD_INFO["PROJECT_AUTHOR"]);
    task.setBuildIntermediatesPath(FILE.join(ENV["CAPP_BUILD"], BUILD_INFO["PROJECT_NAME"] + ".build", CONFIGURATION));
    task.setBuildPath(FILE.join(ENV["CAPP_BUILD"], CONFIGURATION));
    task.setCompilerFlags(CONFIGURATION === "Debug" ? "-DDEBUG -g" : "-O2");
    task.setEmail(BUILD_INFO["PROJECT_CONTACT"]);
    task.setFlattensSources(BUILD_INFO["PROJECT_FLATTEN_SOURCES"]);
    task.setIdentifier(BUILD_INFO["PROJECT_IDENTIFIER"]);
    task.setInfoPlistPath("Info.plist");
    task.setPreventsNib2Cib(false);
    task.setProductName(BUILD_INFO["PROJECT_NAME"]);
    task.setResources(new FILELIST("Resources/**"));
    task.setSources(BUILD_INFO["PROJECT_SOURCES"]);
    task.setSummary(BUILD_INFO["PROJECT_NAME"]);
    task.setVersion(BUILD_INFO["PROJECT_VERSION"]);
});


TASK ("build", ["BUILDER"], function()
{
    if (BUILD_INFO["PROJECT_TYPE"] == "APPLICATION")
        update_app_size();
});

TASK ("debug", function()
{
    ENV["CONFIGURATION"] = "Debug";
    JAKE.subjake(["."], "build", ENV);
});

TASK ("release", function()
{
    ENV["CONFIGURATION"] = "Release";
    JAKE.subjake(["."], "build", ENV);
});

TASK ("predeploy", ["release"], function()
{
    press_app(BUILD_INFO["PROJECT_NAME"]);
    flatten_app(BUILD_INFO["PROJECT_NAME"], BUILD_INFO["PROJECT_FRAMEWORKS"]);
    cleanup_app(BUILD_INFO["PROJECT_NAME"], BUILD_INFO["PROJECT_FRAMEWORKS"]);
    compress_app(BUILD_INFO["PROJECT_NAME"]);
});

TASK("test", ["test-only"]);

TASK("test-only", function()
{
    ENV["OBJJ_INCLUDE_PATHS"] = "Frameworks";

    OS.system("capp gen -fl -F RESTCappuccino -F TNKit -F NUKit . --force");

    var tests = new FILELIST('Test/*Test.j'),
        manualTests = FILE.list('Test/Manual'),
        cmd = ["ojtest"].concat(tests.items()),
        cmdString = cmd.map(OS.enquote).join(" "),
        code = OS.system(cmdString);

    OS.system("rm -rf Frameworks");

    if (code !== 0)
        OS.exit(code);

    manualTests.forEach(function(manualTest)
    {
        code = OS.system("cd Test/Manual/" + manualTest + "; capp gen -fl -F RESTCappuccino -F TNKit -F NUKit . --force; jake cucumber-test")

        if (code !== 0)
            OS.exit(code);
    });
});
