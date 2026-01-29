local devPackagesRoot = game.ReplicatedStorage.DevPackages
local TestHelper = require(devPackagesRoot.TestHelper)
local Sift = require(devPackagesRoot.Sift)

-- we have to be careful about including stuff like buffers b/c they won't compare properly

local VALUES: { { [any]: any } } = {
	{ hello = "world", goodbye = { world = "hello" } },
	{ hello = "hello", world = "goodbye" },
}

TestHelper.dataType(require(script.Parent.table), {
	values = table.pack(table.unpack(VALUES)),
	compare = Sift.Dictionary.equalsDeep,
})
