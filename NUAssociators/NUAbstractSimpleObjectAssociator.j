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

@import "NUAbstractObjectAssociator.j"

/*! NUAbstractSimpleObjectAssociator is teh class you should use for simple one to many
    associations. This is the most commonly used associator.
*/
@implementation NUAbstractSimpleObjectAssociator : NUAbstractObjectAssociator

#pragma mark -
#pragma mark @action

/*! @ignore
*/
- (@action)removeCurrentAssociatedObject:(id)aSender
{
    [_currentParent setValue:nil forKeyPath:[self keyPathForAssociatedObjectID]];

    [self _sendDelegateDidAssociatorChangeAssociation];
    [self _sendDelegateDidAssociatorRemoveAssociation];
}


#pragma mark -
#pragma mark Overrides

/*! @ignore
*/
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

/*! @ignore
*/
- (BOOL)shouldManagePushForEntityType:(CPString)entityType
{
    var entityTypes = [[self associatorSettings] allKeys];
    return [entityTypes containsObject:entityType] || entityType == [_currentParent RESTName];
}

/*! @ignore
*/
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

/*! @ignore
*/
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
