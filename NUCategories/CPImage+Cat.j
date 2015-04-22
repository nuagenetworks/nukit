/*
*   Filename:         CPImage+Cat.j
*   Created:          Thu Feb 12 16:59:57 PST 2015
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

@import <AppKit/CPImage.j>

@global NUKitParameterCat


@implementation CPImage (Cat)

- (CPString)filename
{
    if (NUKitParameterCat)
        return "http://thecatapi.com/api/images/get?format=src&type=jpg&size=small&" + [CPString UUID];
    else
        return _filename;
}

@end
