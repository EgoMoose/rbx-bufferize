local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("NumberSequence", {
	read = function(stream)
		local keypoints = {}
		local nKeypoints = stream:readu32()
		for i = 1, nKeypoints do
			keypoints[i] = NumberSequenceKeypoint.new(stream:readf32(), stream:readf32(), stream:readf32())
		end
		return NumberSequence.new(keypoints)
	end,
	write = function(stream, sequence)
		local keypoints = sequence.Keypoints
		stream:writeu32(#keypoints)
		for _, kp in keypoints do
			stream:writef32(kp.Time)
			stream:writef32(kp.Value)
			stream:writef32(kp.Envelope)
		end
	end,
})
