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
@import <AppKit/CPPopover.j>
@import <AppKit/CPPredicateEditor.j>
@import <AppKit/CPViewController.j>

@import "NUSkin.j"
@import "NUUtilities.j"

@class  NUModule
@class  NUModuleContext

@global NURESTObjectAttributeAllowedValuesKey
@global NURESTObjectAttributeDisplayNameKey

var NUAdvancedFilteringViewControllerDefault;

/*! NUAdvancedFilteringViewControllerDefault is the class that is responsible
    For building the advanced search interface.
    You should never need to use this by yourself. NUModule will use it when needed.
*/
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
    [_currentModule applyAdvancedFilters:[predicateEditorSearch predicate] ];
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
        otherObjects = [CPMutableArray new],
        tags         = [NUModuleContext defaultFirstResponderTags];

    for (var i = [tags count] - 1; i >= 0; i--)
    {
        var object = tags[i];

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
