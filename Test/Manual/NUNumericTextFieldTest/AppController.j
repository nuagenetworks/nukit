/*
 * AppController.j
 * NUNumericTextFieldTest
 *
 * Created by You on October 30, 2015.
 * Copyright 2015, Your Company All rights reserved.
 */

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import <NUKit/NUKit.j>

@implementation AppController : CPObject
{
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView],
        numericTextField = [NUNumericTextField textFieldWithStringValue:"" placeholder:"" width:200],
        decimalNumericTextField = [NUNumericTextField textFieldWithStringValue:"" placeholder:"" width:200];

    [decimalNumericTextField setFrameOrigin:CGPointMake(0, 50)];

    [contentView addSubview:numericTextField];
    [numericTextField setCucappIdentifier:@"numericTextField"];

    [decimalNumericTextField setAllowDecimals:YES];
    [contentView addSubview:decimalNumericTextField];
    [decimalNumericTextField setCucappIdentifier:@"decimalNumericTextField"];

    [theWindow orderFront:self];

    // Uncomment the following line to turn on the standard menu bar.
    //[CPMenu setMenuBarVisible:YES];

    [numericTextField setObjectValue:@"petit test"];
    [decimalNumericTextField setObjectValue:@"petit test"];
}

@end
