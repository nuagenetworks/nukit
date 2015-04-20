/*
*   Filename:         NUCheckboxStateToBooleanValueTransformer.j
*   Created:          Wed Jan 16 16:20:04 PST 2013
*   Author:           Antoine Mercadal <antoine.mercadal@alcatel-lucent.com>
*   Description:      VSA
*   Project:          Cloud Network Automation - Nuage - Data Center Service Delivery - IPD
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

@global CPOnState
@global CPOffState

/*! Value transformers for CPCheckBox to send YES or NO, instead of 1 or 0
*/
@implementation NUCheckboxStateToBooleanValueTransformer: CPValueTransformer

+ (Class)transformedValueClass
{
    return Boolean;
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)aValue
{
    return aValue ? CPOnState : CPOffState;
}

- (id)reverseTransformedValue:(id)aValue
{
    return aValue ? YES : NO;
}

@end


// registration
NUCheckboxStateToBooleanValueTransformerName = @"NUCheckboxStateToBooleanValueTransformerName";
[CPValueTransformer setValueTransformer:[NUCheckboxStateToBooleanValueTransformer new] forName:NUCheckboxStateToBooleanValueTransformerName];
