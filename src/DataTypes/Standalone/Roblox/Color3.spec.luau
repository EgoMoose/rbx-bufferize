local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Color3.fromRGB(100, 70, 9),
	Color3.fromRGB(0, 0, 0),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(200, 200, 80),
	Color3.fromRGB(100, 0, 200),
}

TestHelper.dataType(require(script.Parent.Color3), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
