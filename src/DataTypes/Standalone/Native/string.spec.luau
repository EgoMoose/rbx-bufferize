local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	"Hello world!",
	string.rep("x", math.pow(2, 16) - 1),
	string.rep("x", math.pow(2, 8) - 1),
}

TestHelper.dataType(require(script.Parent.string), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
