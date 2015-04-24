/*
*   Filename:         NUHierarchyControllersCenter.j
*   Created:          Thu Aug 15 09:44:37 PDT 2013
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

@import <Foundation/Foundation.j>


function _DEBUG_NUHierarchyControllersCenter()
{
    CPLog.debug("---- BEGIN DEBUG ----");
    CPLog.debug("registered controllers:")
    CPLog.debug([NUHierarchyControllersCenter defaultCenter]._controllers);
    CPLog.debug("retains counts:")
    CPLog.debug([NUHierarchyControllersCenter defaultCenter]._retainsCount);
    CPLog.debug("----  END DEBUG  ----");
}


var NUHierarchyControllersCenterDefaultCenter;

@implementation NUHierarchyControllersCenter : CPObject
{
    CPDictionary    _controllers;
    CPDictionary    _retainsCount;
}


#pragma mark -
#pragma mark Class Methods

+ (id)defaultCenter
{
    if (!NUHierarchyControllersCenterDefaultCenter)
        NUHierarchyControllersCenterDefaultCenter = [NUHierarchyControllersCenter new];

    return NUHierarchyControllersCenterDefaultCenter;
}


#pragma mark -
#pragma mark Initialization

- (id)init
{
    if (self = [super init])
    {
        _controllers = @{};
        _retainsCount = @{};
    }

    return self;
}


#pragma mark -
#pragma mark Controllers registration

- (void)registerController:(id)aController forObject:(NURESTObject)anObject
{
    var ID = [anObject ID];

    CPLog.debug("NUHierarchyControllersCenter: registering controller %@:%@ for object %@::%@", [aController className], aController, anObject, ID);

    if ([_controllers containsKey:ID])
    {
        [self retainControllerForObject:anObject];
        return;
    }

    [aController startListeningForPush];
    [_controllers setObject:aController forKey:ID];
    [_retainsCount setObject:1 forKey:ID];

    CPLog.debug("NUHierarchyControllersCenter: Added a controller %@:%@ for object %@:%@. retain count is now 1", [aController className], aController, anObject, ID);
}

- (void)unregisterControllerForObject:(NURESTObject)anObject
{
    var ID = [anObject ID];

    if (![_controllers containsKey:ID])
        return;

    var controller = [_controllers objectForKey:ID];
    CPLog.debug("NUHierarchyControllersCenter: unregistering controller %@:%@ for object %@:%@", [controller className], controller, anObject, ID);

    [controller stopListeningForPush];
    [controller setObservedObject:nil];
    [_controllers removeObjectForKey:ID];
    [_retainsCount removeObjectForKey:ID];
}


#pragma mark -
#pragma mark Retain and Release

- (void)retainControllerForObject:(NURESTObject)anObject
{
    var ID = [anObject ID];

    if (![_controllers containsKey:ID])
        return;

    var retain = [_retainsCount objectForKey:ID] + 1,
        controller = [_controllers objectForKey:ID];

    CPLog.debug("NUHierarchyControllersCenter: Retaining controller %@:%@ for object %@:%@. retain is %@", [controller className], controller, anObject, ID, retain);

    [_retainsCount setObject:retain forKey:ID];

    CPLog.debug("NUHierarchyControllersCenter: Retained controller %@:%@ for object %@:%@. retain count is now %@", [controller className], controller, anObject, ID, retain);
}

- (void)releaseControllerForObject:(NURESTObject)anObject
{
    var ID = [anObject ID];

    if (![_controllers containsKey:ID])
        return;

    var retain = [_retainsCount objectForKey:ID] - 1,
        controller = [_controllers objectForKey:ID];

    CPLog.debug("NUHierarchyControllersCenter: Releasing controller %@:%@ for object %@:%@. current retain is: %@", [controller className], controller, anObject, ID, retain);

    if (!retain)
    {
        [self unregisterControllerForObject:anObject];
        return;
    }

    [_retainsCount setObject:retain forKey:ID];

    CPLog.debug("NUHierarchyControllersCenter: Released controller %@:%@ for object ID %@:%@. retain is now: %@", [controller className], controller, anObject, ID, retain);
}


#pragma mark -
#pragma mark Controller accessor

- (id)controllerForObject:(NURESTObject)anObject
{
    return [_controllers objectForKey:[anObject ID]];
}

@end
