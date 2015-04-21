@import "NUCategory.j"
@import "NUJobExport.j"
@import "NUJobImport.j"
@import "NUMetadata.j"
@import "NUMetadataGlobal.j"
@import "NUMetadataTag.j"
@import "NUValidation.j"
@import "NUVSDObject.j"
@import "NUVSDRESTUser.j"

[[NURESTModelController defaultController] registerModelClass:NUMetadata];
[[NURESTModelController defaultController] registerModelClass:NUMetadataGlobal];
[[NURESTModelController defaultController] registerModelClass:NUMetadataTag];
[[NURESTModelController defaultController] registerModelClass:NUVSDObject];
