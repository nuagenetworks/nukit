/*
*   Filename:         NUAbstractHierarchyController.j
*   Created:          Thu Aug 15 13:12:25 PDT 2013
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
@import <AppKit/CPArrayController.j>
@import <RESTCappuccino/RESTCappuccino.j>

@class NURESTObject

@implementation NUAbstractHierarchyController : CPObject
{
    BOOL            _ready                  @accessors(getter=isReady);
    NURESTObject    _observedObject         @accessors(property=observedObject);

    BOOL            _isListeningForPush;
    CPArray         _activeTransactionsIDs;
    CPArray         _creationQueue;
    CPArray         _searchableArrayControllers;
}


#pragma mark -
#pragma mark Initialization

- (id)init
{
    if (self = [super init])
    {
        _ready = NO;

        _activeTransactionsIDs      = [];
        _creationQueue              = [];
        _isListeningForPush         = NO;
        _searchableArrayControllers = [];
    }

    return self;
}


#pragma mark -
#pragma mark Utilities

- (void)setObservedObject:(NURESTObject)anObject
{
    [self flushRegisteredTransactionIDs];

    if ([_observedObject isEqual:anObject])
        return;

    _observedObject = anObject;
    _ready          = NO;

    [self resetArrayControllers];

    if (!_observedObject)
        return;

    [self reload];
}

- (void)resetArrayControllers
{
    throw("implement me");
}

- (void)reload
{
    throw("implement me");
}

- (void)registerTransactionID:(CPString)aTransactionID
{
    [_activeTransactionsIDs addObject:aTransactionID];
}

- (void)flushRegisteredTransactionIDs
{
    [_activeTransactionsIDs removeAllObjects];
}

- (BOOL)isValidTransactionID:(CPString)anID
{
    return [_activeTransactionsIDs containsObject:anID];
}


#pragma mark -
#pragma mark Searching

- (void)registerSearchableArrayController:(CPArrayController)aController identifier:(CPString)anIdentifer
{
    aController.__identifier = @" " + anIdentifer;
    [_searchableArrayControllers addObject:aController];
}

- (void)generateSearchDictionaryWithPredicate:(CPPredicate)aPredicate
{
    var ret = @{};

    for (var i = [_searchableArrayControllers count] - 1; i >= 0; i--)
    {
        var controller = _searchableArrayControllers[i],
            objects = [[controller arrangedObjects] filteredArrayUsingPredicate:aPredicate];

        if (![objects count])
            continue;

        [ret setObject:objects forKey:controller.__identifier];
    }

    if ([aPredicate evaluateWithObject:_observedObject])
        ret = @{" " + [_observedObject RESTName]: [_observedObject]};

    return ret;
}


#pragma mark -
#pragma mark Creation Queue Management

- (void)creationQueue
{
    return _creationQueue;
}

- (void)enqueueObject:(id)anObject
{
    [_creationQueue addObject:anObject];
}

- (void)flushCreationQueue
{
    [_creationQueue removeAllObjects];
}


#pragma mark -
#pragma mark Push Management

- (void)shouldManagePushForEntityType:(CPString)aType
{
    throw("implement me");
}

- (void)_manageCreatePushWithJSONObject:(id)aJSONObject ofType:(CPString)aType
{
    throw("implement me");
}

- (void)_manageUpdatePushWithJSONObject:(id)aJSONObject ofType:(CPString)aType
{
    throw("implement me");
}

- (void)_manageDeletePushWithJSONObject:(id)aJSONObject ofType:(CPString)aType
{
    throw("implement me");
}

- (void)startListeningForPush
{
    if (_isListeningForPush)
        return;

    _isListeningForPush = YES;
    CPLog.debug("NUHierarchyController: controller for object " + [_observedObject ID] + " starts to listen to push notifications");
    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didReceivePush:)
                                                 name:NURESTPushCenterPushReceived
                                               object:[NURESTPushCenter defaultCenter]];
}

- (void)stopListeningForPush
{
    if (!_isListeningForPush)
        return;

    _isListeningForPush = NO;

    CPLog.debug("NUHierarchyController: controller for object " + [_observedObject ID] + " stopped to listen to push notifications");
    [[CPNotificationCenter defaultCenter] removeObserver:self
                                                 name:NURESTPushCenterPushReceived
                                               object:[NURESTPushCenter defaultCenter]];
}

- (void)_didReceivePush:(CPNotification)aNotification
{
    if (!_observedObject)
        return;

    var JSONObject = [aNotification userInfo],
        events     = JSONObject.events;

    if (events.length <= 0)
        return;

    for (var i = 0, c = events.length; i < c; i++)
    {
        var eventType  = events[i].type,
            entityType = events[i].entityType,
            entityJSON = events[i].entities[0];

        if (![self shouldManagePushForEntityType:entityType])
            continue;

        switch (eventType)
        {
            case NUPushEventTypeUpdate:
                [self _manageUpdatePushWithJSONObject:entityJSON ofType:entityType];
                break;

            case NUPushEventTypeGrant:
            case NUPushEventTypeCreate:
                [self _manageCreatePushWithJSONObject:entityJSON ofType:entityType];
                break;

            case NUPushEventTypeRevoke:
            case NUPushEventTypeDelete:
                [self _manageDeletePushWithJSONObject:entityJSON ofType:entityType];
                break;
        }
    }
}


@end
