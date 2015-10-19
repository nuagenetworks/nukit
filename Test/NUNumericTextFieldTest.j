/*
*   Filename:         NUNumericTextFieldTest.j
*   Created:          Thu Oct 15 13:19:55 PDT 2015
*   Author:           Alexandre Wilhelm <alexandre.wilhelm@alcatel-lucent.com>
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

    _numericTextField = [[NUNumericTextField alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];

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
    // [_numericTextField setStringValue:@"diehrir"];
    // [self assert:@"" equals:[_numericTextField stringValue]];
    //
    // [_numericTextField setStringValue:1];
    // [self assert:@"1" equals:[_numericTextField stringValue]];
    //
    // [_numericTextField setStringValue:""];
    // [self assert:@"" equals:[_numericTextField stringValue]];
    //
    // [_numericTextField setStringValue:2];
    // [self assert:@"2" equals:[_numericTextField stringValue]];
    //
    // [_numericTextField setStringValue:nil];
    // [self assert:"" equals:[_numericTextField stringValue]];
}

@end