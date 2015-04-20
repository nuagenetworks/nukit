/*
*   Filename:         NUPermittedActionToStringTransformer.j
*   Created:          Mon Mar 10 12:54:45 PDT 2014
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

@global NUPermissionINSTANTIATE;
@global NUPermissionREAD;
@global NUPermissionUSE;
@global NUPermissionEXTEND;
@global NUPermissionWRITE;
@global NUPermissionALL;

@implementation NUPermittedActionToStringTransformer: CPValueTransformer

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
    switch (value)
    {
        case NUPermissionINSTANTIATE:
            return @"Instantiate";

        case NUPermissionREAD:
            return @"Read";

        case NUPermissionUSE:
            return @"Use";

        case NUPermissionEXTEND:
            return @"Extend";

        case NUPermissionWRITE:
            return @"Edition";

        case NUPermissionALL:
            return @"Full control";
    }

    [CPException raise:CPInvalidArgumentException reason:[self class] + @" unexpected value to transform :" + value];
}

@end


// registration
NUPermittedActionToStringTransformerName = @"NUPermittedActionToStringTransformerName";
[CPValueTransformer setValueTransformer:[NUPermittedActionToStringTransformer new] forName:NUPermittedActionToStringTransformerName];
