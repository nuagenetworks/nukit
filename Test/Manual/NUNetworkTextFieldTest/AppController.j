/*
 * AppController.j
 * NUNetworkTextFieldTest
 *
 * Created by You on October 21, 2015.
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
        networkTextField = [[NUNetworkTextField alloc] initWithFrame:CGRectMake(100, 100, 200, 30)],
        networkTextField2 = [[NUNetworkTextField alloc] initWithFrame:CGRectMake(100, 150, 200, 30)];

    [networkTextField2 setMask:NO];

    [contentView addSubview:networkTextField];
    [contentView addSubview:networkTextField2];

    [networkTextField2 setNextKeyView:networkTextField];
    [networkTextField setNextKeyView:networkTextField2];

    [networkTextField setCucappIdentifier:@"first-networkTextField"];
    [networkTextField2 setCucappIdentifier:@"second-networkTextField"];

    [theWindow orderFront:self];

    // Uncomment the following line to turn on the standard menu bar.
    //[CPMenu setMenuBarVisible:YES];
}

@end
