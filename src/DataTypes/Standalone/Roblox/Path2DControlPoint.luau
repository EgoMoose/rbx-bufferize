local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("Path2DControlPoint", {
	read = function(stream)
		local pos = UDim2.new(stream:readf32(), stream:readi32(), stream:readf32(), stream:readi32())
		local left = UDim2.new(stream:readf32(), stream:readi32(), stream:readf32(), stream:readi32())
		local right = UDim2.new(stream:readf32(), stream:readi32(), stream:readf32(), stream:readi32())
		return Path2DControlPoint.new(pos, left, right)
	end,
	write = function(stream, ctrlP)
		local pos = ctrlP.Position
		stream:writef32(pos.X.Scale)
		stream:writei32(pos.X.Offset)
		stream:writef32(pos.Y.Scale)
		stream:writei32(pos.Y.Offset)

		local left = ctrlP.LeftTangent
		stream:writef32(left.X.Scale)
		stream:writei32(left.X.Offset)
		stream:writef32(left.Y.Scale)
		stream:writei32(left.Y.Offset)

		local right = ctrlP.RightTangent
		stream:writef32(right.X.Scale)
		stream:writei32(right.X.Offset)
		stream:writef32(right.Y.Scale)
		stream:writei32(right.Y.Offset)
	end,
})
