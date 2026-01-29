local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Path2DControlPoint.new(),
	Path2DControlPoint.new(UDim2.new(-math.pi, -12009, 0.78, 76)),
	Path2DControlPoint.new(
		UDim2.new(-math.pi, -12009, 0.78, 76),
		UDim2.new(math.exp(1), -8.2, 10, 76),
		UDim2.new(1, 0, 0, 0)
	),
}

TestHelper.dataType(require(script.Parent.Path2DControlPoint), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
