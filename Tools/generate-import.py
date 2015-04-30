#!/usr/bin/python

from optparse import OptionParser

import os
import re
import sys
import datetime

def generate_file(name_file, subfolder):

    files = list()

    for (dirpath, dirnames, filenames) in os.walk("."):
        for filename in filenames:
            path = dirpath
            tmp_file_name = filename

            if (path == "."):
                path = ""

            if (path[:2] == "./"):
                if not subfolder:
                    continue
                else:
                    path = path[2:len(path)] + "/"

            name = path + tmp_file_name

            objective_j_file = re.search('(\w*.j)', tmp_file_name)

            if objective_j_file and objective_j_file != name_file:
                files.append(name)

    date = datetime.datetime.now()

    headers = """/*
    *   Filename:         %s
    *   Created:          %s
    *   Author:           Alexandre Wilhelm <alexandre.wilhelm@alcatel-lucent.com>
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
    */""" % (name_file, date.strftime('%a %b %d %H:%M:%S %Z %Y'))

    destination_file = open(name_file + ".j", 'w')
    destination_file.write(headers)
    destination_file.write("\n\n")

    for f in files:

        import_string = "@import \"%s\"\n" % f
        destination_file.write(import_string)

    destination_file.close()

if __name__ == "__main__":
    parser = OptionParser()
    parser.add_option("-f", "--file", dest="file",
                        help="Name of the file to generate")
    parser.add_option("-s", "--subfolder", action="store_true", dest="subfolder",
                        help="Import the files find in the subfolder")

    options, args = parser.parse_args()

    if options.file is None:
        print "You need to specify the file where you want to generate your imports with the option -f"
        sys.exit(1)

    generate_file(options.file, options.subfolder)
