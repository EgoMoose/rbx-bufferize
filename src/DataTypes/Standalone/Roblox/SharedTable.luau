local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

-- technically we could use a modified version of the table type, but that would require this to also be dependant
return DataTypeDefinition.unsupported("SharedTable")
