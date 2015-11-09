/*
*   Filename:         NUNetworkFieldTest.j
*   Created:          Thu Oct 15 10:05:56 PDT 2015
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

@import "../NUControls/NUNetworkTextField.j"

@implementation NUNetworkTextFieldTest : OJTestCase
{
    CPWindow            _window;
    NUNetworkTextField  _networkTextField;
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
    _networkTextField = [[NUNetworkTextField alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];

    [[_window contentView] addSubview:_networkTextField];
}

- (void)tearDown
{

}

- (void)testCreate
{
    [_networkTextField setNeedsLayout];
    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}

- (void)testSelection
{
    [_window makeFirstResponder:_networkTextField];
    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];

    var expectedFirstResponder = _networkTextField._networkElementTextFields[0];
    [self assert:[_window firstResponder] equals:expectedFirstResponder];

    var expectedFirstResponder = _networkTextField._networkElementTextFields[1];
    [_networkTextField _selectNextTextField];
    [self assert:[_window firstResponder] equals:expectedFirstResponder];

    var expectedFirstResponder = _networkTextField._networkElementTextFields[2];
    [_networkTextField _selectNextTextField];
    [self assert:[_window firstResponder] equals:expectedFirstResponder];

    var expectedFirstResponder = _networkTextField._networkElementTextFields[3];
    [_networkTextField _selectNextTextField];
    [self assert:[_window firstResponder] equals:expectedFirstResponder];

    var expectedFirstResponder = _networkTextField._networkElementTextFields[4];
    [_networkTextField _selectNextTextField];
    [self assert:[_window firstResponder] equals:expectedFirstResponder];

    var expectedFirstResponder = _networkTextField._networkElementTextFields[4];
    [_networkTextField _selectNextTextField];
    [self assert:[_window firstResponder] equals:expectedFirstResponder];

    var expectedFirstResponder = _networkTextField._networkElementTextFields[3];
    [_networkTextField _selectPreviousTextField];
    [self assert:[_window firstResponder] equals:expectedFirstResponder];

    var expectedFirstResponder = _networkTextField._networkElementTextFields[2];
    [_networkTextField _selectPreviousTextField];
    [self assert:[_window firstResponder] equals:expectedFirstResponder];

    var expectedFirstResponder = _networkTextField._networkElementTextFields[1];
    [_networkTextField _selectPreviousTextField];
    [self assert:[_window firstResponder] equals:expectedFirstResponder];

    var expectedFirstResponder = _networkTextField._networkElementTextFields[0];
    [_networkTextField _selectPreviousTextField];
    [self assert:[_window firstResponder] equals:expectedFirstResponder];

    var expectedFirstResponder = _networkTextField._networkElementTextFields[0];
    [_networkTextField _selectPreviousTextField];
    [self assert:[_window firstResponder] equals:expectedFirstResponder];

    [_window makeFirstResponder:nil];
    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}

- (void)testSelectAll
{
    [_networkTextField setMode:NUNetworkIPV4Mode];
    [_networkTextField setStringValue:@"192.168.1.1/32"];
    [_networkTextField selectAll];
}

- (void)testSetStringValueWithMask_IPV4
{
    [_networkTextField setMode:NUNetworkIPV4Mode];

    [_networkTextField setStringValue:@"192.168.1.1"];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"192.168.1.1/67"];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"192.568.1.1/32"];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"192.1.1/32"];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"192..1.1/32"];
    [self assert:@"192..1.1/32" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"..1.1/32"];
    [self assert:@"..1.1/32" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@".../"];
    [self assert:@".../" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"..."];
    [self assert:@".../" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"192.168.1.1/32"];
    [self assert:@"192.168.1.1/32" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@""];
    [self assert:@"" equals:[_networkTextField stringValue]];
}

- (void)testSetStringValueWithMask_IPV6
{
    [_networkTextField setMode:NUNetworkIPV6Mode];

    [_networkTextField setStringValue:@"2001:0db8:0000:85a3:0000:0000:ac1f:8001/120"];
    [self assert:@"2001:0db8:0000:85a3:0000:0000:ac1f:8001/120" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:nil];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"2001:db8:0000:85a3:0000:0000:ac1f:8001/120"];
    [self assert:@"2001:db8:0000:85a3:0000:0000:ac1f:8001/120" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"2001:0:0000:85a3:0000:0000:ac1f:8001/120"];
    [self assert:@"2001:0:0000:85a3:0000:0000:ac1f:8001/120" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@""];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"2001:ffff:0000:85a3:9999:0000:ac1f:8001/120"];
    [self assert:@"2001:ffff:0000:85a3:9999:0000:ac1f:8001/120" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@""];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"2001:ffff:0000:85a3:9999:0000:ac1f:8001/129"];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"2001:ffff:0000:85a3:9999:0000:ac1f:8001"];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"2001::0000:85a3:0000:0000:ac1f:8001/120"];
    [self assert:@"2001::0000:85a3:0000:0000:ac1f:8001/120" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@""];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"2001:0:0000:85a3:1:0000:0000:ac1f:8001/120"];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"2001:::85a3::0000:ac1f:8001/120"];
    [self assert:@"2001:::85a3::0000:ac1f:8001/120" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@":::::::/"];
    [self assert:@":::::::/" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@""];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"::::::::/"];
    [self assert:@"" equals:[_networkTextField stringValue]];
}

- (void)testSetStringValueWithNoMask_IPV6
{
    [_networkTextField setMode:NUNetworkIPV6Mode];
    [_networkTextField setMask:NO];

    [_networkTextField setStringValue:@"2001:0db8:0000:85a3:0000:0000:ac1f:8001"];
    [self assert:@"2001:0db8:0000:85a3:0000:0000:ac1f:8001" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:nil];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"2001:db8:0000:85a3:0000:0000:ac1f:8001"];
    [self assert:@"2001:db8:0000:85a3:0000:0000:ac1f:8001" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"2001:0:0000:85a3:0000:0000:ac1f:8001"];
    [self assert:@"2001:0:0000:85a3:0000:0000:ac1f:8001" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@""];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"2001:ffff:0000:85a3:9999:0000:ac1f:8001"];
    [self assert:@"2001:ffff:0000:85a3:9999:0000:ac1f:8001" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@""];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"2001::0000:85a3:0000:0000:ac1f:8001"];
    [self assert:@"2001::0000:85a3:0000:0000:ac1f:8001" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@""];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"2001:0:0000:85a3:1:0000:0000:ac1f:8001"];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"2001:::85a3::0000:ac1f:8001"];
    [self assert:@"2001:::85a3::0000:ac1f:8001" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@":::::::"];
    [self assert:@":::::::" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@""];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"::::::::"];
    [self assert:@"" equals:[_networkTextField stringValue]];
}

- (void)testSetStringValueWithNoMask_IPV4
{
    [_networkTextField setMode:NUNetworkIPV4Mode];
    [_networkTextField setMask:NO];

    [_networkTextField setStringValue:@"192.168.1.1/32"];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"192.168.1.1/67"];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"192.568.1.1/32"];
    [self assert:@"" equals:[_networkTextField stringValue]];;

    [_networkTextField setStringValue:@"192..1.1"];
    [self assert:@"192..1.1" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"..."];
    [self assert:@"..." equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@".../"];
    [self assert:@"..." equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"192.168.1.1"];
    [self assert:@"192.168.1.1" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@""];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"192.568.1.1"];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"192.1.1"];
    [self assert:@"" equals:[_networkTextField stringValue]];
}

- (void)testSetStringValueMACMode
{
    [_networkTextField setMode:NUNetworkMACMode];

    [_networkTextField setStringValue:@"aa:fr:ff:aa:11:22"];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"aa:ff:ff:aa:11:22"];
    [self assert:@"aa:ff:ff:aa:11:22" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@""];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"aa:fr:ff:aa:11:22:12"];
    [self assert:@"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"aa::ff:aa:11:22"];
    [self assert:@"aa::ff:aa:11:22" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@"2a:fr:ff:aa:11:22"];
    [self assert:@"aa::ff:aa:11:22" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:nil];
    [self assert:"" equals:[_networkTextField stringValue]];

    [_networkTextField setStringValue:@":::::"];
    [self assert:@":::::" equals:[_networkTextField stringValue]];
}

- (void)testMethod__digitsForIPValue_IPV4
{
    [_networkTextField setMask:NO];

    [_networkTextField setMode:NUNetworkIPV4Mode];
    [_networkTextField setStringValue:@"192.168.1.1"];

    var digits = [_networkTextField _digitsForIPValue:[_networkTextField stringValue]];
    [self assert:digits equals:["192", "168", "1", "1"]];

    [_networkTextField setStringValue:@"192..1.1"];
    var digits = [_networkTextField _digitsForIPValue:[_networkTextField stringValue]];
    [self assert:digits equals:["192", "", "1", "1"]];

    // TODO: change that in NUNetworkTextField
    [_networkTextField setMask:YES];
    [_networkTextField setStringValue:@"192.168.1.1/32"];
    var digits = [_networkTextField _digitsForIPValue:[_networkTextField stringValue]];
    [self assert:digits equals:["192", "168", "1", "1/32"]];
}

- (void)testMethod__isIPValue_IPV4
{
    [_networkTextField setMode:NUNetworkIPV4Mode];

    [self assert:[_networkTextField _isIPValue:"150"] equals:YES];
    [self assert:[_networkTextField _isIPValue:150] equals:YES];
    [self assert:[_networkTextField _isIPValue:nil] equals:YES];
    [self assert:[_networkTextField _isIPValue:""] equals:YES];
    [self assert:[_networkTextField _isIPValue:256] equals:NO];
    [self assert:[_networkTextField _isIPValue:255] equals:YES];
    [self assert:[_networkTextField _isIPValue:0] equals:YES];
    [self assert:[_networkTextField _isIPValue:-1] equals:NO];
}

- (void)testMethod__isMaskValue_IPV4
{
    [_networkTextField setMode:NUNetworkIPV4Mode];

    [self assert:[_networkTextField _isMaskValue:""] equals:YES];
    [self assert:[_networkTextField _isMaskValue:nil] equals:YES];
    [self assert:[_networkTextField _isMaskValue:"0"] equals:YES];
    [self assert:[_networkTextField _isMaskValue:32] equals:YES];
    [self assert:[_networkTextField _isMaskValue:-1] equals:NO];
    [self assert:[_networkTextField _isMaskValue:0] equals:YES];
}

- (void)testMethod__digitsForIPValue_IPV6
{
    [_networkTextField setMask:NO];
    [_networkTextField setMode:NUNetworkIPV6Mode];
    [_networkTextField setStringValue:@"2001:0db8:0000:85a3:0000:0000:ac1f:8001"];

    var digits = [_networkTextField _digitsForIPValue:[_networkTextField stringValue]];
    [self assert:digits equals:["2001", "0db8", "0000", "85a3", "0000", "0000","ac1f","8001"]];

    // TODO: change that in NUNetworkTextField
    [_networkTextField setMask:YES];
    [_networkTextField setStringValue:@"2001:0db8:0000:85a3:0000:0000:ac1f:8001/120"];
    var digits = [_networkTextField _digitsForIPValue:[_networkTextField stringValue]];
    [self assert:digits equals:["2001", "0db8", "0000", "85a3", "0000", "0000","ac1f","8001/120"]];
}

- (void)testMethod__isIPValue_IPV6
{
    [_networkTextField setMode:NUNetworkIPV6Mode];

    [self assert:[_networkTextField _isIPValue:"8000"] equals:YES];
    [self assert:[_networkTextField _isIPValue:0] equals:YES];
    [self assert:[_networkTextField _isIPValue:nil] equals:YES];
    [self assert:[_networkTextField _isIPValue:""] equals:YES];
    [self assert:[_networkTextField _isIPValue:"ffff"] equals:YES];
    [self assert:[_networkTextField _isIPValue:"f490"] equals:YES];
    [self assert:[_networkTextField _isIPValue:"ff"] equals:YES];
    [self assert:[_networkTextField _isIPValue:"frff"] equals:NO];
    [self assert:[_networkTextField _isIPValue:"1"] equals:YES];
    [self assert:[_networkTextField _isIPValue:9999] equals:YES];
    [self assert:[_networkTextField _isIPValue:-1] equals:NO];
}

- (void)testMethod__isMaskValue_IPV6
{
    [_networkTextField setMode:NUNetworkIPV6Mode];

    [self assert:[_networkTextField _isMaskValue:""] equals:YES];
    [self assert:[_networkTextField _isMaskValue:nil] equals:YES];
    [self assert:[_networkTextField _isMaskValue:"0"] equals:YES];
    [self assert:[_networkTextField _isMaskValue:128] equals:YES];
    [self assert:[_networkTextField _isMaskValue:32] equals:YES];
    [self assert:[_networkTextField _isMaskValue:-1] equals:NO];
    [self assert:[_networkTextField _isMaskValue:0] equals:YES];
}

- (void)testMethod__digitsForMACValue
{
    [_networkTextField setMode:NUNetworkMACMode];
    [_networkTextField setStringValue:@"aa:fe:ff:aa:11:22"];

    var digits = [_networkTextField _digitsForMACValue:[_networkTextField stringValue]];
    [self assert:digits equals:["aa", "fe", "ff", "aa", "11", "22"]];

    [_networkTextField setStringValue:@"aa::ff:aa:11:22"];
    var digits = [_networkTextField _digitsForMACValue:[_networkTextField stringValue]];
    [self assert:digits equals:["aa", "", "ff", "aa", "11", "22"]];
}

- (void)testMethod__isMACValue
{
    [_networkTextField setMode:NUNetworkMACMode];

    [self assert:[_networkTextField _isMACValue:""] equals:YES];
    [self assert:[_networkTextField _isMACValue:nil] equals:YES];
    [self assert:[_networkTextField _isMACValue:"ff"] equals:YES];
    [self assert:[_networkTextField _isMACValue:"aa"] equals:YES];
    [self assert:[_networkTextField _isMACValue:"fr"] equals:NO];
    [self assert:[_networkTextField _isMACValue:"rf"] equals:NO];
    [self assert:[_networkTextField _isMACValue:"00"] equals:YES];
    [self assert:[_networkTextField _isMACValue:"99"] equals:YES];
    [self assert:[_networkTextField _isMACValue:"999"] equals:NO];
    [self assert:[_networkTextField _isMACValue:"aaa"] equals:NO];
}

- (void)testNetworkTextFields
{
    [_networkTextField setMask:NO];
    [_networkTextField setMode:NUNetworkIPV4Mode];
    [self assert:[_networkTextField._networkElementTextFields count] equals:4];
    [self assert:[_networkTextField._separatorLabels count] equals:3];

    [_networkTextField setMask:YES];
    [self assert:[_networkTextField._networkElementTextFields count] equals:5];
    [self assert:[_networkTextField._separatorLabels count] equals:4];

    [_networkTextField setMask:NO];
    [_networkTextField setMode:NUNetworkIPV6Mode];
    [self assert:[_networkTextField._networkElementTextFields count] equals:8];
    [self assert:[_networkTextField._separatorLabels count] equals:7];

    [_networkTextField setMask:YES];
    [self assert:[_networkTextField._networkElementTextFields count] equals:9];
    [self assert:[_networkTextField._separatorLabels count] equals:8];

    [_networkTextField setMask:NO];
    [_networkTextField setMode:NUNetworkMACMode];
    [self assert:[_networkTextField._networkElementTextFields count] equals:6];
    [self assert:[_networkTextField._separatorLabels count] equals:5];
}

@end