local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.never("RaycastResult")
