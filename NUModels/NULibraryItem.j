/*
*   Filename:         NULibraryItem.j
*   Created:          Fri Jun 21 11:17:40 PDT 2013
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


@implementation NULibraryItem : CPObject
{
    CPDictionary    _instanceDefaultSettings   @accessors(property=instanceDefaultSettings);
    CPString        _description               @accessors(property=description);
    CPString        _name                      @accessors(property=name);
    CPString        _representedObjectClass    @accessors(property=representedObjectClass);

    CPImage        _icon;
}


#pragma mark -
#pragma mark Class Methods

+ (id)libraryObjectWithName:(CPString)aName description:(CPString)aDescription class:(Class)aClass settings:(CPDictionary)someSettings
{
    var lib = [NULibraryItem new];

    [lib setName:aName];
    [lib setDescription:aDescription];
    [lib setInstanceDefaultSettings:someSettings];
    [lib setRepresentedObjectClass:aClass];

    return lib;
}


#pragma mark -
#pragma mark Getters and Setters

- (CPImage)icon
{
    // we create an instance here because some objects have variable icons
    if (!_icon)
        _icon = [[self instantiateRepresentedObject] icon];

    return _icon;
}

- (id)instantiateRepresentedObject
{
    var instance  = [_representedObjectClass new];

    if (_instanceDefaultSettings)
    {
        for (var i = [[_instanceDefaultSettings allKeys] count] - 1; i >= 0; i--)
        {
            var keyPath = [_instanceDefaultSettings allKeys][i];
            [instance setValue:[_instanceDefaultSettings objectForKey:keyPath] forKeyPath:keyPath];
        }
    }

    if ([instance respondsToSelector:@selector(name)] && ![instance name])
        [instance setName:[self name]];

    return instance;
}


#pragma mark -
#pragma mark CPCoding

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        _description             = [aCoder decodeObjectForKey:@"_description"];
        _instanceDefaultSettings = [aCoder decodeObjectForKey:@"_instanceDefaultSettings"];
        _name                    = [aCoder decodeObjectForKey:@"_name"];
        _representedObjectClass  = [aCoder decodeObjectForKey:@"_representedObjectClass"];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:_description forKey:@"_description"];
    [aCoder encodeObject:_instanceDefaultSettings forKey:@"_instanceDefaultSettings"];
    [aCoder encodeObject:_name forKey:@"_name"];
    [aCoder encodeObject:_representedObjectClass forKey:@"_representedObjectClass"];
}

@end
