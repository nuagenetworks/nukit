@import <Foundation/Foundation.j>
@import <NUKit/NUAbstractDataView.j>

@global NUNullDescriptionTransformerName


@implementation DataView : NUAbstractDataView
{
    @outlet CPTextField fieldDescription;
    @outlet CPTextField fieldName;
}

- (void)bindDataView
{
    [super bindDataView];

    var descriptionTransformer = @{CPValueTransformerNameBindingOption: NUNullDescriptionTransformerName};

    [fieldDescription bind:CPValueBinding toObject:_objectValue withKeyPath:@"description" options:descriptionTransformer];
    [fieldName bind:CPValueBinding toObject:_objectValue withKeyPath:@"name" options:nil];
}

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        fieldDescription = [aCoder decodeObjectForKey:@"fieldDescription"];
        fieldName = [aCoder decodeObjectForKey:@"fieldName"];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:fieldDescription forKey:@"fieldDescription"];
    [aCoder encodeObject:fieldName forKey:@"fieldName"];
}

@end
