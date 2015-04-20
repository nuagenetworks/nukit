/*
*   Filename:         NUModuleTitleTransformers.j
*   Created:          Wed Aug 13 12:52:53 PDT 2014
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


@implementation NUApplicationsModuleSubtitleValueTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return CPString;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return @"Application Designer - " + value;
}

@end

// registration
NUApplicationsModuleSubtitleValueTransformerName = @"NUApplicationsModuleSubtitleValueTransformerName";
[CPValueTransformer setValueTransformer:[NUApplicationsModuleSubtitleValueTransformer new] forName:NUApplicationsModuleSubtitleValueTransformerName];


@implementation NUDomainsModuleSubtitleValueTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return CPString;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return @"Domain Designer - " + value;
}

@end

// registration
NUDomainsModuleSubtitleValueTransformerName = @"NUDomainsModuleSubtitleValueTransformerName";
[CPValueTransformer setValueTransformer:[NUDomainsModuleSubtitleValueTransformer new] forName:NUDomainsModuleSubtitleValueTransformerName];


@implementation NUGatewaysModuleSubtitleValueTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return CPString;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return @"Gateway Designer - " + value;
}

@end

// registration
NUGatewaysModuleSubtitleValueTransformerName = @"NUGatewaysModuleSubtitleValueTransformerName";
[CPValueTransformer setValueTransformer:[NUGatewaysModuleSubtitleValueTransformer new] forName:NUGatewaysModuleSubtitleValueTransformerName];


@implementation NUNSGsModuleSubtitleValueTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return CPString;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return @"Network Services Gateway Configuration - " + value;
}

@end

// registration
NUNSGsModuleSubtitleValueTransformerName = @"NUNSGsModuleSubtitleValueTransformerName";
[CPValueTransformer setValueTransformer:[NUNSGsModuleSubtitleValueTransformer new] forName:NUNSGsModuleSubtitleValueTransformerName];


@implementation NUGroupsModuleSubtitleValueTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return CPString;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return @"Group Editor - " + value;
}

@end

// registration
NUGroupsModuleSubtitleValueTransformerName = @"NUGroupsModuleSubtitleValueTransformerName";
[CPValueTransformer setValueTransformer:[NUGroupsModuleSubtitleValueTransformer new] forName:NUGroupsModuleSubtitleValueTransformerName];


@implementation NUL2DomainsModuleSubtitleValueTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return CPString;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return @"L2 Domain Designer - " + value;
}

@end

// registration
NUL2DomainsModuleSubtitleValueTransformerName = @"NUL2DomainsModuleSubtitleValueTransformerName";
[CPValueTransformer setValueTransformer:[NUL2DomainsModuleSubtitleValueTransformer new] forName:NUL2DomainsModuleSubtitleValueTransformerName];


@implementation NUPolicyGroupsModuleSubtitleValueTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return CPString;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return @"Policy Group Editor - " + value;
}

@end

// registration
NUPolicyGroupsModuleSubtitleValueTransformerName = @"NUPolicyGroupsModuleSubtitleValueTransformerName";
[CPValueTransformer setValueTransformer:[NUPolicyGroupsModuleSubtitleValueTransformer new] forName:NUPolicyGroupsModuleSubtitleValueTransformerName];


@implementation NUStatisticsModuleSubtitleValueTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return CPString;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return @"Statistics - " + value;
}

@end

// registration
NUStatisticsModuleSubtitleValueTransformerName = @"NUStatisticsModuleSubtitleValueTransformerName";
[CPValueTransformer setValueTransformer:[NUStatisticsModuleSubtitleValueTransformer new] forName:NUStatisticsModuleSubtitleValueTransformerName];


@implementation NUVirtualMachinesModuleSubtitleValueTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return CPString;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return @"Virtual Machines - " + value;
}

@end

// registration
NUVirtualMachinesModuleSubtitleValueTransformerName = @"NUVirtualMachinesModuleSubtitleValueTransformerName";
[CPValueTransformer setValueTransformer:[NUVirtualMachinesModuleSubtitleValueTransformer new] forName:NUVirtualMachinesModuleSubtitleValueTransformerName];
