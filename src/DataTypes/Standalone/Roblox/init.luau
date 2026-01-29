local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypePacker = require(dataTypesRoot.DataTypePacker)

return DataTypePacker.packModules(script:GetChildren())
