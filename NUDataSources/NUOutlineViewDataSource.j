/*
 * TNOutlineViewDataSource.j
 *
 * Copyright (C) 2010  Antoine Mercadal <antoine.mercadal@inframonde.eu>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

@import <Foundation/Foundation.j>
@import <AppKit/CPSearchField.j>
@import <AppKit/CPOutlineView.j>

@global CPDragOperationNone


@implementation NUOutlineViewDataSource : CPObject
{
    CPArray         _content                @accessors(property=content);
    CPArray         _searchableKeyPaths     @accessors(property=searchableKeyPaths);
    CPString        _childKeyPath           @accessors(property=childKeyPath);
    CPString        _parentKeyPath          @accessors(property=parentKeyPath);
    CPSearchField   _searchField            @accessors(property=searchField);
    CPOutlineView   _table                  @accessors(property=table);
    id              _dragAndDropDelegate    @accessors(property=dragAndDropDelegate);

    CPPredicate     _filter;
}


#pragma mark -
#pragma mark Initialization

- (id)init
{
    if (self = [super init])
    {
        _content = [CPArray array];
        _parentKeyPath = @"parent";
        _childKeyPath = @"children";
    }

    return self;
}


#pragma mark -
#pragma mark Data Information

- (int)count
{
    return [_content count];
}


#pragma mark -
#pragma mark Data manipulation

- (void)addObject:(id)anObject
{
    [_content addObject:anObject];
}

- (void)addObjectsFromArray:(CPArray)someObjects
{
    [_content addObjectsFromArray:someObjects];
}

- (void)removeAllObjects
{
    [_content removeAllObjects];
}

- (void)removeObject:(id)anObject
{
    [_content removeObject:anObject];
}

- (void)objectAtIndex:(int)anIndex
{
    return [self filteredContent:_content][anIndex];
}

- (void)objectsAtIndexes:(CPindexSet)someIndexes
{
    return [[self filteredContent:_content] objectsAtIndexes:someIndexes];
}

- (void)sortUsingDescriptors:(CPArray)someDescriptors
{
    [_content sortUsingDescriptors:someDescriptors];
}

- (CPArray)filteredArrayUsingPredicate:(CPPredicate)aPredicate
{
    return [_content filteredArrayUsingPredicate:aPredicate];
}

- (BOOL)containsObject:(id)anObject
{
    return [_content containsObject:anObject];
}

- (CPArray)objectMatchingPredicate:(CPPredicate)aPredicate
{
    var ret = [self _getChildrenOfObject:nil usingPredicate:aPredicate];
    return [ret count] == 1 ? ret[0] : nil;
}

- (CPArray)flattenedContent
{
    return [self _getChildrenOfObject:nil usingPredicate:nil];
}


#pragma mark -
#pragma mark Filtering

- (void)setFilterPredicate:(CPPredicate)aPredicate
{
    if (aPredicate == _filter)
        return;

    _filter = aPredicate;
    [_table reloadData];
}

- (void)setFilterString:(CPString)aString
{
    if (aString == [_filter predicateFormat])
        return;

    if (aString && [aString length])
    {
        _filter = [CPPredicate predicateWithFormat:aString];

        // if predicate creation failed, build a predicate according to searchable ketpaths
        if (!_filter)
        {
            var tempPredicateString = @"";

            for (var i = [_searchableKeyPaths count] - 1; i >= 0; i--)
            {
                var keyPath = _searchableKeyPaths[i];

                tempPredicateString += keyPath + " contains[c] '" + aString + "' ";
                if (i + 1 < [_searchableKeyPaths count])
                    tempPredicateString += " OR ";
            }

            if ([tempPredicateString length])
                _filter = [CPPredicate predicateWithFormat:tempPredicateString];
        }
    }
    else
        _filter = nil;

    [_table reloadData];
}

- (IBAction)filterObjects:(id)sender
{
    if (!_searchField)
        _searchField = sender;

    [self setFilterString:[_searchField stringValue]];
}

- (void)filteredContent:(CPArray)anArray
{
    if (!_filter)
        return anArray;

    return [self _getChildrenOfObject:nil usingPredicate:_filter];
}

- (void)_getChildrenOfObject:(id)anObject usingPredicate:(CPPredicate)aPredicate
{
    var objects = anObject ? [anObject valueForKeyPath:_childKeyPath] : _content,
        matchingObjects = aPredicate ? [objects filteredArrayUsingPredicate:aPredicate] : [objects copy],
        ret = [CPArray array];

    if ([matchingObjects count])
        [ret addObjectsFromArray:matchingObjects];


    for (var i = [objects count] - 1; i >= 0; i--)
    {
        var obj = objects[i],
            retArray = [self _getChildrenOfObject:obj usingPredicate:aPredicate];

        if ([retArray count])
            [ret addObjectsFromArray:retArray];
    }

    return ret;
}


#pragma mark -
#pragma mark Datasource implementation

- (int)outlineView:(CPOutlineView)anOutlineView numberOfChildrenOfItem:(id)item
{
    if (!item)
        return [[self filteredContent:_content] count];
    else
    {
        if (_filter)
            return 0;

        if ([item valueForKeyPath:_childKeyPath])
            return [[item valueForKeyPath:_childKeyPath] count];
        return 0;
    }
}

- (BOOL)outlineView:(CPOutlineView)anOutlineView isItemExpandable:(id)item
{
    if (!item)
        return YES;

    if (![item valueForKeyPath:_childKeyPath])
        return NO;

    if (_filter)
        return NO;

    return ([[item valueForKeyPath:_childKeyPath] count] > 0) ? YES : NO;
}

- (id)outlineView:(CPOutlineView)anOutlineView child:(int)index ofItem:(id)item
{
    if (!item)
        return [self filteredContent:_content][index];
    else
    {
        if ([item valueForKeyPath:_childKeyPath])
            return [item valueForKeyPath:_childKeyPath][index];
        return nil;
    }

}

- (id)outlineView:(CPOutlineView)anOutlineView objectValueForTableColumn:(CPTableColumn)tableColumn byItem:(id)item
{
    var identifier = [tableColumn identifier];

    if (identifier == @"outline")
        return nil;

    return [item valueForKeyPath:identifier];
}


#pragma mark -
#pragma mark Drag and Drop

- (BOOL)outlineView:(CPOutlineView)outlineView writeItems:(CPArray)items toPasteboard:(CPPasteboard)thePasteBoard
{
    if (_dragAndDropDelegate && [_dragAndDropDelegate respondsToSelector:@selector(dataSource:writeItems:toPasteboard:)])
        return [_dragAndDropDelegate dataSource:self writeItems:items toPasteboard:thePasteBoard];

    return NO;
}

- (CPDragOperation)outlineView:(CPOutlineView)outlineView validateDrop:(CPDraggingInfo)info proposedItem:(id)item proposedChildIndex:(CPInteger)index
{
    if (_dragAndDropDelegate && [_dragAndDropDelegate respondsToSelector:@selector(dataSource:validateDrop:proposedItem:proposedChildIndex:)])
        return [_dragAndDropDelegate dataSource:self validateDrop:info proposedItem:item proposedChildIndex:index];

    return CPDragOperationNone;
}

- (BOOL)outlineView:(CPOutlineView)outlineView acceptDrop:(CPDraggingInfo)info item:(id)item childIndex:(CPInteger)index
{
    if (_dragAndDropDelegate && [_dragAndDropDelegate respondsToSelector:@selector(dataSource:acceptDrop:item:childIndex:)])
        return [_dragAndDropDelegate dataSource:self acceptDrop:info item:item childIndex:index];

    return NO;
}

@end
