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
@import <AppKit/CPButton.j>

@import "NUAbstractObjectAssociator.j"
@import "NUModuleContext.j"

/*! NUAbstractAdvancedObjectAssociator is the class you should use to create
    association that requires an association object.
*/
@implementation NUAbstractAdvancedObjectAssociator : NUAbstractObjectAssociator
{
    id              _currentAssociationObject    @accessors(property=currentAssociationObject);

    NUModuleContext _currentContext;
}

#pragma mark -
#pragma mark Initialization

/*! @ignore
*/
- (void)viewDidLoad
{
    [super viewDidLoad];

    _currentContext = [self contextForAssociationObject];
    [_currentContext setDelegate:self];
}


#pragma mark -
#pragma mark NUAbstractAdvancedObjectAssociator Protocol

/*! Implement this to return the fetcher that must be used to
    retreieve the association object
*/
- (NURESTFetcher)fetcherOfAssociationObject
{
    throw ("implement me");
}

/*! Implement this to return the NUModuleContext that should be used
    to manipulate the association object.
*/
- (NUModuleContext)contextForAssociationObject
{
    throw ("implement me");
}

/*! Implement this to return the class of the association object.
*/
- (Class)classForAssociationObject
{
    throw ("implement me");
}

/*! Implement this to update the associatuon object when the user selects an associated object.
*/
- (void)updateAssociationObject:(id)anAssociationObject withAssociatedObject:(id)anAssociatedObject
{
    throw ("implement me");
}

/*! Internal API that you can override to perform additonal operations
    after the associated has been updated.
*/
- (void)didUpdateAssociatedObject:(id)anAssociatedObject
{

}


#pragma mark -
#pragma mark Overrides

/*! @ignore
*/
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

/*! @ignore
*/
- (@action)removeCurrentAssociatedObject:(id)aSender
{
    [self _updateDataViewWithAssociatedObject:nil];
    [self _sendDelegateDidAssociatorChangeAssociation];
    [self _sendDelegateDidAssociatorRemoveAssociation];
    [self didUpdateAssociatedObject:nil];
    [self setModified:YES];
}

/*! @ignore
*/
- (@action)save:(id)aSender
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
    }
    else
    {
        [self updateAssociationObject:[_currentContext editedObject] withAssociatedObject:_currentAssociatedObject];

        if (![_currentAssociationObject ID])
            [_currentContext createEditedObject:self];
        else
            [_currentContext updateEditedObject:self];
    }
}


#pragma mark -
#pragma mark Overrides

/*! @ignore
*/
- (void)fetcher:(NURESTFetcher)aFetcher ofObject:(id)anObject didFetchContent:(CPArray)someContents
{
    _currentAssociationObject = [someContents firstObject];
    [_currentContext setEditedObject:_currentAssociationObject]

    [self didUpdateAssociatedObject:_currentAssociationObject];

    if (_currentAssociationObject)
        [self _fetchAssociatedObjectWithID:[_currentAssociationObject valueForKeyPath:[self keyPathForAssociatedObjectID]]];
}


#pragma mark -
#pragma mark Push Management

/*! @ignore
*/
- (BOOL)shouldManagePushForEntityType:(CPString)entityType
{
    var entityTypes = [[self associatorSettings] allKeys];
    return ([entityTypes containsObject:entityType]
            || entityType == [[self classForAssociationObject] RESTName]
            || entityType == [_currentParent RESTName]);
}

/*! @ignore
*/
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

/*! @ignore
*/
- (void)didObjectChooser:(NUObjectsChooser)anObjectChooser selectObjects:(CPArray)selectedObjects
{
    var associatedObject = [selectedObjects firstObject];

    if (![associatedObject isEqual:_currentAssociatedObject])
    {
        [self setCurrentAssociatedObject:associatedObject];
        [self _updateDataViewWithAssociatedObject:_currentAssociatedObject];

        if (!_currentAssociationObject)
        {
            _currentAssociationObject = [[self classForAssociationObject] new];
            [_currentContext setEditedObject:_currentAssociationObject]
        }

        [self didUpdateAssociatedObject:_currentAssociationObject];
        [self _sendDelegateDidAssociatorChangeAssociation];
        [self _sendDelegateDidAssociatorAddAssociation];
        [self setModified:YES];
    }

    [anObjectChooser closeModulePopover];
}

/*! @ignore
*/
- (void)moduleContext:(NUModuleContext)aContext didSaveObject:(id)anObject connection:(NURESTConnection)aConnection
{
    [self setModified:NO];
}

/*! @ignore
*/
- (void)moduleContext:(NUModuleContext)aContext didDeleteObject:(id)anObject connection:(NURESTConnection)aConnection
{
    [self setModified:NO];
}

@end
