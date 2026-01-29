local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("ColorSequence", {
	read = function(stream)
		local keypoints = {}
		local nKeypoints = stream:readu32()
		for i = 1, nKeypoints do
			local t = stream:readf32()
			local color = Color3.fromRGB(stream:readu8(), stream:readu8(), stream:readu8())
			keypoints[i] = ColorSequenceKeypoint.new(t, color)
		end
		return ColorSequence.new(keypoints)
	end,
	write = function(stream, sequence)
		local keypoints = sequence.Keypoints
		stream:writeu32(#keypoints)
		for _, kp in keypoints do
			local rHex, gHex, bHex = kp.Value:ToHex():match("(..)(..)(..)")
			stream:writef32(kp.Time)
			stream:writeu8(tonumber(rHex, 16) :: number)
			stream:writeu8(tonumber(gHex, 16) :: number)
			stream:writeu8(tonumber(bHex, 16) :: number)
		end
	end,
})
