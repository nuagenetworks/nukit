#!/usr/bin/python

from optparse import OptionParser

import os
import re
import sys
import datetime

def generate_file(output_file, subfolder):

    if not output_file:
        output_file = os.getcwd().split("/")[-1]
        if not output_file.startswith("NU"):
            output_file = "NU%s" % output_file

    files = list()

    for (dirpath, dirnames, filenames) in os.walk("."):
        for filename in filenames:
            path = dirpath
            tmp_output_file = filename

            if (path == "."):
                path = ""

            if (path[:2] == "./"):
                if not subfolder:
                    continue
                else:
                    path = path[2:len(path)] + "/"

            name = path + tmp_output_file

            objective_j_file = re.search('(\w*.j)', tmp_output_file)

            if objective_j_file and name != "%s.j" % output_file:
                files.append(name)

    date = datetime.datetime.now()

    headers = """/*
*   Filename:         %s
*   Created:          %s
*   Author:           Script
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
*/""" % (output_file, date.strftime('%a %b %d %H:%M:%S %Z %Y'))

    destination_file = open(output_file + ".j", 'w')
    destination_file.write(headers)
    destination_file.write("\n\n")

    for f in files:

        import_string = "@import \"%s\"\n" % f
        destination_file.write(import_string)

    destination_file.close()

if __name__ == "__main__":
    parser = OptionParser()
    parser.add_option("-o", "--output", dest="output",
                        help="Name of the file to generate")
    parser.add_option("-r", "--recursice", action="store_true", dest="recursive",
                        help="Import the files find in the subfolder")

    options, args = parser.parse_args()

    generate_file(options.output, options.recursive)
