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
