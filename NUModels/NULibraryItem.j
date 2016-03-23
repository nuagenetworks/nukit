/*
* Copyright (c) 2016, Alcatel-Lucent Inc
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the copyright holder nor the names of its contributors
*       may be used to endorse or promote products derived from this software without
*       specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
