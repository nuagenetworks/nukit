/*
****************************************************************************
*
*   Filename:         CPObject+Duplication.j
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

@import <Foundation/CPObject.j>
@import <Foundation/CPKeyedArchiver.j>
@import <Foundation/CPKeyedUnarchiver.j>

 /*! @ingroup categories
     Categories that allows CPObject to perform a deep copy of itself
 */
@implementation CPObject (duplicate)

/*! create and return a deep copy of the object
    @return copied object
*/
- (id)duplicate
{
    var copy = [CPKeyedArchiver archivedDataWithRootObject:self];
    return [CPKeyedUnarchiver unarchiveObjectWithData:copy];
}

- (CPComparisonResult)caseInsensitiveCompare:(id)anObject
{
    return [self compare:anObject];
}

@end

