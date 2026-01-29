local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

return DataTypeDefinition.new("TweenInfo", {
	read = function(stream)
		local t = stream:readf32()
		local easingStyle = Enum.EasingStyle:FromValue(stream:readu16()) :: Enum.EasingStyle
		local easingDirection = Enum.EasingDirection:FromValue(stream:readu16()) :: Enum.EasingDirection
		local repeatCount = stream:readu32() - 1
		local reverses = stream:readu8() == 1
		local delayTime = stream:readf32()

		return TweenInfo.new(t, easingStyle, easingDirection, repeatCount, reverses, delayTime)
	end,
	write = function(stream, info)
		stream:writef32(info.Time)
		stream:writeu16(info.EasingStyle.Value)
		stream:writeu16(info.EasingDirection.Value)
		stream:writeu32(math.max(-1, info.RepeatCount) + 1) --  not sure abt this?
		stream:writeu8(if info.Reverses then 1 else 0)
		stream:writef32(info.DelayTime)
	end,
})
