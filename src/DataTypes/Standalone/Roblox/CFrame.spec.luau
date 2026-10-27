local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)
local JestGlobals = require(game.ReplicatedStorage.DevPackages.JestGlobals)

local it = JestGlobals.it
local expect = JestGlobals.expect

local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local BufferStream = require(dataTypesRoot.Parent.BufferStream)
local CFrameStream = require(dataTypesRoot.Helpers.CFrameStream)
local CFrameDefinition = require(script.Parent.CFrame)

local VALUES = {
	CFrame.identity,
	CFrame.Angles(math.pi, 0, -math.pi / 2),
	CFrame.new(0, 0, 0, 1, 2, 3, 4),
	-- reflection, axis aligned but can't be stored as a rotation index
	CFrame.new(1, 2, 3, 1, 0, 0, 0, 1, 0, 0, 0, -1),
}

local function writtenLength(cframe: CFrame)
	local stream = BufferStream.dynamic(buffer.create(0))
	CFrameDefinition:writeStream(stream, cframe)
	return stream:getCursor()
end

-- https://dom.rojo.space/binary.html#cframe
-- euler angles in degrees, applied in YXZ order
local BINARY_FORMAT_IDS = {
	[0x02] = { 0, 0, 0 },
	[0x03] = { 90, 0, 0 },
	[0x05] = { 0, 180, 180 },
	[0x06] = { -90, 0, 0 },
	[0x07] = { 0, 180, 90 },
	[0x09] = { 0, 90, 90 },
	[0x0a] = { 0, 0, 90 },
	[0x0c] = { 0, -90, 90 },
	[0x0d] = { -90, -90, 0 },
	[0x0e] = { 0, -90, 0 },
	[0x10] = { 90, -90, 0 },
	[0x11] = { 0, 90, 180 },
	[0x14] = { 0, 180, 0 },
	[0x15] = { -90, -180, 0 },
	[0x17] = { 0, 0, 180 },
	[0x18] = { 90, 180, 0 },
	[0x19] = { 0, 0, -90 },
	[0x1b] = { 0, -90, -90 },
	[0x1c] = { 0, -180, -90 },
	[0x1e] = { 0, 90, -90 },
	[0x1f] = { 90, 90, 0 },
	[0x20] = { 0, 90, 0 },
	[0x22] = { -90, 90, 0 },
	[0x23] = { 0, -90, 180 },
}

it("should write axis aligned rotations with the binary format ids", function()
	for id, degrees in BINARY_FORMAT_IDS do
		local rx, ry, rz = math.rad(degrees[1]), math.rad(degrees[2]), math.rad(degrees[3])
		local cframe = CFrame.new(1, 2, 3) * CFrame.fromEulerAngles(rx, ry, rz, Enum.RotationOrder.YXZ)

		local stream = BufferStream.dynamic(buffer.create(0))
		CFrameStream.write(stream, cframe)
		expect(stream:getCursor()).toBe(1 + 12)

		stream:setCursor(0)
		expect(stream:readu8()).toBe(id)

		-- the euler angles leave float noise in the input, the decoded rotation should be exact
		-- compared with == rather than toEqual since signed zeros are expected
		local expected = { cframe:GetComponents() }
		stream:setCursor(0)
		local decoded = { CFrameStream.read(stream):GetComponents() }
		for i = 1, 12 do
			local component = if i <= 3 then expected[i] else math.round(expected[i])
			expect(decoded[i] == component).toBe(true)
		end
	end
end)

it("should write reflections and complex rotations in full", function()
	expect(writtenLength(CFrame.new(1, 2, 3, 1, 0, 0, 0, 1, 0, 0, 0, -1))).toBe(1 + 1 + 48)
	expect(writtenLength(CFrame.new(0, 0, 0, 1, 2, 3, 4))).toBe(1 + 1 + 48)
end)

TestHelper.dataType(CFrameDefinition, {
	values = table.pack(table.unpack(VALUES)),
	compare = function(a, b)
		--[[
		WAIT! That's not lossless?!?!

		CFrame's that are aligned to the cardinal axes are stored as a single byte.
		The concept is described here: https://dom.rojo.space/binary.html#cframe
		However, b/c of floating point math the components of this type of cframe
		often doesn't get stored perfectly as -1, 0, or 1. Thus, we sanitize the value
		within range of f32 epsilon error before encoding it.

		This means that the in the case of these aligned CFrames you might not get a lossless
		encoding, but that's b/c you're actually getting a **MORE** accurate result than what's
		being input.
		--]]
		return CFrameStream.equals(a, b)
	end,
})
