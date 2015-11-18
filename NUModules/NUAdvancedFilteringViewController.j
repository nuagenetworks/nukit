/*
*   Filename:         NUAdvancedFilteringViewController.j
*   Created:          Tue Jul 22 11:10:43 PST 2013
*   Author:           Christophe SERAFIN <christophe.serafin@alcatel-lucent.com>
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
@import <AppKit/CPPopover.j>
@import <AppKit/CPPredicateEditor.j>
@import <AppKit/CPViewController.j>

@import "NUSkin.j"
@import "NUUtilities.j"

@class  NUModule

@global NURESTObjectAttributeAllowedValuesKey
@global NURESTObjectAttributeDisplayNameKey
@global NUModuleContextCommonControlTagsAsFirstResponder


var NUAdvancedFilteringViewControllerDefault;


@implementation NUAdvancedFilteringViewController : CPViewController
{
    @outlet     CPPredicateEditor   predicateEditorSearch;
    @outlet     CPPopover           popoverPredicateEditorSearch;

    CPArray                         _allowedValuesOperators;
    CPArray                         _dateOperators;
    CPArray                         _numberOperators;
    CPArray                         _stringOperators;
    CPMutableDictionary             _matchingNames;
    NUModule                        _currentModule;
}


#pragma mark -
#pragma mark Initialization

+ (NUAdvancedFilteringViewController)defaultController
{
    if (!NUAdvancedFilteringViewControllerDefault)
    {
        NUAdvancedFilteringViewControllerDefault = [[NUAdvancedFilteringViewController alloc] initWithCibName:@"AdvancedSearchPopover" bundle:[CPBundle bundleForClass:[self class]]];
        [NUAdvancedFilteringViewControllerDefault view];
    }

    return NUAdvancedFilteringViewControllerDefault;
}

- (void)viewDidLoad
{
    [self view]._DOMElement.style.borderRadius = "5px";
    [[predicateEditorSearch superview] setBackgroundColor:NUSkinColorWhite];
    [predicateEditorSearch setRowHeight:24.0];
    [predicateEditorSearch setCanRemoveAllRows:NO];

    _allowedValuesOperators = [[CPArray alloc] initWithObjects:CPEqualToPredicateOperatorType, CPNotEqualToPredicateOperatorType];

    _dateOperators = [[CPArray alloc] initWithObjects:CPLessThanPredicateOperatorType,
                                                      CPLessThanOrEqualToPredicateOperatorType,
                                                      CPGreaterThanPredicateOperatorType,
                                                      CPGreaterThanOrEqualToPredicateOperatorType,
                                                      CPEqualToPredicateOperatorType,
                                                      CPNotEqualToPredicateOperatorType];

    _numberOperators = [[CPArray alloc] initWithObjects:CPLessThanPredicateOperatorType,
                                                        CPLessThanOrEqualToPredicateOperatorType,
                                                        CPGreaterThanPredicateOperatorType,
                                                        CPGreaterThanOrEqualToPredicateOperatorType,
                                                        CPEqualToPredicateOperatorType,
                                                        CPNotEqualToPredicateOperatorType];

    _stringOperators = [[CPArray alloc] initWithObjects:CPContainsPredicateOperatorType,
                                                        CPEqualToPredicateOperatorType,
                                                        CPNotEqualToPredicateOperatorType,
                                                        CPMatchesPredicateOperatorType,
                                                        CPLikePredicateOperatorType,
                                                        CPBeginsWithPredicateOperatorType,
                                                        CPEndsWithPredicateOperatorType];

    _cucappID([[popoverPredicateEditorSearch contentViewController] view], @"popover_advanced_search");
}


#pragma mark -
#pragma mark Action Management

- (@action)clickApplyButton:(id)aSender
{
    [self closePopover];

    [self _switchPredicateLeftExpressionValue];
    [_currentModule applyAdvancedFilters:[[predicateEditorSearch predicate] predicateFormat]];
}


#pragma mark -
#pragma mark Popover Management

- (void)openPopoverOnView:(id)aSender forModule:(NUModule)aModule object:(id)anObject predicateFormat:(CPString)aString
{
    [self closePopover];

    if (aModule != _currentModule)
    {
        [self _reset];
        _currentModule = aModule;

        [predicateEditorSearch setRowTemplates:[self _rowTemplatesForObject:anObject]];
        [predicateEditorSearch setObjectValue:[self _predicateFromFormat:aString]];
    }

    if ([[predicateEditorSearch rowTemplates] count] <= 1)  // No filters, No popover
        return;

    [self _switchPredicateLeftExpressionValue];

    [popoverPredicateEditorSearch showRelativeToRect:nil ofView:aSender preferredEdge:CPMaxXEdge];

    var applyButton = [[[popoverPredicateEditorSearch contentViewController] view] subviewWithTag:@"apply"];
    [popoverPredicateEditorSearch setDefaultButton:applyButton];
    _cucappID(applyButton, @"button_apply_search");

    if (![predicateEditorSearch numberOfRows])
        [predicateEditorSearch addRow:nil];
}

- (void)closePopover
{
    [popoverPredicateEditorSearch makeFirstResponder:nil];
    [popoverPredicateEditorSearch close];
}


#pragma mark -
#pragma mark Private methods

- (CPPredicate)_predicateFromFormat:(CPString)aString
{
    var predicate = nil,
        rowTemplates = [predicateEditorSearch rowTemplates];

    try { predicate = [CPPredicate predicateWithFormat:aString]; } catch (e) {}

    return predicate
}

- (void)_switchPredicateLeftExpressionValue
{
    var subpredicates = [[predicateEditorSearch predicate] subpredicates];

    for (var i = [subpredicates count] - 1; i >= 0; i--)
    {
        var subpredicate = subpredicates[i],
            currentName = [[[subpredicate leftExpression] pathExpression] keyPath];

        [[subpredicate leftExpression] pathExpression]._value = [_matchingNames objectForKey:currentName];
    }
}

- (CPArray)_rowTemplatesForObject:(id)anObject
{
    if (!anObject)
        return [];

    var attributes      = [anObject searchAttributes],
        attributeNames  = [self _reorderWithCommonControlTagsFirst:[attributes allKeys]],
        compound        = [[CPPredicateEditorRowTemplate alloc] initWithCompoundTypes:[CPOrPredicateType, CPAndPredicateType, CPNotPredicateType]],
        rowTemplates    = [[CPArray alloc] initWithObjects:compound];

    for (var i = [attributeNames count] - 1; i >= 0 ; i--)
    {
        var attributeName   = attributeNames[i],
            attribute       = [attributes objectForKey:attributeName],
            displayName     = [attribute objectForKey:NURESTObjectAttributeDisplayNameKey],
            rowTemplate;

        // Register display name linked to the attribute name
        [_matchingNames setObject:attributeName forKey:displayName];
        [_matchingNames setObject:displayName forKey:attributeName];

        if ([attribute containsKey:NURESTObjectAttributeAllowedValuesKey])
        {
            var allowedValues = [attribute objectForKey:NURESTObjectAttributeAllowedValuesKey],
                expressions = [CPArray array];

            for (var idx = [allowedValues count] - 1; idx >= 0; idx--)
                [expressions addObject:[CPExpression expressionForConstantValue:allowedValues[idx]]];

            rowTemplate = [[CPPredicateEditorRowTemplate alloc] initWithLeftExpressions:[[CPExpression expressionForKeyPath:displayName]]
                                                                       rightExpressions:expressions
                                                                               modifier:CPDirectPredicateModifier
                                                                              operators:_allowedValuesOperators
                                                                                options:[CPCaseInsensitivePredicateOption]];
        }
        else
        {
            var attributeType,
                operators,
                stringType = [anObject typeOfLocalKeyPath:attributeName];

            switch (stringType)
            {
                case "CPString":
                case "CPArray":
                case "CPArrayController":
                    attributeType = CPStringAttributeType
                    operators = _stringOperators;
                    break;

                case "float":
                    attributeType = CPInteger16AttributeType
                    operators = _numberOperators;
                    break;

                case "int":
                case "CPNumber":
                    attributeType = CPFloatAttributeType
                    operators = _numberOperators;
                    break;

                case "BOOL":
                    attributeType = CPBooleanAttributeType
                    operators = _allowedValuesOperators;
                    break;

                case "CPDate":
                    attributeType = CPDateAttributeType
                    operators = _dateOperators;
                    break;

                default:
                    [CPException raise:CPInvalidArgumentException reason:@"[NUAdvancedFilteringViewController] Cannot find type " + stringType + " for attribute " + attributeName + " of object " + [anObject class] ];
            }

            rowTemplate = [[CPPredicateEditorRowTemplate alloc] initWithLeftExpressions:[[CPExpression expressionForKeyPath:displayName]]
                                                           rightExpressionAttributeType:attributeType
                                                                               modifier:CPDirectPredicateModifier
                                                                              operators:operators
                                                                                options:[CPCaseInsensitivePredicateOption]];
        }

        [rowTemplates addObject:rowTemplate];
    }

    return rowTemplates;
}

- (CPArray)_reorderWithCommonControlTagsFirst:(CPArray)anArray
{
    var firstObjects = [CPMutableArray new],
        otherObjects = [CPMutableArray new];

    for (var i = [NUModuleContextCommonControlTagsAsFirstResponder count] - 1; i >= 0; i--)
    {
        var object = NUModuleContextCommonControlTagsAsFirstResponder[i];

        if ([anArray containsObject:object])
        {
            [firstObjects addObject:object];
        }
    }

    firstObjects = firstObjects.reverse();

    for (var i = [anArray count] - 1; i >= 0; i--)
    {
        var object = anArray[i];

        if (![firstObjects containsObject:object])
            [otherObjects addObject:object];
    }

    return otherObjects.concat(firstObjects);
}

- (void)_reset
{
    _currentModule = nil;
    _matchingNames = [[CPMutableDictionary alloc] init];

    for (var i = [predicateEditorSearch numberOfRows] - 1; i >= 0; i--)
        [predicateEditorSearch removeRowAtIndex:i];
}

@end
