local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	NumberSequence.new(1),
	NumberSequence.new(0, 1),
	NumberSequence.new(-1, 1),
	NumberSequence.new(-math.pi, math.exp(1)),
	NumberSequence.new({
		NumberSequenceKeypoint.new(0, math.pi, 2.76),
		NumberSequenceKeypoint.new(0.76542, -10),
		NumberSequenceKeypoint.new(1, 0, math.sqrt(2)),
	}),
}

TestHelper.dataType(require(script.Parent.NumberSequence), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
