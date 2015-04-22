/*
*   Filename:         NUGenealogyDataView.j
*   Created:          Tue Oct 21 16:34:40 PDT 2014
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

@import "NUAbstractDataView.j"
@import "NUNullDescriptionTransformer.j"


@implementation NUGenealogyDataView : NUAbstractDataView
{
    @outlet CPView          viewContainer;
    @outlet CPImageView     imageViewIcon;
    @outlet CPTextField     fieldName;
    @outlet CPTextField     fieldDescription;
}


#pragma mark -
#pragma mark Data View Protocol

- (void)bindDataView
{
    [super bindDataView];

    var nullDescriptionOptions = @{CPValueTransformerNameBindingOption: NUNullDescriptionTransformerName};

    [fieldName bind:CPValueBinding toObject:_objectValue withKeyPath:@"displayName" options:nil];
    [fieldDescription bind:CPValueBinding toObject:_objectValue withKeyPath:@"displayDescription" options:nullDescriptionOptions];
    [imageViewIcon bind:CPValueBinding toObject:_objectValue withKeyPath:@"displayIcon" options:nil];
}


#pragma mark -
#pragma mark CPCoding compliance

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        fieldDescription = [aCoder decodeObjectForKey:@"fieldDescription"];
        fieldName        = [aCoder decodeObjectForKey:@"fieldName"];
        imageViewIcon    = [aCoder decodeObjectForKey:@"imageViewIcon"];
        viewContainer    = [aCoder decodeObjectForKey:@"viewContainer"];

        [viewContainer setBorderColor:NUSkinColorGrey];
        [viewContainer setBorderRadius:3.0];
        [viewContainer setBackgroundColor:NUSkinColorGreyLight];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:fieldDescription forKey:@"fieldDescription"];
    [aCoder encodeObject:fieldName forKey:@"fieldName"];
    [aCoder encodeObject:imageViewIcon forKey:@"imageViewIcon"];
    [aCoder encodeObject:viewContainer forKey:@"viewContainer"];
}

@end
