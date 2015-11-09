@import <Foundation/Foundation.j>

@implementation Cucumber (CuCapp)

- (CPString)valueIsEqual:(CPArray)params
{
    var obj = cucumber_objects[params[0]],
        value = params[1];

    if (!obj)
        return '{"result" : "__CUKE_ERROR__"}';

    if ([obj respondsToSelector:@selector(stringValue)] && value === [obj stringValue])
        return '{"result" : "OK"}';

    return '{"result" : "__CUKE_ERROR__", "value" : "' + [obj stringValue] + '", "exepectedValue" : "' + value + '"}';
}

- (id)isControlFocused:(CPArray)params
{
    var obj = cucumber_objects[params[0]];

    if (!obj)
        return '{"result" : "__CUKE_ERROR__"}';

    var window = [obj window],
        firstResponder = [window firstResponder];

    if ([obj isKindOfClass:[NUNetworkTextField class]])
    {
        if ([firstResponder isKindOfClass:[_NUNetworkElementTextField class]] && [firstResponder delegate] == obj)
            return '{"result" : "OK"}';
        else
            return '{"result" : "NOT FOCUSED"}';
    }

    if (firstResponder == obj)
        return '{"result" : "OK"}';

    return '{"result" : "NOT FOCUSED"}';
}

@end