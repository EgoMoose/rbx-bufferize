local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

-- TODO: This can be supported, it just has a lot of properties...
return DataTypeDefinition.unsupported("CatalogSearchParams")
