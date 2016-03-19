/*
*   Filename:         NUModuleAssignation.j
*   Created:          Tue Sep 16 14:48:06 PDT 2014
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
@import "NUModule.j"
@import "NUObjectsChooser.j"

@class NUKit

@global CPApp
@global NUModuleAutoValidation


NUModuleAssignationActionAssign   = @"NUModuleAssignationActionAssign";
NUModuleAssignationActionUnassign = @"NUModuleAssignationctionUnassign";

/*! NUModuleAssignation is a variant of NUModule. Its goal is to manage assignation
    instead of CRUD operations.
*/
@implementation NUModuleAssignation : NUModule
{
    NUObjectsChooser    _chooser;
    CPButton            _buttonFirstAssign;
    CPButton            _buttonUnassignObject;
    CPButton            _buttonAssignObject;
}


#pragma mark -
#pragma mark Initialization

/*! Called when the view is loaded
*/
- (void)viewDidLoad
{
    [super viewDidLoad];

    _chooser = [NUObjectsChooser new];
    [_chooser setDelegate:self];
    [self configureObjectsChooser:_chooser];
}

/*! Configures additional controls for actions NUModuleAssignationActionAssign and NUModuleAssignationActionUnassign
*/
- (void)configureAdditionalControls
{
    if (buttonBarMain)
    {
        _buttonAssignObject = [CPButtonBar plusButton];
        [_buttonAssignObject setImage:NUSkinImageButtonLink];
        [_buttonAssignObject setAlternateImage:NUSkinImageButtonLinkAlt];
        [_buttonAssignObject setButtonType:CPMomentaryChangeButton];
        [_buttonAssignObject setTarget:self];
        [_buttonAssignObject setAction:@selector(openAssignObjectPopover:)];
        [self registerControl:_buttonAssignObject forAction:NUModuleAssignationActionAssign];

        _buttonUnassignObject = [CPButtonBar minusButton];
        [_buttonUnassignObject setImage:NUSkinImageButtonUnlink];
        [_buttonUnassignObject setAlternateImage:NUSkinImageButtonUnlinkAlt];
        [_buttonUnassignObject setButtonType:CPMomentaryChangeButton];
        [_buttonUnassignObject setTarget:self];
        [_buttonUnassignObject setAction:@selector(openUnassignObjectPopover:)];
        [self registerControl:_buttonUnassignObject forAction:NUModuleAssignationActionUnassign];

        [buttonBarMain setButtons:[_buttonAddObject, _buttonAssignObject, _buttonDeleteObject, _buttonUnassignObject, _buttonEditObject, _buttonInstantiateObject]];
    }

    if (viewGettingStarted)
    {
        var container = [[viewGettingStarted subviewWithTag:@"container"] subviewWithTag:@"buttonscontainer"];
        _buttonFirstAssign = [container subviewWithTag:@"first_assign_button"];

        if (_buttonFirstAssign)
        {
            [_buttonFirstAssign setBordered:NO];
            [_buttonFirstAssign setButtonType:CPMomentaryChangeButton];
            [_buttonFirstAssign setValue:CPImageInBundle("button-first-assign.png", 32.0, 32.0, [[NUKit kit]  bundle]) forThemeAttribute:@"image" inState:CPThemeStateNormal];
            [_buttonFirstAssign setValue:CPImageInBundle("button-first-assign-pressed.png", 32.0, 32.0, [[NUKit kit]  bundle]) forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
            [_buttonFirstAssign setTarget:self];
            [_buttonFirstAssign setAction:@selector(openAssignObjectPopover:)];

            [self registerControl:_buttonFirstAssign forAction:NUModuleAssignationActionAssign];
        }
    }
}

/*! Configure contextual menu for NUModuleAssignationActionAssign and NUModuleAssignationActionUnassign
*/
- (CPArray)configureContextualMenu
{
    var menuItemAssign = [[CPMenuItem alloc] initWithTitle:@"Assign..." action:@selector(openAssignObjectPopover:) keyEquivalent:@""];
    [self registerMenuItem:menuItemAssign forAction:NUModuleAssignationActionAssign];

    var menuItemUnassign = [[CPMenuItem alloc] initWithTitle:@"Unassign..." action:@selector(openUnassignObjectPopover:) keyEquivalent:@""];
    [self registerMenuItem:menuItemUnassign forAction:NUModuleAssignationActionUnassign];

    var actionOrder = [super configureContextualMenu];
    [actionOrder insertObject:NUModuleAssignationActionAssign atIndex:1];
    [actionOrder insertObject:NUModuleAssignationActionUnassign atIndex:3];

    return actionOrder;
}

/*! Configure the cucappID prefix for NUModuleAssignationActionAssign and NUModuleAssignationActionUnassign
*/
- (void)configureCucappIDs
{
    [super configureCucappIDs];

    [self setCuccapPrefix:@"assign" forAction:NUModuleAssignationActionAssign];
    [self setCuccapPrefix:@"unassign" forAction:NUModuleAssignationActionUnassign];
}

/*! Correctly update the cucappIDs
*/
- (void)updateCucappIDsAccordingToContext:(NUModuleContext)aContext
{
    [super updateCucappIDsAccordingToContext:aContext];

    if (_buttonFirstAssign)
        _cucappID(_buttonFirstAssign, @"button_" + [self cuccapPrefixForAction:NUModuleAssignationActionAssign] + @"_" + [aContext identifier]);

    _cucappID(_buttonUnassignObject, @"button_" + [self cuccapPrefixForAction:NUModuleAssignationActionUnassign] + @"_" + [aContext identifier]);
    _cucappID(_buttonAssignObject, @"button_" + [self cuccapPrefixForAction:NUModuleAssignationActionAssign] + @"_" + [aContext identifier]);
}


#pragma mark -
#pragma mark NUModuleAssignation API

/*! This needs to be implemented by your module.
    You usually set the mandatory value for the NUObjectChooser.
*/
- (void)configureObjectsChooser:(NUObjectChooser)anObjectChooser
{
    throw "Not implemented";
}

/*! This is called to actually perform the assignation
*/
- (void)assignObjects:(CPArray)someObjects
{
    throw "Not implemented";
}

/*! This is called to when the parent of the associated objects is needed
*/
- (id)parentOfAssociatedObject
{
    throw "Not implemented";
}

/*! Custom implementation of the shouldManagePushForEventualInnerObject:
*/
- (BOOL)shouldManagePushForEventualInnerObject:(id)aJSONObject
{
    return [[[self flattenedDataSourceContent] filteredArrayUsingPredicate:[CPPredicate predicateWithFormat:@"ID == %@", aJSONObject.ID]] count];
}


#pragma mark -
#pragma mark NUModule API

/*! Define the default permitted actions
*/
- (CPSet)permittedActionsForObject:(id)anObject
{
    var permittedActions = [super permittedActionsForObject:anObject];

    if ([permittedActions containsObject:NUModuleActionEdit])
        [permittedActions removeObject:NUModuleActionEdit]

    if ([permittedActions containsObject:NUModuleActionAdd])
    {
        [permittedActions removeObject:NUModuleActionAdd];
        [permittedActions addObject:NUModuleAssignationActionAssign];
    }

    if ([permittedActions containsObject:NUModuleActionDelete])
    {
        [permittedActions removeObject:NUModuleActionDelete];
        [permittedActions addObject:NUModuleAssignationActionUnassign];
    }

    return permittedActions;
}

/*! @ignore
*/
- (BOOL)shouldManagePushOfType:(CPString)aType forEntityType:(CPString)entityType
{
    return (entityType == [_currentParent RESTName] && NUPushEventTypeUpdate) || [super shouldManagePushOfType:aType forEntityType:entityType];
}

/*! @ignore
*/
- (BOOL)shouldProcessJSONObject:(id)aJSONObject ofType:(CPString)aType eventType:(CPString)anEventType
{
    if (anEventType == NUPushEventTypeUpdate && aJSONObject.ID == [_currentParent ID])
        [self reload];

    if ([self shouldManagePushForEventualInnerObject:aJSONObject])
        return YES;

    return [super shouldProcessJSONObject:aJSONObject ofType:aType eventType:anEventType];
}


#pragma mark -
#pragma mark Assignation & Unassignation

/*! Opens the assign object chooser
*/
- (@action)openAssignObjectPopover:(id)aSender
{
    var action = [aSender isKindOfClass:CPMenuItem] ? [self actionForMenuItem:aSender] : [self actionForControl:aSender];

    if ([aSender isKindOfClass:CPMenuItem])
        aSender = [self controlsForAction:action][0];

    [self setCurrentContext:[self defaultContextForAction:action]];

    var context = [self currentContext];

    [_chooser setIgnoredObjects:[[self flattenedDataSourceContent] copy]];
    [_chooser configureFetcherKeyPath:[context fetcherKeyPath] forClass:[context managedObjectClass]];
    [_chooser showOnView:aSender forParentObject:[self parentOfAssociatedObject]];
}

/*! Opens the unassign popover
*/
- (@action)openUnassignObjectPopover:(id)aSender
{
    if (NUModuleAutoValidation || [[CPApp currentEvent] modifierFlags] & CPShiftKeyMask)
    {
        [self _performUnassignObjects:nil];
        return;
    }

    var popoverConfirmation = [[NUKit kit] registeredDataViewWithIdentifier:@"popoverConfirmation"],
        buttonConfirm = [[[popoverConfirmation contentViewController] view] subviewWithTag:@"confirm"],
        relativeRect;

    [buttonConfirm setTarget:self];
    [buttonConfirm setAction:@selector(_performUnassignObjects:)];
    _cucappID(buttonConfirm, @"button_popover_confirm_delete");

    if ([aSender isKindOfClass:CPMenuItem])
        aSender = [self defaultPopoverTargetForMenuItem];

    if ([aSender isKindOfClass:CPTableView])
    {
        relativeRect = computeRelativeRectOfSelectedRow(aSender);
        aSender = [aSender enclosingScrollView];
    }

    [popoverConfirmation showRelativeToRect:relativeRect ofView:aSender preferredEdge:CPMinYEdge];
    [popoverConfirmation setDefaultButton:buttonConfirm];
}

/*! @ignore
*/
- (@action)_performUnassignObjects:(id)aSender
{
    var content = [CPArray arrayWithArray:[self flattenedDataSourceContent]];
    [content removeObjectsInArray:_currentSelectedObjects];
    [self assignObjects:content];

    [[[NUKit kit] registeredDataViewWithIdentifier:@"popoverConfirmation"] close];
}


#pragma mark -
#pragma mark Delegates

/*! @ignore
*/
- (void)didObjectChooser:(NUObjectsChooser)anObjectChooser selectObjects:(CPArray)selectedObjects
{
    var content = [CPArray arrayWithArray:[[self flattenedDataSourceContent] copy]];
    [content addObjectsFromArray:selectedObjects];
    [self assignObjects:content];
    [_chooser closeModulePopover];
}

@end
