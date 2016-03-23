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
