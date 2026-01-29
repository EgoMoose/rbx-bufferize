local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Faces.new(Enum.NormalId.Right),
	Faces.new(Enum.NormalId.Top),
	Faces.new(Enum.NormalId.Back),
	Faces.new(Enum.NormalId.Back, Enum.NormalId.Right),
	Faces.new(
		Enum.NormalId.Back,
		Enum.NormalId.Bottom,
		Enum.NormalId.Front,
		Enum.NormalId.Left,
		Enum.NormalId.Right,
		Enum.NormalId.Top
	),
}

TestHelper.dataType(require(script.Parent.Faces), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
