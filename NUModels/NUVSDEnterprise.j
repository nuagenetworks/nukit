/*
*   Filename:         NUVSDEnterprise.j
*   Created:          Mon Apr 20 18:08:55 PDT 2015
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
@import <AppKit/CPArrayController.j>
@import <AppKit/CPImage.j>

@import "NUMetadataTagsFetcher.j"

var NUEnterpriseController,
    NUEnterpriseCurrent;


@implementation NUVSDEnterprise : NUVSDObject
{
    CPString                                _description                            @accessors(property=description);
    CPString                                _name                                   @accessors(property=name);

    NUMetadataTagsFetcher                   _metadataTags                           @accessors(property=metadataTags);
}


#pragma mark -
#pragma mark Class Method

+ (id)currentEnterprise
{
    return NUEnterpriseCurrent;
}

+ (void)setCurrentEnterprise:(id)anEnterprise
{
    NUEnterpriseCurrent = anEnterprise;
}


#pragma mark -
#pragma mark Initialization

- (id)init
{
    if (self = [super init])
    {
        [self exposeLocalKeyPathToREST:@"description"];
        [self exposeLocalKeyPathToREST:@"name"];

        _metadataTags = [NUMetadataTagsFetcher fetcherWithParentObject:self];
   }

    return self;
}

@end
