/*
*   Filename:         NUIPUtils.j
*   Created:          Fri Aug  9 10:57:07 PDT 2013
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

@import "Resources/ipaddr.js"

function validateIPAddress(aString)
{
    return ipaddr.IPv4.isValid(aString)
}


function parseIPAddress(aString)
{
    var ret = {};

    try
    {
        ret.representedObject   = ipaddr.parseCIDR(aString);
        ret.netmask             = ret.representedObject.netmask.ip;
        ret.gateway             = ret.representedObject.address.firstIP;
        ret.address             = ret.representedObject.address.ip;
        ret.CIDR                = ret.representedObject.netmask.bits;
        ret.firstIP             = ret.representedObject.address.firstIP;
        ret.lastIP              = ret.representedObject.address.lastIP;
    }
    catch (e)
    {
        ret.representedObject   = nil;
        ret.netmask             = nil;
        ret.gateway             = nil;
        ret.address             = nil;
        ret.CIDR                = nil;
        ret.firstIP             = nil;
        ret.lastIP              = nil;
    }

    return ret;
}


function isNetworkContainedInNetwork(IP, network)
{
    var addr = ipaddr.parse(IP),
        CIDR = ipaddr.parseCIDR(network);

    return addr.match(CIDR);
}


function pullRandomIPFromNetwork(network)
{
    var CIDR        = ipaddr.parseCIDR(network),
        randomValue = Math.floor(Math.random() * CIDR.IPNumber),
        randomIP    = CIDR.address.decimals + randomValue;

    return ipaddr.parse(randomIP);
}


function areNetworksOverlapping(CIDR1, CIDR2)
{
    var CIDR1 = ipaddr.parseCIDR(CIDR1),
        CIDR2 = ipaddr.parseCIDR(CIDR2);

    return CIDR1.address.match(CIDR2);
}


function _randomCIDRFromBase(base)
{
    var digit2 = Math.floor(Math.random() * 120) + 10,
        digit3 = Math.floor(Math.random() * 120) + 10;

    return base + @"." + digit2 + @"." + digit3 + @".0/24"
}


function _isNetworkOverlapsAny(existingCIDRs, candidateCIDR)
{
    for (var i = existingCIDRs.length - 1; i >= 0; i--)
    {
        var existingCIDR = existingCIDRs[i];

        if (areNetworksOverlapping(existingCIDR, candidateCIDR))
            return true;
    }

    return false;
}


function firstValidCIDRFrom(existingCIDRs)
{
    if (!existingCIDRs || existingCIDRs.length == 0)
        return _randomCIDRFromBase(10);

    var candidateCIDR,
        tryNumber = 0,
        base = 10;

    while (tryNumber < 1000) // set a very hard limit just in case
    {
        candidateCIDR = _randomCIDRFromBase(base);

        if (!_isNetworkOverlapsAny(existingCIDRs, candidateCIDR))
            break;

        tryNumber++;

        if (tryNumber == 30)
            base = 192;

        if (tryNumber == 60)
            base = Math.floor(Math.random() * 120) + 10;
    }

    return candidateCIDR;
}


function firstIPInNetwork(network)
{
    var CIDR = ipaddr.parseCIDR(network);
    return CIDR.netmask.firstIP;
}


function lastIPInNetwork(network)
{
    var CIDR = ipaddr.parseCIDR(network);
    return CIDR.netmask.lastIP;
}
