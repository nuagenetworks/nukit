/*
*   Filename:         NUMetadataTag.j
*   Created:          Tue Feb 10 11:54:05 PST 2015
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
@import <NUKit/NUVSDObject.j>


@implementation NUMetadataTag : NUVSDObject
{
    CPString    _description    @accessors(property=description);
    CPString    _name           @accessors(property=name);
}


#pragma mark -
#pragma mark Initialization

+ (CPString)RESTName
{
    return @"metadatatag";
}

- (id)init
{
    if (self = [super init])
    {
        [self exposeLocalKeyPathToREST:@"description"];
        [self exposeLocalKeyPathToREST:@"name"];
    }

    return self;
}

@end
