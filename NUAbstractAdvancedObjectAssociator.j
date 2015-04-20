/*
*   Filename:         NUAbstractAdvancedObjectAssociator.j
*   Created:          Wed Feb 12 20:00:39 PST 2014
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
@import <AppKit/CPButton.j>
@import "NUVSDObject.j"
@import "NUAbstractObjectAssociator.j"

@class NUModuleContext


@implementation NUAbstractAdvancedObjectAssociator : NUAbstractObjectAssociator
{
    NUVSDObject     _currentAssociationObject    @accessors(property=currentAssociationObject);

    NUModuleContext _currentContext;
}

#pragma mark -
#pragma mark Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];

    _currentContext = [self contextForAssociationObject];
    [_currentContext setDelegate:self];
}


#pragma mark -
#pragma mark NUAbstractAdvancedObjectAssociator Protocol

- (NURESTFetcher)fetcherOfAssociationObject
{
    throw ("implement me");
}

- (NUModuleContext)contextForAssociationObject
{
    throw ("implement me");
}

- (Class)classForAssociationObject
{
    throw ("implement me");
}

- (void)updateAssociationObject:(NUVSDObject)anAssociationObject withAssociatedObject:(NUVSDObject)anAssociatedObject
{
    throw ("implement me");
}

- (void)didUpdateAssociatedObject:(NUVSDObject)anAssociatedObject
{

}


#pragma mark -
#pragma mark Overrides

- (void)setCurrentParent:(id)aParent
{
    [super setCurrentParent:aParent];

    _currentAssociationObject = nil;

    [_currentContext setParentObject:_currentParent];
    [_currentContext setEditedObject:nil];

    if (!_currentParent)
        return;

    [self _updateDataViewWithAssociatedObject:nil];

    var fetcher = [self fetcherOfAssociationObject];
    [fetcher flush];
    [fetcher fetchAndCallSelector:@selector(fetcher:ofObject:didFetchContent:) ofObject:self];
}


#pragma mark -
#pragma mark Action

- (IBAction)removeCurrentAssociatedObject:(id)aSender
{
    [self _updateDataViewWithAssociatedObject:nil];
    [self didUpdateAssociatedObject:nil];
    [self setModified:YES];
}

- (IBAction)save:(id)aSender
{
    // if we have no associated object, then we check if we have a current association object
    if (!_currentAssociatedObject)
    {
        // if so, we delete it
        if (_currentAssociationObject && [_currentAssociationObject ID])
        {
            [_currentContext setSelectedObjects:[_currentAssociationObject]];
            [_currentContext deleteSelectedObjects:self];
            [_currentContext setEditedObject:nil];
            _currentAssociationObject = nil;
            [self didUpdateAssociatedObject:_currentAssociationObject];
        }
        else
            [self setModified:NO];

        // and we do nothing.
        return;
    }

    // we call this to let the subclasses a chance to update the association object
    [self updateAssociationObject:_currentAssociationObject withAssociatedObject:_currentAssociatedObject];

    [_currentContext setEditedObject:_currentAssociationObject];

    // otherwise, by default we don't mark the stuff for creation
    var needsCreation = ![_currentAssociationObject ID];

    // we create or update the association object
    if (needsCreation)
        [_currentContext createEditedObject:self];
    else
        [_currentContext updateEditedObject:self];
}


#pragma mark -
#pragma mark Overrides

- (void)fetcher:(NURESTFetcher)aFetcher ofObject:(id)anObject didFetchContent:(CPArray)someContents
{
    _currentAssociationObject = [someContents firstObject];
    [self didUpdateAssociatedObject:_currentAssociationObject];

    if (_currentAssociationObject)
        [self _fetchAssociatedObjectWithID:[_currentAssociationObject valueForKeyPath:[self keyPathForAssociatedObjectID]]];
}


#pragma mark -
#pragma mark Push Management

- (BOOL)shouldManagePushForEntityType:(CPString)entityType
{
    return (entityType == [[self classForAssociatedObject] RESTName]
            || entityType == [[self classForAssociationObject] RESTName]
            || entityType == [_currentParent RESTName]);
}

- (void)managePushedObject:(id)aJSONObject ofType:(CPString)aType eventType:(CPString)anEventType
{
    [super managePushedObject:aJSONObject ofType:aType eventType:anEventType];

    if (aType != [[self classForAssociationObject] RESTName] || aJSONObject.parentID != [_currentParent ID])
        return;

    switch (anEventType)
    {
        case NUPushEventTypeCreate:
            var newAssociation = [[self classForAssociationObject] new];
            [newAssociation objectFromJSON:aJSONObject];
            [self fetcher:nil ofObject:nil didFetchContent:[newAssociation]];
            break;

        case NUPushEventTypeUpdate:
            [_currentAssociationObject objectFromJSON:aJSONObject];
            [self fetcher:nil ofObject:nil didFetchContent:[_currentAssociationObject]];
            break;

        case NUPushEventTypeDelete:
            [self setCurrentAssociatedObject:nil];
            [self _updateDataViewWithAssociatedObject:nil];
            [self fetcher:nil ofObject:nil didFetchContent:nil];
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
        [self setCurrentAssociatedObject:associatedObject];
        [self _updateDataViewWithAssociatedObject:_currentAssociatedObject];

        if (!_currentAssociationObject)
            _currentAssociationObject = [[self classForAssociationObject] new];

        [self didUpdateAssociatedObject:_currentAssociationObject];
        [self setModified:YES];
    }

    [anObjectChooser closeModulePopover];
}

- (void)moduleContext:(NUModuleContext)aContext didSaveObject:(NUVSDObject)anObject connection:(NURESTConnection)aConnection
{
    [self _sendDelegateDidAssociatorChangeAssociation];
    [self _sendDelegateDidAssociatorAddAssociation];
    [self setModified:NO];
}

- (void)moduleContext:(NUModuleContext)aContext didDeleteObject:(NUVSDObject)anObject connection:(NURESTConnection)aConnection
{
    [self _sendDelegateDidAssociatorChangeAssociation];
    [self _sendDelegateDidAssociatorRemoveAssociation];
    [self setModified:NO];
}

@end
