local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

TestHelper.dataType(require(script.Parent["nil"]), {
	values = table.pack(nil),
	compare = function(a, b)
		return a == b
	end,
})
