local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local VALUES = {
	buffer.fromstring("Hello world!"),
	buffer.fromstring("soiuxhvciusehdodwlhdailoksdjwijikld   qdwuoadhuxiaugwshuidh qk"),
	buffer.create(math.pow(2, 16) - 1),
}

TestHelper.dataType(require(script.Parent.buffer), {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return buffer.tostring(a) == buffer.tostring(b)
	end,
})
