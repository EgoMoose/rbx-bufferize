local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	PathWaypoint.new(Vector3.new(0, 12, math.pi), Enum.PathWaypointAction.Jump),
	PathWaypoint.new(Vector3.new(-100, 2, 0), Enum.PathWaypointAction.Custom),
	PathWaypoint.new(Vector3.new(0, math.exp(1), math.huge), Enum.PathWaypointAction.Walk, "Hello world!"),
}

TestHelper.dataType(require(script.Parent.PathWaypoint), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a == b
	end,
})
