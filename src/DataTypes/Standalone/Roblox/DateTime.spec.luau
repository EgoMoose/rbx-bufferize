local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)
local JestGlobals = require(game.ReplicatedStorage.DevPackages.JestGlobals)

local it = JestGlobals.it
local expect = JestGlobals.expect

local BufferStream = require(script:FindFirstAncestor("DataTypes").Parent.BufferStream)
local DateTimeDefinition = require(script.Parent.DateTime)

local VALUES = {
	DateTime.fromUnixTimestampMillis(0),
	DateTime.fromUnixTimestampMillis(1761522479123),
	DateTime.fromUnixTimestampMillis(-1234567890123),
	DateTime.fromUniversalTime(1400, 1, 1, 0, 0, 0, 0),
	DateTime.fromUniversalTime(9999, 12, 31, 23, 59, 59, 999),
	DateTime.fromUnixTimestampMillis(-17987443200000 + 2 ^ 32 - 1),
	DateTime.fromUnixTimestampMillis(-17987443200000 + 2 ^ 32),
}

it("should write 6 bytes after the type id", function()
	local stream = BufferStream.dynamic(buffer.create(0))
	DateTimeDefinition:writeStream(stream, DateTime.now())
	expect(stream:getCursor()).toBe(1 + 6)
end)

TestHelper.dataType(DateTimeDefinition, {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		return a.UnixTimestampMillis == b.UnixTimestampMillis
	end,
})
