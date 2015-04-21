/*
*   Filename:         NUMessageDataView.j
*   Created:          Wed Jul 31 17:18:08 PDT 2013
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
@import <RESTCappuccino/RESTCappuccino.j>

@import <NUKit/NUAbstractDataView.j>

var NUMessageDataViewImageCheckBoxOkStateOn,
    NUMessageDataViewImageCheckBoxOkStateOff,
    NUMessageDataViewImageCheckBoxOkStateOnPressed,
    NUMessageDataViewImageCheckBoxOkStateOffPressed;

@implementation NUMessageDataView : NUAbstractDataView
{
    @outlet CPCheckBox      checkBoxOK;
    @outlet CPImageView     imageViewSad;
    @outlet CPTextField     fieldDescription;
    @outlet CPTextField     fieldName;
    @outlet CPTextField     fieldReceivedDate;
    @outlet CPView          viewSeverity;

    id                      _currentMessage;
}


#pragma mark -
#pragma mark Initialization

+ (void)initialize
{
   NUMessageDataViewImageCheckBoxOkStateOn             = CPImageInBundle(@"button-message-checkbox-ok-on.png", CGSizeMake(16.0, 16.0));
   NUMessageDataViewImageCheckBoxOkStateOff            = CPImageInBundle(@"button-message-checkbox-cancel-on.png", CGSizeMake(16.0, 16.0));
   NUMessageDataViewImageCheckBoxOkStateOnPressed      = CPImageInBundle(@"button-message-checkbox-ok-on-pressed.png", CGSizeMake(16.0, 16.0));
   NUMessageDataViewImageCheckBoxOkStateOffPressed     = CPImageInBundle(@"button-message-checkbox-cancel-on-pressed.png", CGSizeMake(16.0, 16.0));
}


#pragma mark -
#pragma mark Data View Protocol

- (void)setObjectValue:(id)aMessage
{
    _currentMessage = aMessage;

    [fieldName bind:CPValueBinding toObject:aMessage withKeyPath:@"name" options:nil];
    [fieldName bind:@"toolTip" toObject:aMessage withKeyPath:@"name" options:nil];

    [fieldDescription bind:CPValueBinding toObject:aMessage withKeyPath:@"description" options:nil];
    [fieldDescription bind:@"toolTip" toObject:aMessage withKeyPath:@"description" options:nil];

    [fieldReceivedDate setStringValue:[aMessage receivedDate]];
    [viewSeverity setBackgroundColor:([aMessage className] == @"NURESTError") ? NUSkinColorOrange : NUSkinColorBlue];

    if ([aMessage isKindOfClass:NURESTConfirmation])
    {
        [checkBoxOK bind:CPValueBinding toObject:aMessage withKeyPath:@"currentChoice" options:nil];
        [checkBoxOK setHidden:NO];
        [imageViewSad setHidden:YES];
    }
    else
    {
        [checkBoxOK unbind:CPValueBinding];
        [checkBoxOK setHidden:YES];
        [imageViewSad setHidden:NO];
    }
}

- (IBAction)validate:(id)aSender
{
    if ([_currentMessage isKindOfClass:NURESTConfirmation])
        [_currentMessage setCurrentChoice:1];
}

- (IBAction)cancel:(id)aSender
{
    if ([_currentMessage isKindOfClass:NURESTConfirmation])
        [_currentMessage setCurrentChoice:0];
}


#pragma mark -
#pragma mark CPCoding compliance

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        fieldName         = [aCoder decodeObjectForKey:@"fieldName"];
        fieldDescription  = [aCoder decodeObjectForKey:@"fieldDescription"];
        checkBoxOK        = [aCoder decodeObjectForKey:@"checkBoxOK"];
        viewSeverity      = [aCoder decodeObjectForKey:@"viewSeverity"];
        imageViewSad      = [aCoder decodeObjectForKey:@"imageViewSad"];
        fieldReceivedDate = [aCoder decodeObjectForKey:@"fieldReceivedDate"];

        [checkBoxOK setImage:NUMessageDataViewImageCheckBoxOkStateOn];
        [checkBoxOK setAlternateImage:NUMessageDataViewImageCheckBoxOkStateOnPressed];
        [checkBoxOK setValue:NUMessageDataViewImageCheckBoxOkStateOn forThemeAttribute:@"image" inState:CPThemeStateSelected];
        [checkBoxOK setValue:NUMessageDataViewImageCheckBoxOkStateOff forThemeAttribute:@"image" inState:CPThemeStateNormal];
        [checkBoxOK setValue:NUMessageDataViewImageCheckBoxOkStateOnPressed forThemeAttribute:@"image" inState:CPThemeStateSelected | CPThemeStateHighlighted];
        [checkBoxOK setValue:NUMessageDataViewImageCheckBoxOkStateOffPressed forThemeAttribute:@"image" inState:CPThemeStateNormal | CPThemeStateHighlighted];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:fieldName forKey:@"fieldName"];
    [aCoder encodeObject:fieldDescription forKey:@"fieldDescription"];
    [aCoder encodeObject:checkBoxOK forKey:@"checkBoxOK"];
    [aCoder encodeObject:viewSeverity forKey:@"viewSeverity"];
    [aCoder encodeObject:imageViewSad forKey:@"imageViewSad"];
    [aCoder encodeObject:fieldReceivedDate forKey:@"fieldReceivedDate"];
}

@end
