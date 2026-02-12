local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

-- named 'luaFunction' b/c auto-import is being annoying if the file is just called 'function'

return DataTypeDefinition.never("function")
