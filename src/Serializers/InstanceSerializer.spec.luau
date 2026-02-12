local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)
local JestGlobals = require(game.ReplicatedStorage.DevPackages.JestGlobals)

local it = JestGlobals.it
local expect = JestGlobals.expect

local bufferizeRoot = script.Parent.Parent
local TableHelper = require(bufferizeRoot.DataTypes.Helpers.TableHelper)
local Bufferize = require(bufferizeRoot)

-- INSTANCE TESTS

local testInstances = {}
local function createTestInstance(callback: () -> Instance)
	table.insert(testInstances, callback())
end

createTestInstance(function()
	local part = Instance.new("Part")
	part.Name = "SimplePart"
	part.Color = Color3.new(1, 0, 1)
	part.Anchored = true
	part.Transparency = 0.75
	return part
end)

createTestInstance(function()
	local root = Instance.new("Folder")
	root.Name = "NestedFolders"
	local parent = root
	for i = 1, 100 do
		parent = Instance.new("Folder", parent)
	end
	return root
end)

createTestInstance(function()
	local root = Instance.new("Model")
	local partA = Instance.new("Part", root)
	local partB = Instance.new("WedgePart", root)
	partB.Size = Vector3.new(math.pi, 10, 1000.78)
	local valPointer = Instance.new("ObjectValue", partB)
	valPointer.Parent = partA
	return root
end)

--

TestHelper.values(table.pack(table.unpack(testInstances)), function(instance)
	local serialized
	it("should serialize.", function()
		serialized = Bufferize.serializeInstance(instance)
		expect(typeof(serialized)).toEqual("table")
	end)

	local b
	it("should encode to a buffer.", function()
		b = Bufferize.encode(serialized)
		expect(typeof(b)).toEqual("buffer")
	end)

	local decoded
	it("should decode losslessly.", function()
		decoded = Bufferize.decode(b)
		expect(typeof(decoded)).toEqual("table")
	end)

	it("should match the initial serialization", function()
		local isEqual = TableHelper.equalsDeep(serialized, decoded, function(a, b)
			if typeof(a) == "userdata" and typeof(b) == "userdata" then
				return true
			end
			return a == b
		end)
		expect(isEqual).toEqual(true)
	end)

	local deserialized
	it("should deserialize.", function()
		deserialized = Bufferize.deserializeInstance(decoded)
		expect(typeof(deserialized)).toEqual("Instance")
	end)
end)
