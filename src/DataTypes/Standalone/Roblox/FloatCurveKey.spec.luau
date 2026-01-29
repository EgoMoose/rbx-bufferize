local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local key = FloatCurveKey.new(0.3, math.pi, Enum.KeyInterpolationMode.Cubic)
key.LeftTangent = 80
key.RightTangent = -math.sqrt(2)

local VALUES = {
	FloatCurveKey.new(0.3, math.pi, Enum.KeyInterpolationMode.Cubic),
	FloatCurveKey.new(100, 32, Enum.KeyInterpolationMode.Constant),
	FloatCurveKey.new(0.002123, -7.82567, Enum.KeyInterpolationMode.Linear),
	FloatCurveKey.new(math.pi, math.exp(1), Enum.KeyInterpolationMode.Cubic),
	key,
}

TestHelper.dataType(require(script.Parent.FloatCurveKey), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
