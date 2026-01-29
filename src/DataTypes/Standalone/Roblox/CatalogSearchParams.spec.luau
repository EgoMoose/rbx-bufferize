local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	CatalogSearchParams.new(),
}

TestHelper.dataType(require(script.Parent.CatalogSearchParams), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
