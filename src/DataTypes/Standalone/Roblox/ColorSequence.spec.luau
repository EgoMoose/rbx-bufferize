local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	ColorSequence.new(Color3.new(0, 0, 0)),
	ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.new(1, 0, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(0, 0, 1)),
	}),
}

TestHelper.dataType(require(script.Parent.ColorSequence), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
