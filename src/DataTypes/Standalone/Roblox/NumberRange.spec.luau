local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	NumberRange.new(1),
	NumberRange.new(0, 1),
	NumberRange.new(-1, 1),
	NumberRange.new(math.pi),
	NumberRange.new(-math.pi, math.exp(1)),
}

TestHelper.dataType(require(script.Parent.NumberRange), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
