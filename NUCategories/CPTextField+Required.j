/*
*   Filename:         CPTextField+Required.j
*   Created:          Mon Jan 28 14:32:51 PST 2013
*   Author:           Antoine Mercadal <antoine.mercadal@alcatel-lucent.com>
*   Description:      VSA
*   Project:          Cloud Network Automation - Nuage - Data Center Service Delivery - IPD
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
@import <AppKit/CPTextField.j>
@import <AppKit/CPImageView.j>

var CPTextFieldImageRequired = nil;

NUThemeStateError = CPThemeState("NUThemeStateError");

@implementation CPTextField (RequiredMode)

- (void)setRequired:(BOOL)isRequired
{
    if (self.__required == isRequired)
        return;

    self.__required = isRequired;

    if (isRequired)
    {
        if (!CPTextFieldImageRequired)
            CPTextFieldImageRequired = CPImageInBundle(@"required.png", CGSizeMake(8, 8));

        self.__requiredImageView = [[CPImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        [self.__requiredImageView setAutoresizingMask:CPViewMinXMargin];
        [self.__requiredImageView setImage:CPTextFieldImageRequired];
        [self.__requiredImageView setToolTip:@"This field is required"];

        var opts = @{CPValueTransformerNameBindingOption: CPNegateBooleanTransformerName};
        [self.__requiredImageView bind:CPHiddenBinding toObject:self withKeyPath:CPEnabledBinding options:opts];

        var currentFrame = [self bounds];
        [self.__requiredImageView setFrameOrigin:CGPointMake(CGRectGetWidth(currentFrame) - 16, CGRectGetMidY(currentFrame) - 4)];
        [self addSubview:self.__requiredImageView];
        [self setValue:CGInsetMake(4.0, 20.0, 0.0, 6.0) forThemeAttribute:@"content-inset" inState:CPThemeStateBezeled];
        [self setValue:CGInsetMake(4.0, 20.0, 0.0, 6.0) forThemeAttribute:@"content-inset" inState:[CPThemeStateBezeled, CPThemeStateEditing]];
    }
    else
    {
        if (self.__requiredImageView)
            [self.__requiredImageView removeFromSuperview];
        [self setValue:CGInsetMake(4.0, 6.0, 0.0, 6.0) forThemeAttribute:@"content-inset" inState:CPThemeStateBezeled];
        [self setValue:CGInsetMake(4.0, 6.0, 0.0, 6.0) forThemeAttribute:@"content-inset" inState:[CPThemeStateBezeled, CPThemeStateEditing]];
    }
}

- (BOOL)isRequired
{
    return !!self.__required;
}

- (void)setInvalid:(BOOL)isInvalid reason:(CPString)aReason
{
    if (self.__invalid == isInvalid)
        return;

    self.__invalid = isInvalid;

    if (isInvalid)
    {
        if (!self.__errorView)
        {
            self.__errorView = [[NUDataViewsRegistry dataViewForName:@"viewInvalidInput"] duplicate];
            [self.__errorView setAutoresizingMask:CPViewMinXMargin];
        }

        var currentFrame = [self bounds],
            currentSize = [self.__errorView frameSize],
            bezelInset = [self valueForThemeAttribute:@"bezel-inset" inState:CPThemeStateBezeled];

        currentSize.height = currentFrame.size.height -  bezelInset.top - bezelInset.bottom - 2;

        [self.__errorView setFrameSize:currentSize];
        [self.__errorView setFrameOrigin:CGPointMake(CGRectGetWidth(currentFrame) - currentSize.width - bezelInset.right - 1,
                                         CGRectGetMidY(currentFrame) - (currentSize.height / 2))];
        [self setValue:CGInsetMake(4.0, currentSize.width + 5, 0.0, 6.0) forThemeAttribute:@"content-inset" inState:CPThemeStateBezeled];
        [self setValue:CGInsetMake(4.0, currentSize.width + 5, 0.0, 6.0) forThemeAttribute:@"content-inset" inState:[CPThemeStateBezeled, CPThemeStateEditing]];

        [self addSubview:self.__errorView positioned:CPWindowAbove relativeTo:nil];

        if (aReason)
            [self.__errorView setToolTip:aReason];
    }
    else
    {
        if (self.__errorView)
        {
            [self.__errorView removeFromSuperview];
            [self.__errorView setToolTip:nil];
        }

        if (!self.__required)
        {
            [self setValue:CGInsetMake(4.0, 6.0, 0.0, 6.0) forThemeAttribute:@"content-inset" inState:CPThemeStateBezeled];
            [self setValue:CGInsetMake(4.0, 6.0, 0.0, 6.0) forThemeAttribute:@"content-inset" inState:[CPThemeStateBezeled, CPThemeStateEditing]];
        }
        else
        {
            [self setValue:CGInsetMake(4.0, 20.0, 0.0, 6.0) forThemeAttribute:@"content-inset" inState:CPThemeStateBezeled];
            [self setValue:CGInsetMake(4.0, 20.0, 0.0, 6.0) forThemeAttribute:@"content-inset" inState:[CPThemeStateBezeled, CPThemeStateEditing]];
        }
    }

    if (isInvalid)
        [self setThemeState:NUThemeStateError];
    else
        [self unsetThemeState:NUThemeStateError];

}

- (BOOL)isInvalid
{
    return !!self.__invalid;
}

@end
