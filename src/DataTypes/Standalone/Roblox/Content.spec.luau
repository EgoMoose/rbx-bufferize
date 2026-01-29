local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	Content.none,
	Content.fromAssetId(123),
	Content.fromUri("rbxasset://Textures/Sword128.png"),
}

TestHelper.dataType(require(script.Parent.Content), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
