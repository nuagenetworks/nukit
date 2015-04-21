/*
*   Filename:         NUVSDRESTUser.j
*   Created:          Mon Apr 20 17:29:12 PDT 2015
*   Author:           Antoine Mercadal <antoine.mercadal@alcatel-lucent.com>
*   Description:      VSA
*   Project:          VSD - Nuage - Data Center Service Delivery - IPD
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
@import <AppKit/CPImage.j>
@import <RESTCappuccino/NURESTBasicUser.j>

@global NUUserAvatarDefault
@global NUUserAvatarTypeBase64
@global NUUserAvatarTypeURL
@global NUUserAvatarTypeComputedURL

NURESTUserRoleCMS           = @"CMS";
NURESTUserRoleCSPRoot       = @"CSPROOT";
NURESTUserRoleCSPOperator   = @"CSPOPERATOR";
NURESTUserRoleOrgAdmin      = @"ORGADMIN";
NURESTUserRoleOrgDesigner   = @"ORGNETWORKDESIGNER";
NURESTUserRoleOrgUser       = @"ORGUSER";


@implementation NUVSDRESTUser : NURESTBasicUser
{
    CPString    _avatarData         @accessors(property=avatarData);
    CPString    _avatarType         @accessors(property=avatarType);
    CPString    _email              @accessors(property=email);
    CPString    _enterpriseID       @accessors(property=enterpriseID);
    CPString    _enterpriseName     @accessors(property=enterpriseName);
    CPString    _firstName          @accessors(property=firstName);
    CPString    _lastName           @accessors(property=lastName);
    CPString    _mobileNumber       @accessors(property=mobileNumber);
    CPString    _role               @accessors(property=role);
}


#pragma mark -
#pragma mark Class Method

+ (CPString)RESTName
{
    return "me";
}

+ (BOOL)RESTResourceNameFixed
{
    return YES;
}

- (CPURL)RESTResourceURL
{
    return [CPURL URLWithString:[self RESTName] + @"/" relativeToURL:[[self class] RESTBaseURL]];
}

- (CPURL)RESTResourceURLForChildrenClass:(Class)aChildrenClass
{
    return [CPURL URLWithString:[aChildrenClass RESTResourceName] + @"/" relativeToURL:[[self class] RESTBaseURL]];
}


#pragma mark -
#pragma mark Initialization

- (id)init
{
    if (self = [super init])
    {
        [self exposeLocalKeyPathToREST:@"avatarData" searchable:NO];
        [self exposeLocalKeyPathToREST:@"avatarType" searchable:NO];
        [self exposeLocalKeyPathToREST:@"email"];
        [self exposeLocalKeyPathToREST:@"enterpriseID" searchable:NO];
        [self exposeLocalKeyPathToREST:@"enterpriseName"];
        [self exposeLocalKeyPathToREST:@"firstName"];
        [self exposeLocalKeyPathToREST:@"lastName"];
        [self exposeLocalKeyPathToREST:@"mobileNumber"];
        [self exposeLocalKeyPathToREST:@"role"];
    }

    return self;
}


#pragma mark -
#pragma mark Custom getters and setters

- (void)setAvatarData:(CPString)someRawData
{
    if (_avatarData == someRawData)
        return;

    [self willChangeValueForKey:@"avatarData"];
    [self willChangeValueForKey:@"avatarImage"];
    _avatarData = someRawData;
    [self didChangeValueForKey:@"avatarData"];
    [self didChangeValueForKey:@"avatarImage"];
}

- (void)setAvatarType:(CPString)aType
{
    if (_avatarType == aType)
        return;

    [self willChangeValueForKey:@"avatarType"];
    [self willChangeValueForKey:@"avatarImage"];
    _avatarType = aType;
    [self didChangeValueForKey:@"avatarType"];
    [self didChangeValueForKey:@"avatarImage"];
}

- (CPImage)avatarImage
{
    if (!_avatarData)
        return NUUserAvatarDefault;

    switch (_avatarType)
    {
        case NUUserAvatarTypeBase64:
            return [[CPImage alloc] initWithData:[CPData dataWithBase64:_avatarData]];

        case NUUserAvatarTypeURL:
        case NUUserAvatarTypeComputedURL:
            return [[CPImage alloc] initWithContentsOfFile:_avatarData + "?cachehack=" + new Date().getTime()];
    }
}

- (void)setFirstName:(CPString)aFirstName
{
    if (_firstName === aFirstName)
        return;

    [self willChangeValueForKey:@"firstName"];
    [self willChangeValueForKey:@"information"];
    _firstName = aFirstName;
    [self didChangeValueForKey:@"firstName"];
    [self didChangeValueForKey:@"information"];
}

- (void)setLastName:(CPString)aLastName
{
    if (_lastName === aLastName)
        return;

    [self willChangeValueForKey:@"lastName"];
    [self willChangeValueForKey:@"information"];
    _lastName = aLastName;
    [self didChangeValueForKey:@"lastName"];
    [self didChangeValueForKey:@"information"];
}

- (void)setUserName:(CPString)aUserName
{
    if (_userName === aUserName)
        return;

    [self willChangeValueForKey:@"userName"];
    [self willChangeValueForKey:@"information"];
    _userName = aUserName;
    [self didChangeValueForKey:@"userName"];
    [self didChangeValueForKey:@"information"];
}

- (void)setRole:(CPString)aRole
{
    if (_role === aRole)
        return;

    [self willChangeValueForKey:@"role"];
    [self willChangeValueForKey:@"roleName"];
    [self willChangeValueForKey:@"information"];
    _role = aRole;
    [self didChangeValueForKey:@"role"];
    [self didChangeValueForKey:@"roleName"];
    [self didChangeValueForKey:@"information"];
}

- (void)roleName
{
    switch (_role)
    {
        case NURESTUserRoleCSPRoot:
            return @"data center administrator";
        case NURESTUserRoleCSPOperator:
            return @"data center operator";
        case NURESTUserRoleOrgAdmin:
            return @"administrator of";
        case NURESTUserRoleOrgDesigner:
            return @"network designer of";
        case NURESTUserRoleOrgUser:
            return @"standard user of";
    }
}

- (void)setEnterpriseName:(CPString)aName
{
    if (_enterpriseName === aName)
        return;

    [self willChangeValueForKey:@"enterpriseName"];
    [self willChangeValueForKey:@"information"];
    _enterpriseName = aName;
    [self didChangeValueForKey:@"enterpriseName"];
    [self didChangeValueForKey:@"information"];
}

- (CPString)information
{
    switch (_role)
    {
        case NURESTUserRoleCSPRoot:
        case NURESTUserRoleCSPOperator:
            return [CPString stringWithFormat:@"%s %s (%s) - %s", [_firstName lowercaseString], [_lastName lowercaseString],
                                                                    [_userName lowercaseString], [self roleName]];

        case NURESTUserRoleOrgAdmin:
        case NURESTUserRoleOrgUser:
        case NURESTUserRoleOrgDesigner:
            return [CPString stringWithFormat:@"%s %s (%s) - %s %s", [_firstName lowercaseString], [_lastName lowercaseString],
                                                                    [_userName lowercaseString], [self roleName], [_enterpriseName lowercaseString]];
    }
}

- (NUVSDEnterprise)currentEnterprise
{
    throw "Implement me";
}


#pragma mark -
#pragma mark Utilites

- (void)hasRoles:(CPArray)someRoles
{
    return [someRoles containsObject:_role];
}

- (void)prepareUpdatePassword:(CPString)aNewPassword
{
    _desiredNewPassword = aNewPassword;
}

@end
