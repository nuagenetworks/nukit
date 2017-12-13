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

@import "Resources/ipaddr.js"

function validateIPAddress(aString)
{
    try {
        var CIDR = ipaddr.parseCIDR(aString);
        return ipaddr.isValid(CIDR.address.ip);
    }
    catch (e)
    {
        return ipaddr.isValid(aString)
    }
}


function parseIPAddress(aString)
{
    var ret = {};

    try
    {
        ret.representedObject   = ipaddr.parseCIDR(aString);
        ret.netmask             = ret.representedObject.netmask.ip;
        ret.gateway             = ret.representedObject.firstIP;
        ret.address             = ret.representedObject.address.ip;
        ret.CIDR                = ret.representedObject.netmask.bits;
        ret.firstIP             = ret.representedObject.firstIP;
        ret.lastIP              = ret.representedObject.lastIP;
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
    try
    {
        var CIDR = ipaddr.parseCIDR(network);
        return CIDR.firstIP;
    }
    catch (e)
    {
        return nil;
    }
}


function lastIPInNetwork(network)
{
    try
    {
        var CIDR = ipaddr.parseCIDR(network);
        return CIDR.lastIP;
    }
    catch (e)
    {
        return nil;
    }
}

function _randomIPv6FromBase(base)
{
    var digit2 = Math.floor(Math.random() * 65535).toString(16);
        digit3 = Math.floor(Math.random() * 65535).toString(16);
        digit4 = Math.floor(Math.random() * 65535).toString(16);
        digit5 = Math.floor(Math.random() * 65535).toString(16);
        digit6 = Math.floor(Math.random() * 65535).toString(16);
        digit7 = Math.floor(Math.random() * 65535).toString(16);

    return base + @":" + digit2 + @":" + digit3 + @":" + digit4 + @":" + digit5 + @":" + digit6 + @":" + digit7 + @":0/64";
}

function firstValidIPv6From(existingCIDRs)
{
    if (!existingCIDRs || existingCIDRs.length == 0)
        return _randomIPv6FromBase(2005);

    var candidateCIDR,
        tryNumber = 0,
        base = 2005;

    while (tryNumber < 1000) // set a very hard limit just in case
    {
        candidateCIDR = _randomIPv6FromBase(base);

        if (!_isNetworkOverlapsAny(existingCIDRs, candidateCIDR))
            break;

        tryNumber++;

        if (tryNumber == 30)
            base = 0000;

        if (tryNumber == 60)
            base = Math.floor(Math.random() * 65535).toString(16);
    }

    return candidateCIDR;
}

function firstIPv6InNetwork(network)
{
    var index = network.lastIndexOf(":");
    return network.substring(0, index) + ":1";
}
