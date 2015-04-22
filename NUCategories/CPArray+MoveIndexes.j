/*
 * CPArray+MoveIndexes.j
 * reportcard-client
 *
 * Created by Christophe SERAFIN.
 * Copyright 2012.
 */

@import <Foundation/CPArray.j>

@implementation CPArray (MoveIndexes)

/*! TODO : Doc
*/
- (void)moveIndexes:(CPIndexSet)indexes toIndex:(int)insertIndex
{
    var aboveCount = 0,
        object,
        removeIndex,
        index = [indexes lastIndex];

    while (index != CPNotFound)
    {
        if (index >= insertIndex)
        {
            removeIndex = index + aboveCount;
            aboveCount ++;
        }
        else
        {
            removeIndex = index;
            insertIndex --;
        }

        object = [self objectAtIndex:removeIndex];
        [self removeObjectAtIndex:removeIndex];
        [self insertObject:object atIndex:insertIndex];

        index = [indexes indexLessThanIndex:index];
    }
}

@end
