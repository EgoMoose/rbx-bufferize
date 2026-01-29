local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	UDim.new(0, 0),
	UDim.new(math.pi, 10),
	UDim.new(-math.pi, 10.7),
}

TestHelper.dataType(require(script.Parent.UDim), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
