/*
*   Filename:         NUUtilities.j
*   Created:          Fri Oct 26 15:48:23 PDT 2012
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

@import "NUIPUtils.j"

// @import "../Resources/FileSaver.js"

@global NUApplicationCuccapSupported

function _configure_nuage_tabview(tabView)
{
    [tabView setTabItemViewPrototype:[NUTabViewItemPrototype new]];
    [tabView setTabViewBackgroundColor:NUSkinColorGreyLight];
    [tabView setEnableManualScrolling:NO];
    [tabView setBorderColor:NUSkinColorGrey];
}

function _json_to_query_parameters(json)
{
    var ret = "";

    for (key in json)
        ret += key + '=' + encodeURIComponent(json[key]) + '&';

    return ret;
}

function createDownload(content, filename, extension)
{
    var contentType = 'application/octet-stream',
        a = document.createElement('a'),
        blob = new Blob([content], {'type':contentType});

    a.href = window.URL.createObjectURL(blob);
    a.download = filename + "." + extension;
    a.click();
    delete a;
}

/*
    Quick Accessors and Developers Sweets
*/
function _v(dict)
{
    return [dict objectForKey:"value"];
}

function _l(dict)
{
    return [dict objectForKey:"label"];
}

function _cucappID(object, cucappID)
{
    if (NUApplicationCuccapSupported)
        [object setCucappIdentifier:cucappID];
}

function _generateRandomMAC()
{
    var hexTab      = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"],
        dA          = "BE",
        dB          = "EF",
        dC          = hexTab[Math.round(Math.random() * 15)] + hexTab[Math.round(Math.random() * 15)],
        dD          = hexTab[Math.round(Math.random() * 15)] + hexTab[Math.round(Math.random() * 15)],
        dE          = hexTab[Math.round(Math.random() * 15)] + hexTab[Math.round(Math.random() * 15)],
        dF          = hexTab[Math.round(Math.random() * 15)] + hexTab[Math.round(Math.random() * 15)];

    return dA + ":" + dB + ":" + dC + ":" + dD + ":" + dE + ":" + dF;
}

function _currentUserHasRoles(someRoles)
{
    return [[NURESTUser defaultUser] hasRoles:someRoles];
}

function _currentUserOwnerOfParentDomain(anObject)
{
    var domainsTypes = [[NUDomainTemplate RESTName], [NUDomain RESTName], [NUL2DomainTemplate RESTName], [NUL2Domain RESTName]];
    return [anObject isCurrentUserOwnerOfAnyParentMatchingTypes:domainsTypes];
}

function _get_query_parameter_with_name(name)
{
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");

    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);

    return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

function _massageThemeState(aThemeState)
{
    if (aThemeState && aThemeState.isa && [aThemeState isKindOfClass:CPArray])
        aThemeState = CPThemeState.apply(null, aThemeState);

    return aThemeState;
}


/*
    Validation System
*/

function _handleAttr(attr, name)
{
    return !attr || name == attr;
}

function _handleAttrs(attr, names)
{
    return !attr || [names containsObject:attr];
}

function _validatePasswordMatch(validation, partialAttribute, obj, properties)
{
    if (!_handleAttrs(partialAttribute, properties))
        return validation;

    for (var i = [properties count] - 1; i >= 0; i--)
         [validation removeErrorForProperty:properties[i]];

     var password = [obj valueForKeyPath:properties[0]],
         confirm = [obj valueForKeyPath:properties[1]];

     if (password != confirm)
     {
         [validation setErrorTitle:"Doesn't match" forProperty:properties[0]];
         [validation setErrorTitle:"Doesn't match" forProperty:properties[1]];
     }

     return validation;
}

function _validateAllSet(validation, partialAttribute, obj, properties, functions)
{
    if (!_handleAttrs(partialAttribute, properties))
        return validation;

    for (var i = [properties count] - 1; i >= 0; i--)
         [validation removeErrorForProperty:properties[i]];

     var allNull = true;

     for (var i = [properties count] - 1; i >= 0; i--)
     {
         if ([obj valueForKeyPath:properties[i]])
         {
             allNull = false;
             break;
         }
     }

     if (allNull)
         return validation;

    for (var i = [properties count] - 1; i >= 0; i--)
    {
        var prop = properties[i];

        if (![obj valueForKeyPath:prop])
            [validation setErrorTitle:"Must be set" forProperty:prop];
    }

    return validation;
}

function _validate(validation, partialAttribute, obj, property, functions)
{
    if (!_handleAttr(partialAttribute, property))
        return validation;

    // first, cleanup old state if any
    [validation removeErrorForProperty:property];

    for (var i = 0, c = [functions count]; i < c; i++)
    {
        var f = functions[i][0],
            args = [[obj valueForKeyPath:property]],
            additionalArgs = functions[i].slice(1);

        if (additionalArgs.length)
            args = args.concat(additionalArgs);

        var response = f.apply(this, args);

        if (response)
            [validation setErrorTitle:response forProperty:property];
    }

    return validation;
}

function _IPAddress(string, canBeNull, canBeAll)
{
    if (canBeNull && !string)
        return;

    if (!string)
        return "Not a valid address";

    if (canBeAll && string == "0.0.0.0/0")
        return nil;

    if (string.indexOf("0.") == 0)
        return "0.x.x.x is not a valid address";

    var success = !_stringNotEmpty(string) && validateIPAddress(string);
    return success ? null : "Not a valid address";
}

function _virtualIP(string)
{
    if (string == "0.0.0.0")
        return "0.0.0.0 is not a valid virtual IP";

    return (_IPAddress(string, true));
}

function _NetworkMacro(string)
{
    if (string == "0.0.0.0/0")
        return nil;

    var success = !_IPAddress(string, true, true);
    return success ? null : "Not valid network";
}

function _MACAddress(string, canBeNull)
{
    if (canBeNull && !string)
        return;

    var re = new RegExp("^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$"),
        success = re.test(string);
    return success ? null : "Not a valid MAC address";
}

function _stringNotEmpty(string)
{
    if (!string)
        return "Must not be empty";

    string = "" + string;

    var success = string && string.length > 0;
    return success ? null : "Must not be empty";
}

function _stringLenBetween(string, min, max)
{
    if (!string && !min)
        return;

    if (!string)
        return  "Lenght must be longer than 0";

    var l = string.length,
        success = l >= min && l <= max;

    return success ? null : "Lenght must be between " + min + " and " + max + " characters";
}

function _maxLength(string, size)
{
    if (!string)
        return;

    var success = string.length <= size;
    return success ? null : "Must not be longer than " + size + " characters";
}

function _emailAddress(email)
{
    if (!email)
        return "is not a valid email";

    email = email.replace( /\s/g, "");
    var re = new RegExp("^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$"),
        success = re.test(email);
    return success ? null : "Not a valid email";
}

function _number(string)
{
    var success = !isNaN(parseFloat(string)) && isFinite(string);
    return success ? null : "Not a valid number";
}

function _positiveNumber(string, canBeNull, canBeZero)
{
    if (canBeNull && !string)
        return;

    var success;

    if (canBeZero)
        success = !_number(string) && parseInt(string) >= 0;
    else
        success = !_number(string) && parseInt(string) > 0;

    return success ? null : "Not a valid positive number";
}

function _floatingIPQuota(string)
{
    var success = !_number(string) && parseInt(string) >= 0;
    return success ? null : "Not a valid quota";
}

function _numberBetween(n, min, max)
{
    var success = !_number(n) && n >= min && n <= max;
    return success ? null : "Must be between " + min + " and " + max;
}

function _routeTarget(string)
{
    if (!string)
        return;

    string = string.replace( /\s/g, "");
    var re = /^\d{1,42}:\d{1,42}$/,
        success = re.test(string);

    return success ? null : "Format must be number:number";
}

function _routeDistinguisher(string)
{
    return _routeTarget(string);
}

function _alphaNumeric(string)
{
    if (!string)
        return;

    var re = /^[\w\s-]*$/i,
        success = re.test(string);

    return success ? null : "Can only contains alphanumeric characters";
}

function _VPortNamingLimitation(string)
{
    if (!string)
        return;

    var re = /^[\w\s-:/]*$/i,
        success = re.test(string);

    return success ? null : "Can only contains alphanumeric characters";
}

function _rateLimiting(string)
{
    if (!string)
        return;

    return _positiveNumber(string, false, true);
}

function _hostsInSubnet(string)
{
    if (!string)
        return;

    var x = parseInt(string),
        success = !_positiveNumber(string, false, true) && ((x & (x - 1)) == 0);

    return success ? null : "Must be a power of 2";
}

function _gatewayPortName(string)
{
    if (!string)
        return "Format must be x/x/x or ethx";

    string = string.replace( /\s/g, "");
    var re1 = /^\d{1,42}\/\d{1,42}\/\d{1,42}$/,
        re2 = /^eth\d{1,42}$/,
        success = re1.test(string) || re2.test(string);

    return success ? null : "Format must be x/x/x or ethx";
}

function _VLANNumber(string)
{
    var success = !_number(string) && string >= 0 && string <= 4094;
    return success ? null : "VLAN value must be an integer between 0 and 4094";

}

function _rangePattern(aPattern, min, max)
{
    if (!aPattern)
        return "Not a correct range pattern";

    var re = /^\d*-\d*$/,
        success = re.test(aPattern);

    if (success)
    {
        var digit = aPattern.split("-");

        if (parseInt(digit[0]) >= parseInt(digit[1]))
            return "First digit must be smaller than second one";

        if (min != undefined && digit[0] < min)
            return "First digit must be greater than " + min;

        if (max != undefined && digit[1] > max)
            return "First digit must be smaller than " + max;

        return nil;
    }
    else
        return "Not a correct range pattern";
}

function _complexRangePattern(aPattern, min, max)
{
    if (!aPattern)
        return "Not a correct range pattern";

    aPattern = aPattern.replace(/ /g, "");

    var digits = aPattern.split(",");

    for (var i = digits.length - 1; i >= 0; i--)
    {
        var digit = digits[i],
            isPositiveNumber = !_positiveNumber(digit, false, true),
            isPattern = !_rangePattern(digit, min, max);

        if (!isPositiveNumber && !isPattern)
            return "Not a correct range pattern";

        if (isPositiveNumber && parseInt(digit) > max)
            return "One value is greater than " + max;

        if (isPositiveNumber && parseInt(digit) < min)
            return "One value is smaller than " + min;
    }

    return nil;
}

function _PolicyEntryPort(aPort)
{
    var success = (aPort == "*") || (!_positiveNumber(aPort, false, true) && parseInt(aPort) <= 65535 && parseInt(aPort) != 0) || !_rangePattern(aPort, 1, 65535);
    return success ? null : "Port must be an integer between 1 and 65535 or '*' or a range (n-n)";
}

function _IPInNetwork(IP, network)
{
    try {
        if (!isNetworkContainedInNetwork(IP, network))
            return IP + " is not valid in network " + network;
    }
    catch (e){}

    return nil;
}

function _phoneNumber(aPhoneNumber, mandatory)
{
    if (!aPhoneNumber)
        return mandatory ? "Phone number is mandatory" : null;

    var re = /^[0-9+]{5,15}$/,
        success = re.test(aPhoneNumber);

    return success ? null : "Not a valid phone number";
}
