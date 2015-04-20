/*
*   Filename:         NUSkin.j
*   Created:          Fri Aug  9 16:34:54 PDT 2013
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
@import <AppKit/CPImage.j>
@import <AppKit/CPColor.j>

NUSkinColorBlindModeEnabled = NO;
if (typeof(window.location) != "undefined" && window.location.search && window.location.search.indexOf("colorblind") != -1)
    NUSkinColorBlindModeEnabled = YES;

NUSkinImageButtonPlus                 = CPImageInBundle(@"buttonbar-image-plus.png", CGSizeMake(16.0, 16.0));
NUSkinImageButtonPlusAlt              = CPImageInBundle(@"buttonbar-image-plus-alt.png", CGSizeMake(16.0, 16.0));
NUSkinImageButtonLink                 = CPImageInBundle(@"button-link.png", CGSizeMake(16.0, 16.0));
NUSkinImageButtonLinkAlt              = CPImageInBundle(@"button-link-pressed.png", CGSizeMake(16.0, 16.0));
NUSkinImageButtonUnlink               = CPImageInBundle(@"button-unlink.png", CGSizeMake(16.0, 16.0));
NUSkinImageButtonUnlinkAlt            = CPImageInBundle(@"button-unlink-pressed.png", CGSizeMake(16.0, 16.0));
NUSkinImageButtonMinus                = CPImageInBundle(@"buttonbar-image-minus.png", CGSizeMake(16.0, 16.0));
NUSkinImageButtonMinusAlt             = CPImageInBundle(@"buttonbar-image-minus-alt.png", CGSizeMake(16.0, 16.0));
NUSkinImageButtonEdit                 = CPImageInBundle(@"buttonbar-image-edit.png", CGSizeMake(16.0, 16.0));
NUSkinImageButtonEditAlt              = CPImageInBundle(@"buttonbar-image-edit-alt.png", CGSizeMake(16.0, 16.0));
NUSkinImageButtonInstantiate          = CPImageInBundle(@"buttonbar-image-instantiate.png", CGSizeMake(16.0, 16.0));
NUSkinImageButtonInstantiateAlt       = CPImageInBundle(@"buttonbar-image-instantiate-alt.png", CGSizeMake(16.0, 16.0));
NUSkinImageButtonHelp                 = CPImageInBundle(@"button-help.png", CGSizeMake(16.0, 16.0));
NUSkinImageButtonHelpPressed          = CPImageInBundle(@"button-help-pressed.png", CGSizeMake(16.0, 16.0));
NUSkinImageFullscreenEnter            = CPImageInBundle(@"fullscreen-enter.png", CGSizeMake(16.0, 16.0));
NUSkinImageFullscreenEnterExit        = CPImageInBundle(@"fullscreen-exit.png", CGSizeMake(16.0, 16.0));
NUSkinImageFullscreenEnterExitPressed = CPImageInBundle(@"fullscreen-exit-pressed.png", CGSizeMake(16.0, 16.0));
NUSkinImageFullscreenEnterPressed     = CPImageInBundle(@"fullscreen-enter-pressed.png", CGSizeMake(16.0, 16.0));

NUSkinColorBlack                      = [CPColor colorWithHexString:@"6B6B6B"];
NUSkinColorBlackDark                  = [CPColor colorWithHexString:@"5E5959"];
NUSkinColorBlackDarker                = [CPColor colorWithHexString:@"232022"];
NUSkinColorBlackLight                 = [CPColor colorWithHexString:@"777D7D"];
NUSkinColorBlackLighter               = [CPColor colorWithHexString:@"91AEAE"];
NUSkinColorBlue                       = [CPColor colorWithHexString:NUSkinColorBlindModeEnabled ? @"0072B2" : @"6B94EC"];
NUSkinColorBlueDark                   = [CPColor colorWithHexString:@"5A83DE"];
NUSkinColorBlueDarker                 = [CPColor colorWithHexString:@"333333"];
NUSkinColorBlueLight                  = [CPColor colorWithHexString:@"7DA3F7"];
NUSkinColorBlueLighter                = [CPColor colorWithHexString:@"B3D0FF"];
NUSkinColorBluePale                   = [CPColor colorWithHexString:@"C7D9F9"];
NUSkinColorGreenDark                  = [CPColor colorWithHexString:@"36AB65"];
NUSkinColorGreen                      = [CPColor colorWithHexString:NUSkinColorBlindModeEnabled ? @"009E73" : @"B3D645"];
NUSkinColorGreenLight                 = [CPColor colorWithHexString:@"E0FE83"];
NUSkinColorGreenLighter               = [CPColor colorWithHexString:@"FFFFCB"];
NUSkinColorGrey                       = [CPColor colorWithHexString:@"D9D9D9"];
NUSkinColorGreyDark                   = [CPColor colorWithHexString:@"CCC2C2"];
NUSkinColorGreyDarker                 = [CPColor colorWithHexString:@"333333"];
NUSkinColorGreyLight                  = [CPColor colorWithHexString:@"F2F2F2"];
NUSkinColorGreyLighter                = [CPColor colorWithHexString:@"FCFCFC"];
NUSkinColorOrange                     = [CPColor colorWithHexString:NUSkinColorBlindModeEnabled ? @"E69F00" : @"F9B13D"];
NUSkinColorOrangeLight                = [CPColor colorWithHexString:@"FEC26A"];
NUSkinColorOrangeLighter              = [CPColor colorWithHexString:@"FED291"];
NUSkinColorRed                        = [CPColor colorWithHexString:NUSkinColorBlindModeEnabled ? @"D55E00" : @"F76159"];
NUSkinColorWhite                      = [CPColor colorWithHexString:@"FFFFFF"];
NUSkinColorWindowBody                 = [CPColor colorWithHexString:@"F5F5F5"];
NUSkinColorYellow                     = [CPColor colorWithHexString:NUSkinColorBlindModeEnabled ? @"F0E442" : @"EEDA54"];
NUSkinColorMauve                      = [CPColor colorWithHexString:@"AA97F2"];
NUSkinColor1                          = [CPColor colorWithHexString:@"F77278"];
NUSkinColor2                          = [CPColor colorWithHexString:@"2D3F4E"];
