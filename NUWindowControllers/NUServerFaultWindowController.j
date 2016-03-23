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
@import <AppKit/CPWindowController.j>

@class NUKit


@implementation NUServerFaultWindowController : CPWindowController
{
    @outlet CPImageView imageViewLogo;
}


#pragma mark -
#pragma mark Initialization

- (id)init
{
    self = [super initWithWindowCibName:@"ServerFault"]

    return self;
}

- (void)windowDidLoad
{
    var contentView = [[self window] contentView];
    [[contentView subviewWithTag:@"logout"] setBGColor:@"red"];

    [imageViewLogo setImage:[[NUKit kit] applicationLogo]];

    [self window]._windowView._DOMElement.style.WebkitAnimationName     = "bounceInDown";
    [self window]._windowView._DOMElement.style.WebkitTransform         = "translateZ(0)";
    [self window]._windowView._DOMElement.style.WebkitAnimationDuration = "1s";
    [self window]._windowView._DOMElement.style.backgroundColor         = "rgba(255, 255, 255, 0.8)";
}


#pragma mark -
#pragma mark Utilities

- (@action)logOut:(id)aSender
{
    [[NUKit kit] performLogout];
}

- (@action)showWindow:(id)aSender
{
    [[self window] center];
    [super showWindow:aSender];
}


#pragma mark -
#pragma mark Overrides

// TODO: this is insane, I guess Cocoa has a way to specify the bundle instead of overrides these two methos

- (void)loadWindow
{
    if (_window)
        return;

    [[CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"] loadCibFile:[self windowCibPath] externalNameTable:@{ CPCibOwner: _cibOwner }];
}

- (CPString)windowCibPath
{
    if (_windowCibPath)
        return _windowCibPath;

    return [[CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"] pathForResource:_windowCibName + @".cib"];
}

@end
