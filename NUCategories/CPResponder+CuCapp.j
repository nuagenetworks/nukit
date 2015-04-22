/*
*   Filename:         CPResponder+CuCapp.j
*   Created:          Thu Jan 17 15:38:38 PST 2013
*   Author:           Antoine Mercadal <antoine.mercadal@alcatel-lucent.com>
*   Description:      VSA
*   Project:          Cloud Network Automation - Nuage - Data Center Service Delivery - IPD
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

@import <Foundation/Foundation.j>
@import <AppKit/CPResponder.j>

@global NUKitParameterShowDebugToolTips

@implementation CPResponder (CuCapp)

- (void)setCucappIdentifier:(CPString)anIdentifier
{
    self.__cucappIdentifier = anIdentifier;

    if (NUKitParameterShowDebugToolTips && [self respondsToSelector:@selector(setToolTip:)])
        [self setToolTip:@"cucappID: " +  anIdentifier + "\nClass Name: " + [self className]];
}

- (CPString)cucappIdentifier
{
    return self.__cucappIdentifier;
}

@end


@implementation CPMenuItem (cucappAdditionsMenu)

- (void)setCucappIdentifier:(CPString)anIdentifier
{
    [[self _menuItemView] setCucappIdentifier:anIdentifier];
}

- (CPString)cucappIdentifier
{
    [[self _menuItemView] cucappIdentifier];
}

@end

function load_cucapp_CLI(path)
{
    if (!path)
        path = "../../Cucapp/lib/Cucumber.j"

    try {
        objj_importFile(path, true, function() {
            [Cucumber stopCucumber];
            CPLog.debug("Cucapp CLI has been well loaded");
            _addition_cpapplication_send_event_method();
        });
    }
    catch(e)
    {
        [CPException raise:CPInvalidArgumentException reason:@"Invalid path for the lib Cucumber"];
    }
}
