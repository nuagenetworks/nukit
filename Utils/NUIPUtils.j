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

@import "Resources/iplib.js"

/*! Test given string is a valid IP / netmask
*/
function validateIPAddress(ipaddr)
{
    // var regex = new RegExp("^(([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))\.){3}([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))/$");
    //
    // if (!regex.test(ipaddr))
    //     return false;

    try
    {
        var IP = new IPLib.IPv4Address(ipaddr);
        return true;
    }
    catch(e)
    {
        return false;
    }
}

function parseIPAddress(aString)
{
    var ret = {};

    try
    {
        ret.representedObject = new IPLib.CIDR(aString);
        ret.netmask = ret.representedObject.nm.getDot(),
        ret.gateway = ret.representedObject.getFirstIp().ip,
        ret.address = ret.representedObject.ip.getDot();
        ret.CIDR  = ret.representedObject.nm.getBits();
        ret.firstIP = ret.representedObject.getFirstIp().ip;
        ret.lastIP = ret.representedObject.getLastIp().ip;
    }
    catch (e)
    {
        ret.representedObject = nil;
        ret.netmask = nil;
        ret.gateway = nil;
        ret.address = nil;
        ret.CIDR = nil;
        ret.firstIP = nil;
        ret.firstIP = nil;
    }

    return ret;
}

function isNetworkContainedInNetwork(IP, network)
{
    var network = new IPLib.CIDR(network);

    return network.isValidIp(IP);
}

function pullRandomIPFromNetwork(network)
{
    var network = new IPLib.CIDR(network),
        ipNum = network.getIpNumber(),
        randomValue = Math.floor(Math.random() * ipNum),
        randomIP = network.ip.getDec() + randomValue;

    return new IPLib.IPv4Address(randomIP, IPLib.IP_DEC);
}

function areNetworksOverlapping(CIDR1, CIDR2)
{
    var net1 = new IPLib.CIDR(CIDR1),
        net2 = new IPLib.CIDR(CIDR2);

    return net1.isValidIp(net2);
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
    var net = new IPLib.CIDR(network);
    return net.getFirstIp().getDot();
}

function lastIPInNetwork(network)
{
    var net = new IPLib.CIDR(network);
    return net.getLastIp().getDot();
}
