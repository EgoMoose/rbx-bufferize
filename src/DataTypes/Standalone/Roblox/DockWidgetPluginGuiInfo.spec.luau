local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	DockWidgetPluginGuiInfo.new(),
}

TestHelper.dataType(require(script.Parent.DockWidgetPluginGuiInfo), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
