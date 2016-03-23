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
@import <AppKit/AppKit.j>

@import "../NUControls/NUNumericTextField.j"

@implementation NUNumericTextFieldTest : OJTestCase
{
    CPWindow            _window;
    NUNumericTextField  _numericTextField;
}

+ (void)setUp
{

}

+ (void)tearDown
{

}

- (void)setUp
{
    [[CPApplication alloc] init];
    _window = [[CPWindow alloc] initWithContentRect:CGRectMake(0.0, 0.0, 1000.0, 1000.0) styleMask:CPWindowNotSizable];

    _numericTextField = [NUNumericTextField textFieldWithStringValue:"" placeholder:"" width:200];

    [[_window contentView] addSubview:_numericTextField];
}

- (void)tearDown
{

}

- (void)testCreate
{

}

- (void)testStringValue
{
    [_numericTextField setStringValue:@"diehrir"];
    [self assert:@"" equals:[_numericTextField stringValue]];

    [_numericTextField setStringValue:1];
    [self assert:@"1" equals:[_numericTextField stringValue]];

    [_numericTextField setStringValue:""];
    [self assert:@"" equals:[_numericTextField stringValue]];

    [_numericTextField setStringValue:2];
    [self assert:@"2" equals:[_numericTextField stringValue]];
}

- (void)testStringValueWithDecimal
{
    [_numericTextField setAllowDecimals:YES];

    [_numericTextField setStringValue:@"diehrir"];
    [self assert:@"" equals:[_numericTextField stringValue]];

    [_numericTextField setStringValue:1.4];
    [self assert:@"1.4" equals:[_numericTextField stringValue]];

    [_numericTextField setStringValue:""];
    [self assert:@"" equals:[_numericTextField stringValue]];

    [_numericTextField setStringValue:2434.123];
    [self assert:@"2434.123" equals:[_numericTextField stringValue]];
}


@end
