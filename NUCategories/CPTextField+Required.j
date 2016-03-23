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
@import <AppKit/CPTextField.j>
@import <AppKit/CPImageView.j>

@class NUKit


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
            CPTextFieldImageRequired = NUImageInKit(@"required.png", CGSizeMake(8, 8));

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
        [self setValue:CGInsetMake(4.0, 20.0, 0.0, 6.0) forThemeAttribute:@"content-inset" inStates:[CPThemeStateBezeled, CPThemeStateEditing]];
    }
    else
    {
        if (self.__requiredImageView)
            [self.__requiredImageView removeFromSuperview];
        [self setValue:CGInsetMake(4.0, 6.0, 0.0, 6.0) forThemeAttribute:@"content-inset" inState:CPThemeStateBezeled];
        [self setValue:CGInsetMake(4.0, 6.0, 0.0, 6.0) forThemeAttribute:@"content-inset" inStates:[CPThemeStateBezeled, CPThemeStateEditing]];
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
            self.__errorView = [[[NUKit kit] registeredDataViewWithIdentifier:@"viewInvalidInput"] duplicate];
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
        [self setValue:CGInsetMake(4.0, currentSize.width + 5, 0.0, 6.0) forThemeAttribute:@"content-inset" inStates:[CPThemeStateBezeled, CPThemeStateEditing]];

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
            [self setValue:CGInsetMake(4.0, 6.0, 0.0, 6.0) forThemeAttribute:@"content-inset" inStates:[CPThemeStateBezeled, CPThemeStateEditing]];
        }
        else
        {
            [self setValue:CGInsetMake(4.0, 20.0, 0.0, 6.0) forThemeAttribute:@"content-inset" inState:CPThemeStateBezeled];
            [self setValue:CGInsetMake(4.0, 20.0, 0.0, 6.0) forThemeAttribute:@"content-inset" inStates:[CPThemeStateBezeled, CPThemeStateEditing]];
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
