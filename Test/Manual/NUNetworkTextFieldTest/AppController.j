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
        networkTextField = [[NUNetworkTextField alloc] initWithFrame:CGRectMake(100, 100, 400, 30)],
        networkTextField2 = [[NUNetworkTextField alloc] initWithFrame:CGRectMake(100, 150, 400, 30)],
        networkTextField3 = [[NUNetworkTextField alloc] initWithFrame:CGRectMake(100, 200, 400, 30)],
        networkTextField4 = [[NUNetworkTextField alloc] initWithFrame:CGRectMake(100, 250, 400, 30)];

    [networkTextField2 setMask:NO];
    [networkTextField3 setMode:NUNetworkMACMode];

    [networkTextField4 setMode:NUNetworkIPV6Mode]

    [contentView addSubview:networkTextField];
    [contentView addSubview:networkTextField2];
    [contentView addSubview:networkTextField3];
    [contentView addSubview:networkTextField4];

    [networkTextField2 setNextKeyView:networkTextField3];
    [networkTextField setNextKeyView:networkTextField2];
    [networkTextField3 setNextKeyView:networkTextField4];

    [networkTextField setCucappIdentifier:@"first-networkTextField"];
    [networkTextField2 setCucappIdentifier:@"second-networkTextField"];
    [networkTextField3 setCucappIdentifier:@"third-networkTextField"];
    [networkTextField4 setCucappIdentifier:@"fourth-networkTextField"];

    [theWindow orderFront:self];

    // Uncomment the following line to turn on the standard menu bar.
    //[CPMenu setMenuBarVisible:YES];
}

@end
