local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	0,
	1,
	-1,
	math.pi,
	-math.pi * 2,
	math.huge,
	-math.huge,
	math.pow(2, 33),
	math.pow(2, 32) - 1,
	math.pow(2, 16) - 1,
	math.pow(2, 8) - 1,
	-math.pow(2, 31),
	-math.pow(2, 16),
	-math.pow(2, 7),
}

TestHelper.dataType(require(script.Parent.number), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
