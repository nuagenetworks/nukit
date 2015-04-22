/*
****************************************************************************
*
*   Filename:         CPPopover+TNAttachedWindowAPI.j
*
*   Created:          Mon Apr  2 11:23:45 PST 2012
*
*   Description:      Cappuccino UI
*
*   Project:          Cloud Network Automation - Nuage - Data Center Service Delivery - IPD
*
*
***************************************************************************
*
*                 Source Control System Information
*
*   $Id: something $
*
*
*
****************************************************************************
*
* Copyright (c) 2011-2012 Alcatel, Alcatel-Lucent, Inc. All Rights Reserved.
*
* This source code contains confidential information which is proprietary to Alcatel.
* No part of its contents may be used, copied, disclosed or conveyed to any party
* in any manner whatsoever without prior written permission from Alcatel.
*
* Alcatel-Lucent is a trademark of Alcatel-Lucent, Inc.
*
*
*****************************************************************************
*/

@import <AppKit/CPPopover.j>

@implementation CPPopover (TNAttachedWindowAPI)

- (void)setDefaultButton:(CPButton)aButton
{
    [_popoverWindow setDefaultButton:aButton];
}

- (CPButton)defaultButton
{
    return [_popoverWindow defaultButton];
}

- (void)makeFirstResponder:(id)aResponder
{
    [_popoverWindow makeFirstResponder:aResponder];
}

- (void)setInitialFirstResponder:(id)aResponder
{
    [_popoverWindow setInitialFirstResponder:aResponder];
}

@end
