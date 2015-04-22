/*
*   Filename:         NUModuleLoader.j
*   Created:          Mon Feb  4 16:51:51 PST 2013
*   Author:           Antoine Mercadal <antoine.mercadal@alcatel-lucent.com>
*   Description:      VSA
*   Project:          Cloud Network Automation - Nuage - Data Center Service Delivery - IPD
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
@import <Foundation/CPNotificationCenter.j>


var sharedNUModuleLoader;

NUModuleLoaderStartLoadingNotification     = @"NUModuleLoaderStartLoadingNotification";
NUModuleLoaderModuleLoadedNotification     = @"NUModuleLoaderModuleLoadedNotification";
NUModuleLoaderAllModulesLoadedNotification = @"NUModuleLoaderAllModulesLoadedNotification";



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
