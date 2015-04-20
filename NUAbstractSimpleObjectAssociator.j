/*
*   Filename:         NUAbstractSimpleObjectAssociator.j
*   Created:          Wed Feb 12 18:30:09 PST 2014
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
@import "NUAbstractObjectAssociator.j"

@implementation NUAbstractSimpleObjectAssociator : NUAbstractObjectAssociator

#pragma mark -
#pragma mark IBAction

- (IBAction)removeCurrentAssociatedObject:(id)aSender
{
    [_currentParent setValue:nil forKeyPath:[self keyPathForAssociatedObjectID]];

    [self _sendDelegateDidAssociatorChangeAssociation];
    [self _sendDelegateDidAssociatorRemoveAssociation];
}


#pragma mark -
#pragma mark Overrides

- (void)setCurrentParent:(id)aParent
{
    [super setCurrentParent:aParent];

    if (!_currentParent)
        return;

    [self _fetchAssociatedObjectWithID:[_currentParent valueForKeyPath:[self keyPathForAssociatedObjectID]]];
    [self didSetCurrentParent:_currentParent];
}


#pragma mark -
#pragma mark PushManagement

- (BOOL)shouldManagePushForEntityType:(CPString)entityType
{
    return entityType == [[self classForAssociatedObject] RESTName] || entityType == [_currentParent RESTName];
}

- (void)managePushedObject:(id)aJSONObject ofType:(CPString)aType eventType:(CPString)anEventType
{
    [super managePushedObject:aJSONObject ofType:aType eventType:anEventType];

    if (aJSONObject.ID != [_currentParent ID])
        return;

    switch (anEventType)
    {
        case NUPushEventTypeUpdate:
            [self _fetchAssociatedObjectWithID:[_currentParent valueForKeyPath:[self keyPathForAssociatedObjectID]]];
            break;
    }
}


#pragma mark -
#pragma mark Delegates

- (void)didObjectChooser:(NUObjectsChooser)anObjectChooser selectObjects:(CPArray)selectedObjects
{
    var associatedObject = [selectedObjects firstObject];

    if (![associatedObject isEqual:_currentAssociatedObject])
    {
        [_currentParent setValue:[associatedObject ID] forKeyPath:[self keyPathForAssociatedObjectID]];
        [self _fetchAssociatedObjectWithID:[associatedObject ID]];

        [self _sendDelegateDidAssociatorChangeAssociation];
        [self _sendDelegateDidAssociatorAddAssociation];
    }

    [anObjectChooser closeModulePopover];
}

@end
