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


/*
    Helper Functions
*/
color_print = function(message, color)
{
    STREAM.print("\0" + color + "(" + message + "\0)");
}

exit = function (message, code)
{
    color_print("FATAL ERROR: " + message, "red");
    OS.exit(code || 1);
}

press_app = function(project_name)
{
    color_print("* Pressing the application...", "blue");

    FILE.mkdirs(FILE.join("Build", "Deployment", project_name));

    if (OS.system(["press", "-f", FILE.join("Build", "Release", project_name), FILE.join("Build", "Deployment", project_name + ".pressed")]))
        exit("unable to run press correctly.");

    color_print("SUCCESS: Application successfully pressed", "green");
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

    color_print("SUCCESS: Application successfully flattened", "green");
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
    color_print("SUCCESS: Application successfully cleaned up", "green");

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

    color_print("SUCCESS: Frameworks successfully cleaned up", "green");
}

compress_app = function(project_name)
{
    color_print("* Compressing the application with yui compressor...", "blue");

    var application_js     = FILE.join("Build", "Deployment", project_name + ".ready", "Application.js"),
        compressor_command = "java -Xmx1g -jar Libraries/NUKit/Tools/yuicompressor-2.4.8.jar --type js --charset UTF-8 '" + application_js +  "' > '" +  application_js + ".compiled'";

     if (OS.system(compressor_command + " && " + "mv '" + application_js + ".compiled' '" + application_js + "'"))
         exit("unable to run flatten correctly.");

    color_print("SUCCESS: Application successfully compressed", "green");
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

generate_war = function (project_name, target, build_type)
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

    if (target != "Debug")
        OS.system(["cp", "-a", "./Build/" + target + "/" + project_name + build_type + "/Application.js", "webapp/"]);
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

    var compilerFlags = CONFIGURATION === "Debug" ? "-DDEBUG -g" : "-O2";

    if (BUILD_INFO["PROJECT_INCLUDE_COMPILER_FLAGS"])
        compilerFlags += " " + BUILD_INFO["PROJECT_INCLUDE_COMPILER_FLAGS"];

    task.setAuthor(BUILD_INFO["PROJECT_AUTHOR"]);
    task.setBuildIntermediatesPath(FILE.join(ENV["CAPP_BUILD"], BUILD_INFO["PROJECT_NAME"] + ".build", CONFIGURATION));
    task.setBuildPath(FILE.join(ENV["CAPP_BUILD"], CONFIGURATION));
    task.setCompilerFlags(compilerFlags);
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

TASK ("deploy", ["predeploy"], function()
{
    generate_war(BUILD_INFO["PROJECT_NAME"], "Deployment", ".ready");
});

TASK ("devdeploy", ["debug"], function(){
    generate_war(BUILD_INFO["PROJECT_NAME"], "Debug", "");
});

TASK("test", ["test-only"]);

TASK("test-only", function()
{
    ENV["OBJJ_INCLUDE_PATHS"] = "Frameworks";

    OS.system("capp gen -fl -F Bambou -F TNKit -F NUKit . --force");

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
        if (manualTest.indexOf("Test") != -1)
        {
            code = OS.system("cd Test/Manual/" + manualTest + "; capp gen -fl -F Bambou -F TNKit -F NUKit . --force; jake cucumber-test")

            if (code !== 0)
                OS.exit(code);
        }
    });
});

TASK ("cucumber-test", function()
{
    var SYSTEM = require("system");

    OS.system("ln -s " + SYSTEM.prefix + "/packages/cucapp/Cucapp Cucapp")
    var code = OS.system("cucumber");
    OS.system("rm -f Cucapp; rm -f cucumber.html")
    OS.exit(code);
});
