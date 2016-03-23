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

@import "NUAbstractDataView.j"


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
   NUMessageDataViewImageCheckBoxOkStateOn         = NUImageInKit(@"button-message-checkbox-ok-on.png", 16.0, 16.0);
   NUMessageDataViewImageCheckBoxOkStateOff        = NUImageInKit(@"button-message-checkbox-cancel-on.png", 16.0, 16.0);
   NUMessageDataViewImageCheckBoxOkStateOnPressed  = NUImageInKit(@"button-message-checkbox-ok-on-pressed.png", 16.0, 16.0);
   NUMessageDataViewImageCheckBoxOkStateOffPressed = NUImageInKit(@"button-message-checkbox-cancel-on-pressed.png", 16.0, 16.0);
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

- (@action)validate:(id)aSender
{
    if ([_currentMessage isKindOfClass:NURESTConfirmation])
        [_currentMessage setCurrentChoice:1];
}

- (@action)cancel:(id)aSender
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
