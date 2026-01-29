local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	UDim2.new(0, 0, 0, 0),
	UDim2.new(math.pi, 10, math.pi, 10),
	UDim2.new(-math.pi, 10.7, -math.pi, 10.7),
}

TestHelper.dataType(require(script.Parent.UDim2), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
