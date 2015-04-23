/*
*   Filename:         config.jake
*   Created:          Wed Apr 22 19:05:15 PDT 2015
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


ENV           = require("system").env;
FILE          = require("file");
JAKE          = require("jake");
OS            = require("os");
TASK          = JAKE.task;
FILELIST      = JAKE.FileList;
APP           = require("cappuccino/jake").app;
STREAM        = require("narwhal/term").stream
CONFIGURATION = ENV["CONFIG"] || ENV["CONFIGURATION"] || ENV["c"] || "Debug";
BUILD_INFO    = {}
