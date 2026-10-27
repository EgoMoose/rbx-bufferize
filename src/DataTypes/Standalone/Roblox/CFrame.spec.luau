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

-- every axis aligned rotation
local ALIGNED = {}
for _, rx in { 0, 90, 180, 270 } do
	for _, ry in { 0, 90, 180, 270 } do
		for _, rz in { 0, 90, 180, 270 } do
			table.insert(ALIGNED, CFrame.new(1, 2, 3) * CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz)))
		end
	end
end

local function writtenLength(cframe: CFrame)
	local stream = BufferStream.dynamic(buffer.create(0))
	CFrameDefinition:writeStream(stream, cframe)
	return stream:getCursor()
end

it("should write axis aligned rotations as an index", function()
	local indices = {}
	for _, cframe in ALIGNED do
		local stream = BufferStream.dynamic(buffer.create(0))
		CFrameStream.write(stream, cframe)
		expect(stream:getCursor()).toBe(1 + 12)

		stream:setCursor(0)
		local index = stream:readu8()
		expect(index >= 1 and index <= 24).toBe(true)
		indices[index] = true

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

	for i = 1, 24 do
		expect(indices[i]).toBe(true)
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
