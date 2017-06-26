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
@import <AppKit/CPTextField.j>

@global floatValue
@global isFloatNumber
@global isIntegerNumber


/*! NUNumericTextField is a textfield that only allows to input number, int or float
*/
@implementation NUNumericTextField : CPTextField
{
    BOOL    _allowDecimals     @accessors(property=allowDecimals);
    BOOL    _allowNegative     @accessors(property=allowNegative);
}

/*! @ignore
*/
- (BOOL)_setStringValue:(CPString)aValue isNewValue:(BOOL)isNewValue errorDescription:(CPStringRef)anError
{
    var value = [aValue length] && [self objectValue] ? [self objectValue] : @"";

    if ([self _shouldNotAcceptValue:aValue])
    {
        [self _inputElement].value = value.toString();
        return [super _setStringValue:@"" + value isNewValue:NO errorDescription:anError];
    }

    return [super _setStringValue:@"" + aValue isNewValue:isNewValue errorDescription:anError];
}

/*! @ignore
*/
- (void)_setObjectValue:(id)aValue useFormatter:(BOOL)useFormatter
{
    if ([self _shouldNotAcceptValue:aValue])
        return;

    [super _setObjectValue:aValue useFormatter:useFormatter];
}

/*! @ignore
*/
- (BOOL)_shouldNotAcceptValue:(CPString)aValue
{
    if (!aValue)
        return NO;

    var value = aValue.toString();

    if (value.length == 0)
        return NO;

    if ([self allowDecimals])
        return [self allowNegative] ? !value.match(/^-?\d*\.?\d*$/) : !value.match(/^\d+\.?\d*$/);
    else
        return [self allowNegative] ? !value.match(/^-?\d*$/) :!value.match(/^\d*$/);
}

/*! Returns the object value of the object
    This will be a float
*/
- (id)objectValue
{
    if ([super objectValue] === nil || [super objectValue] == @"")
        return nil;

    return [self floatValue];
}

/*! @ignore
*/
- (CPString)stringValue
{
    return @"" + [super stringValue];
}

@end
