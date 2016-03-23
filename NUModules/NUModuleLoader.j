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
@import <Foundation/CPNotificationCenter.j>


var sharedNUModuleLoader;

NUModuleLoaderStartLoadingNotification     = @"NUModuleLoaderStartLoadingNotification";
NUModuleLoaderModuleLoadedNotification     = @"NUModuleLoaderModuleLoadedNotification";
NUModuleLoaderAllModulesLoadedNotification = @"NUModuleLoaderAllModulesLoadedNotification";


/*! @ignore
    This is deprectated
*/
@implementation NUModuleLoader : CPObject
{
    int             _numberOfModulesLoaded  @accessors(property=numberOfModulesLoaded);
    int             _numberOfModulesToLoad  @accessors(property=numberOfModulesToLoad);

    CPDictionary    _modules;
    id              _modulesPList;
}


#pragma mark -
#pragma mark Class Methods

+ (NUModuleLoader)sharedModuleLoader
{
    if (!sharedNUModuleLoader)
        sharedNUModuleLoader = [[NUModuleLoader alloc] init];

    return sharedNUModuleLoader;
}


#pragma mark -
#pragma mark Initialization

- (id)init
{
    if (self = [super init])
    {
        _numberOfModulesLoaded = 0;
        _numberOfModulesLoaded = 0;
        _modules = @{};
    }

    return self;
}


#pragma mark -
#pragma mark Utilities

/*! Register a module into the module loader
    This is done by NUModule, and you should never call this yourself
*/
- (void)registerModule:(NUModule)aModule withIdentifier:(CPString)anIdentifier
{
    if ([_modules containsKey:anIdentifier])
        return;

    [_modules setObject:aModule forKey:anIdentifier];
}

- (void)moduleWithIdentifier:(CPString)anIdentifier
{
    return [_modules objectForKey:anIdentifier];
}

- (void)jumpToModuleWithIdentifier:(CPString)anIdentifier
{
    var targetModule = [self moduleWithIdentifier:anIdentifier],
        parentsChain = [CPArray array],
        currentModule = targetModule;

    while (currentModule = [currentModule parentModule])
        [parentsChain addObject:currentModule];

    for (var i = 0, c = [parentsChain count]; i < c; i++)
    {
        var module = parentsChain[i],
            tabItem = [module tabViewItem],
            tabView = [[module parentModule] tabViewContent];

        [tabView selectTabViewItem:tabItem];
    }
}


#pragma mark -
#pragma mark Module loading management

/*! Start loading all bundles
*/
- (void)load
{
    var request = [CPURLRequest requestWithURL:[CPURL URLWithString:@"Modules/modules.plist"]],
        connection = [CPURLConnection connectionWithRequest:request delegate:self];

    [connection cancel];
    [connection start];
}

/*! will load next CPBundle
*/
- (void)_loadNextBundle
{
    var module  = [_modulesPList objectForKey:@"Modules"][_numberOfModulesLoaded],
        path    = "Modules/" + [module objectForKey:@"folder"],
        bundle  = [CPBundle bundleWithPath:path];

    CPLog.debug("MODULE LOADING: Loading bundle %@", [CPBundle bundleWithPath:path]);

    [bundle loadWithDelegate:self];
}


#pragma mark -
#pragma mark Notifications Posts

- (void)_notifyModulesStartedLoading
{
    [[CPNotificationCenter defaultCenter] postNotificationName:NUModuleLoaderModuleLoadedNotification
                                                        object:self
                                                      userInfo:nil];
}

- (void)_notifyModuleDidLoad:(CPBundle)aBundle
{
    [[CPNotificationCenter defaultCenter] postNotificationName:NUModuleLoaderModuleLoadedNotification
                                                        object:self
                                                      userInfo:aBundle];

}

- (void)_notifyAllModulesLoaded
{
    [[CPNotificationCenter defaultCenter] postNotificationName:NUModuleLoaderAllModulesLoadedNotification
                                                        object:self
                                                      userInfo:nil];
}

#pragma mark -
#pragma mark Delegates

/*! delegate of CPBundle. Will initialize all the modules in plist
    @param aBundle CPBundle that sent the message
*/
- (void)bundleDidFinishLoading:(CPBundle)aBundle
{
    _numberOfModulesLoaded++;

    var bundleCibName = [aBundle objectForInfoDictionaryKey:@"CibName"],
        moduleInstance = [[[aBundle principalClass] alloc] initWithCibName:bundleCibName bundle:aBundle],
        moduleIdentifier = [aBundle objectForInfoDictionaryKey:@"CPBundleIdentifier"],
        parentModules = [aBundle objectForInfoDictionaryKey:@"NUParentModules"],
        labelName = [aBundle objectForInfoDictionaryKey:@"CPBundleName"];

    for (var i = 0, c = [parentModules count]; i < c; i++)
    {
        var parentIdentifier = parentModules[i],
            parentModule = [_modules objectForKey:parentIdentifier];

        [parentModule addSubModule:moduleInstance];
    }

    [self _notifyModuleDidLoad:aBundle];

    if (_numberOfModulesLoaded < _numberOfModulesToLoad)
        [self _loadNextBundle];
    else
        [self _notifyAllModulesLoaded];
}


/*! delegate of CPURLConnection triggered when modules.plist is loaded.
    @param connection CPURLConnection that sent the message
    @param data CPString containing the result of the url
*/
- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    var cpdata = [CPData dataWithRawString:data];

    _modulesPList = [cpdata plistObject];
    _numberOfModulesToLoad = [[_modulesPList objectForKey:@"Modules"] count];

    if (_numberOfModulesToLoad)
    {
        [self _notifyModulesStartedLoading];
        [self _loadNextBundle];
    }
    else
    {
        [self _notifyAllModulesLoaded];
    }
}

@end
