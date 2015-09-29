/*
*   Filename:         CPArrayController+Description.j
*   Created:          Tue Sep 29 10:53:15 PDT 2015
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

@import <AppKit/CPArrayController.j>

@implementation CPArrayController (Description)

- (CPString)description
{
    try
    {
        return @"" + [[self arrangedObjects] valueForKey:@"value"];
    }
    catch (e)
    {
        return @"" + self;
    }
}

@end