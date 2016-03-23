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

@import "NUModule.j"

/*! Very simple generic implementation of a ready to NUModule dedicated to
    show a read only list of objects.
    YOU MUST CREATE THIS MODULE PROGRAMMATICALLY using the + (id)new API
*/
@implementation NUModuleMultipleObjectsShower : NUModule
{
    CGSize  _defaultSize;
}


#pragma mark -
#pragma mark Initialization

/*! Create a new NUModuleMultipleObjectsShower
*/
+ (id)new
{
    var obj = [[self alloc] initWithCibName:@"ObjectsShower" bundle:[CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]];

    [obj view];

    return obj;
}

+ (CPString)moduleName
{
    return @"No Name";
}

/*! @ignore
*/
- (void)viewDidLoad
{
    [super viewDidLoad];

    _defaultSize = [[self view] frameSize];
}


#pragma mark -
#pragma mark Configuration

/*! Configures the module to show the children of the given class from the given parent, using the given fetcher keypath, and showing them in the given dataview
    with a given title in a given content size (optional, only used if you decide to show it in a popover.).
*/
- (void)configureWithParentObject:(id)aParent childrenClass:(Class)aChildrenClass fetcherKeyPath:(CPString)aFetcherKeyPath dataView:(CPView)aDataView title:(CPString)aTitle contentSize:(CGSize)aSize
{
    // load view is needed
    [self view];

    if (![_contextRegistry containsKey:aChildrenClass])
    {
        var context = [[NUModuleContext alloc] initWithName:aTitle identifier:[aChildrenClass RESTName]];
        [context setFetcherKeyPath:aFetcherKeyPath];
        [self registerContext:context forClass:aChildrenClass];
    }

    [[self dataViews] setObject:[aDataView duplicate] forKey:aChildrenClass];

    [self setModuleTitle:aTitle];

    [self setModulePopoverBaseSize:aSize || _defaultSize];
}

/*! @ignore
*/
- (CPSet)permittedActionsForObject:(id)anObject
{
    var permissions = [CPSet new];

    [permissions addObject:NUModuleActionInspect];

    return permissions;
}


#pragma mark -
#pragma mark Overrides

/*! @ignore
*/
- (CPView)tableView:(CPTableView)aTableView viewForTableColumn:(CPTableColumn)aColumn row:(int)aRow
{
    return [[self _dataViewForObject:[_dataSource objectAtIndex:aRow]] duplicate];
}

@end
