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

@import <AppKit/CPButton.j>
@import "NUSkin.j"


@implementation CPButton (color)

- (void)setRed
{
    [self setValue:[CPColor colorWithHexString:@"E1414F"] forThemeAttribute:@"bezel-color" inState:CPThemeStateNormal];
    [self setValue:[CPColor colorWithHexString:@"911E22"] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateNormal];
    [self setValue:[CPColor whiteColor] forThemeAttribute:@"text-color" inState:CPThemeStateNormal];

    [self setValue:[CPColor colorWithHexString:@"BC2F3E"] forThemeAttribute:@"bezel-color" inState:CPThemeStateHighlighted];
    [self setValue:[CPColor colorWithHexString:@"911E22"] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateHighlighted];
    [self setValue:[CPColor whiteColor] forThemeAttribute:@"text-color" inState:CPThemeStateHighlighted];

    [self setValue:NUSkinColorGreyLight forThemeAttribute:@"bezel-color" inState:CPThemeStateDisabled];
    [self setValue:[CPColor colorWithCalibratedWhite:240.0 / 255.0 alpha:0.6] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateDisabled];
    [self setValue:[CPColor colorWithCalibratedWhite:79.0 / 255.0 alpha:0.6] forThemeAttribute:@"text-color" inState:CPThemeStateDisabled];


    [self setNeedsLayout];
}

- (void)setBGColor:(CPString)aColor
{
    switch (aColor)
    {
        case @"red":
            [self setRed];
            break;
    }
}

@end
