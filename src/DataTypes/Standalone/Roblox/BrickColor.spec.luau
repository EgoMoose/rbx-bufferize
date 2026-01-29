local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	BrickColor.new("Alder"),
	BrickColor.new("Black metallic"),
	BrickColor.new("Bright purple"),
	BrickColor.new("Carnation pink"),
	BrickColor.new("Light Royal blue"),
}

TestHelper.dataType(require(script.Parent.BrickColor), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
