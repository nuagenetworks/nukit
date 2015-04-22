/*
 * CPDate+Format.j
 *
 * Copyright (C) 2010 Antoine Mercadal <antoine.mercadal@inframonde.eu>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

@import <Foundation/CPDate.j>

@import "Resources/dateFormat.js"


@implementation CPDate (TNKit)

+ (CPString)dateWithFormat:(CPString)aFormat
{
    var theDate = new Date();
    return theDate.format(aFormat);
}

- (CPString)format:(CPString)aFormat
{
    return self.format(aFormat);
}

+ (CPString)stringDateForTime:(int)aTime
{
    var seconds = aTime / 1000,
        numDays = Math.floor((seconds % 31536000) / 86400),
        numHours = Math.floor(((seconds % 31536000) % 86400) / 3600),
        numMinutes = Math.floor((((seconds % 31536000) % 86400) % 3600) / 60),
        string = @"";

    if (numDays)
        string += numDays + (numDays > 1 ? @" days " : @" day ");

    if (numHours)
        string += numHours + (numHours > 1 ? @" hours " : @" hour ");

    if (numMinutes)
        string += numMinutes + " min";

    if (![string length])
        string = @"0 min";

    return string;
}

@end
