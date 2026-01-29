local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Axes.new(Enum.Axis.X),
	Axes.new(Enum.Axis.Y),
	Axes.new(Enum.Axis.Z),
	Axes.new(Enum.Axis.X, Enum.Axis.Y),
	Axes.new(Enum.Axis.X, Enum.Axis.Y, Enum.Axis.Z),
	Axes.new(Enum.Axis.X, Enum.Axis.Z),
	Axes.new(Enum.Axis.Y, Enum.Axis.Z),
}

TestHelper.dataType(require(script.Parent.Axes), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
