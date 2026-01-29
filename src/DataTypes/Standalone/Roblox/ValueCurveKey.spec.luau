local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	ValueCurveKey.new(0, 1, Enum.KeyInterpolationMode.Linear),
}

TestHelper.dataType(require(script.Parent.ValueCurveKey), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
