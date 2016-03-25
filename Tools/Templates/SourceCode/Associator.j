@import <Foundation/Foundation.j>
@import <NUKit/NUAbstractSimpleObjectAssociator.j>

@implementation Associator : NUAbstractSimpleObjectAssociator

- (CPArray)currentActiveContextIdentifiers
{
    // Returns an array of RESTNames of objects that needs to be associated
    return [[ObjectClass RESTName]];
}

- (CPDictionary)associatorSettings
{
    // Dictionary containing information for each
    // kind of associated objects
    return @{
                [ObjectClass RESTName]: @{
                    // This key tells what registered data view to use for the associated object
                    NUObjectAssociatorSettingsDataViewNameKey: @"objectDataView",

                    // This key tells what fetcher keyPath to use to retrieve in the associated objects
                    NUObjectAssociatorSettingsAssociatedObjectFetcherKeyPathKey: @"childrenObjects"
                }
            };
}

- (CPString)emptyAssociatorTitle
{
    // Title of the associator when nothing is associated
    return @"No selected object";
}

- (CPString)titleForObjectChooser
{
    // Title of the object chooser
    return @"Select an object";
}

- (CPString)keyPathForAssociatedObjectID
{
    // KeyPath of the association key
    return @"associatedObjectID";
}

- (NUVSDObject)parentOfAssociatedObjects
{
    // Returns the instance of the parent object
    // where the possible associated objects will be fetched from.
    return [rootObject current];
}

@end
