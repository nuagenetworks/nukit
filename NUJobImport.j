/*
*   Filename:         NUJobImport.j
*   Created:          Fri Sep 12 16:59:31 PDT 2014
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
@import <RESTCappuccino/NURESTJob.j>


@implementation NUJobImport : NURESTJob

#pragma mark -
#pragma mark Initialization

- (id)init
{
    if (self = [super init])
    {
        _command = @"IMPORT";
    }

    return self;
}

- (CPString)objectToJSON
{
    var JSONObject = [super objectToJSON];

    JSONObject.parameters = JSON.parse(_parameters);

    return JSONObject;
}

@end
