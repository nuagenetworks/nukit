import os, commands
from optparse import OptionParser
import sys

VERBOSE = False;

ROOT_DIRECTORY = os.path.join(os.path.dirname(os.path.realpath(__file__)), "..", "..", "..", "..")

### Utilities

def command(command, title=None, expected=0):
    if title:
        print "# %s" % title
    else:
        print "\033[35m# Running: %s in %s \033[0m" % (command, os.getcwd())

    if not VERBOSE:
        command = "%s > /tmp/buildProject.log 2>&1" % command
    ret = os.system(command)

    if not ret == expected:
        print "\033[31mERROR: Command expected to return %d (was %d)\033[0m" % (expected, ret)
        sys.exit(-1)
    else:
        print "\033[32mSUCCESS\033[0m"
    return ret

def init(installDir, buildDir):
    try:
        os.makedirs(buildDir)
    except:
        pass
    os.environ["JAVA_OPTS"] = "-Xmx1024M"
    os.environ["CAPP_BUILD"] = buildDir
    os.environ["CAPP_NOSUDO"] = "1"
    os.environ["PATH"] = "%s:%s" % (os.environ["PATH"], "%s/bin" % installDir)

    if not "NARWHAL_ENGINE" in os.environ:
        if not 'darwin' in sys.platform:
            os.environ["NARWHAL_ENGINE"] = "rhino"
        else:
            os.environ["NARWHAL_ENGINE"] = "jsc"


### Libraries Management

def build_library(name, customCommand=None):
    os.environ["OBJJ_INCLUDE_PATHS"] = "%s/Frameworks" % ROOT_DIRECTORY
    current_path = os.getcwd()
    os.chdir("Libraries/%s" % name)
    if customCommand is None: command("jake release; jake debug")
    else: command(customCommand)
    os.chdir(current_path)
    command("capp gen -fl --force -F %s ." % name)

def clean_library(name, build_prefix=""):
    current_path = os.getcwd()
    os.chdir("Libraries/%s" % name)
    command("jake clean")
    os.chdir(current_path)


### Theme Management

def build_theme(name):
    os.environ["OBJJ_INCLUDE_PATHS"] = "%s/Frameworks" % ROOT_DIRECTORY
    current_path = os.getcwd()
    os.chdir("Libraries/%s" % name)
    command("jake build")
    os.chdir(current_path)
    command("capp gen -fl --force -T %s ." % name)

def clean_theme(name, build_prefix=""):
    current_path = os.getcwd()
    os.chdir("Libraries/%s" % name)
    command("rm -rf %sBuild" % build_prefix)
    os.chdir(current_path)


### Cappuccino Management

def install_cappuccino(installDir, buildDir, localDistrib):
    current_path = os.getcwd()
    os.chdir("Libraries/Cappuccino")
    command("rm -rf %s" % installDir)
    command("./bootstrap.sh --noprompt --directory %s --copy-local %s" % (installDir, localDistrib))
    command("jake install")

    os.chdir(current_path)

def clean_cappuccino(installDir, buildDir):
    command("jake clobber-theme; jake clobber")
    command("rm -rf '%s'" % installDir)
    command("rm -rf '%s'" % buildDir)


### WAR Management

def build_war(name):
    target = "Deployment"

    if "ARCHITECT_BUILD_DEBUG" in os.environ:
        name = "vcenterui-debug.war"
        target = "Debug"

    current_path = os.getcwd()
    os.chdir("./webapp")
    command("jar -cf %s ." % name)
    command("mv %s ../Build/%s/" % (name, target))
    os.chdir(current_path)

def clean_war():
    current_path = os.getcwd()
    os.chdir("./webapp")
    command("rm -rf Application.js *.environment Frameworks Info.plist Resources index.html")
    os.chdir(current_path)

### Project Management

def build_project(build_version="dev"):
    current_path = os.getcwd()
    git_rev = commands.getoutput("git log --pretty=format:'%h' -n 1")
    git_branch = commands.getoutput("git symbolic-ref HEAD").split("/")[-1]

    if "ARCHITECT_BUILD_DEBUG" in os.environ:
        build_version = "%s-debug" % build_version

    f = open("Resources/app-version.js", "w")
    f.write("APP_GITVERSION = '%s-%s'\nAPP_BUILDVERSION='%s'\n" % (git_branch, git_rev, build_version))
    f.close()
    command("capp gen -fl . --force")

    if "ARCHITECT_BUILD_DEBUG" in os.environ:
        command("jake devdeploy")
    else:
        command("jake deploy")

def build_container(container_name):
    command("docker build -t '%s' ." % container_name)

def clean_dashboard():
    command("rm -rf Build")


def main(additional_libraries, war_name, container_default_name):
    """
    """

    parser = OptionParser()
    parser.add_option("-c", "--cappuccino",
                        dest="cappuccino",
                        action="store_true",
                        help="Build and install Cappuccino")
    parser.add_option("-t", "--tnkit",
                        dest="tnkit",
                        action="store_true",
                        help="Build and install TNKit")
    parser.add_option("-n", "--nuaristo",
                        dest="nuaristo",
                        action="store_true",
                        help="Build and install NUAristo")
    parser.add_option("-r", "--restcappuccino",
                        dest="restcappuccino",
                        action="store_true",
                        help="Build and install RESTCappuccino")
    parser.add_option("-k", "--nukit",
                        dest="nukit",
                        action="store_true",
                        help="Build and deploy NUKit")

    for library in additional_libraries:
        parser.add_option("-%s" % library["short_arg"], "--%s" % library["name"].lower(),
                            dest=library["name"].lower(),
                            action="store_true",
                            help="Build and install %s" % library["name"])

    parser.add_option("-d", "--project",
                        dest="project",
                        action="store_true",
                        help="Build and deploy project")
    parser.add_option("-a", "--all",
                        dest="all",
                        action="store_true",
                        help="Build and deploy everything without Cappuccino")
    parser.add_option("-E", "--everything",
                        dest="everything",
                        action="store_true",
                        help="Build and deploy everything + Cappuccino")
    parser.add_option("-L", "--libraries",
                        dest="libraries",
                        action="store_true",
                        help="Build all libraries")
    parser.add_option("-w", "--war",
                        dest="generatewar",
                        action="store_true",
                        help="Generate the WAR file for JBOSS deployment")
    parser.add_option("-v", "--verbose",
                        dest="verbose",
                        action="store_true",
                        help="Print commands output")
    parser.add_option("--setversion",
                        dest="buildversion",
                        help="Set the build version")
    parser.add_option("-C", "--clean",
                        dest="clean",
                        action="store_true",
                        help="Clean all libraries and project")
    parser.add_option("--clobber",
                        dest="clobber",
                        action="store_true",
                        help="Clean all libraries, project and cappuccino")
    parser.add_option("--cappinstalldir",
                        default="/usr/local/narwhal",
                        dest="cappuccinoInstallDir",
                        help="Cappuccino install directory")
    parser.add_option("--cappbuilddir",
                        dest="cappuccinoBuildDir",
                        help="Cappuccino build directory")
    parser.add_option("--nomanifest",
                        dest="nomanifest",
                        action="store_true",
                        help="disable the HTML5 app.manifest generation")
    parser.add_option("--debug",
                        dest="debug",
                        action="store_true",
                        help="Generate a debug deployment build")
    parser.add_option("--build-container",
                        dest="buildcontainer",
                        action="store_true",
                        default=False,
                        help="Build the docker container")
    parser.add_option("--container-name",
                        dest="containername",
                        default=container_default_name,
                        help="Container name. default %s" % container_default_name)

    options, args = parser.parse_args()

    if options.verbose:
        VERBOSE = True

    if not options.cappuccinoBuildDir and "CAPP_BUILD" in os.environ:
        options.cappuccinoBuildDir = os.environ["CAPP_BUILD"]
    if not options.cappuccinoBuildDir:
        options.cappuccinoBuildDir = "/usr/local/cappuccino"

    options.cappuccinoInstallDir = os.path.expanduser(options.cappuccinoInstallDir)
    options.cappuccinoBuildDir = os.path.expanduser(options.cappuccinoBuildDir)

    init(options.cappuccinoInstallDir, options.cappuccinoBuildDir)

    if options.clean or options.clobber:
        clean_library("NUKit")
        clean_library("TNKit")
        clean_library("RESTCappuccino")

        for library in additional_libraries:
            clean_library(library["name"])

        clean_theme("NUAristo")
        clean_project()
        clean_war()

        if options.clobber:
            clean_cappuccino(options.cappuccinoInstallDir, options.cappuccinoBuildDir)

        sys.exit(0)

    if options.nomanifest:
        os.environ["CAPP_NOMANIFEST"] = "1"

    if options.debug:
        os.environ["ARCHITECT_BUILD_DEBUG"] = "1"

    ## Required libraries
    if options.everything or options.cappuccino:
        install_cappuccino(options.cappuccinoInstallDir, options.cappuccinoBuildDir, "/usr/local/cappuccino-base/current")
    if options.everything or options.all or options.tnkit or options.libraries:
        build_library("TNKit")
    if options.everything or options.all or options.restcappuccino or options.libraries:
        build_library("RESTCappuccino")
    if options.everything or options.all or options.nukit or options.libraries:
        build_library("NUKit")
    if options.everything or options.all or options.nuaristo or options.libraries:
        build_theme("NUAristo")

    ## Additional User Libraries
    for library in additional_libraries:
        if options.everything or options.all or getattr(options, library["name"].lower()) or options.libraries:
            build_library(library["name"])

    if options.everything or options.all or options.project:
        build_project(options.buildversion)

    if options.everything or options.all or options.generatewar:
        build_war(war_name)

    if options.buildcontainer:
        build_container(options.containername)
