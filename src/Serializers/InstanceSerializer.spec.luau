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

createTestInstance(function()
	local root = Instance.new("Model")
	root:AddTag("TagA")
	local partA = Instance.new("Part", root)
	partA:AddTag("TagB")
	local partB = Instance.new("WedgePart", root)
	partB.Size = Vector3.new(math.pi, 10, 1000.78)
	local valPointer = Instance.new("ObjectValue", partB)
	valPointer:AddTag("TagB")
	valPointer.Parent = partA
	return root
end)

createTestInstance(function()
	local root = Instance.new("Model")
	root:AddTag("TagA")
	local partA = Instance.new("Part", root)
	partA:AddTag("TagB")
	local partB = Instance.new("WedgePart", root)
	partB.Size = Vector3.new(math.pi, 10, 1000.78)
	partB:SetAttribute("AnInstance", partA)
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

-- INSTANCE ATTRIBUTE TESTS

local function roundTrip(instance: Instance)
	local serialized = Bufferize.serializeInstance(instance)
	return Bufferize.deserializeInstance(Bufferize.decode(Bufferize.encode(serialized))), serialized
end

local function getAttributeInstance(instance: Instance, name: string): Instance?
	local handle = instance:GetAttribute(name) :: any
	return if handle then handle:Get() else nil
end

local function createAttributeTestRoot()
	local root = Instance.new("Model")
	local partA = Instance.new("Part")
	partA.Name = "A"
	partA.Parent = root
	local partB = Instance.new("Part")
	partB.Name = "B"
	partB.Parent = root
	return root, partA, partB
end

it("should preserve instance attributes referencing earlier instances.", function()
	local root, partA, partB = createAttributeTestRoot()
	partB:SetAttribute("Ref", partA)

	local deserialized = roundTrip(root) :: any
	expect(getAttributeInstance(deserialized.B, "Ref")).toBe(deserialized.A)
end)

it("should preserve instance attributes referencing later instances.", function()
	local root, partA, partB = createAttributeTestRoot()
	partA:SetAttribute("Ref", partB)

	local deserialized: any, serialized = roundTrip(root)
	expect(getAttributeInstance(deserialized.A, "Ref")).toBe(deserialized.B)

	-- every instance should be serialized exactly once with no gaps in the array
	local count = 0
	for _ in serialized do
		count = count + 1
	end
	expect(count).toBe(3)
	expect(#serialized).toBe(3)
end)

it("should preserve instance attributes on the root.", function()
	local root, partA = createAttributeTestRoot()
	root:SetAttribute("Ref", partA)

	local deserialized = roundTrip(root) :: any
	expect(getAttributeInstance(deserialized, "Ref")).toBe(deserialized.A)
end)

it("should preserve instance attributes referencing the root.", function()
	local root, partA = createAttributeTestRoot()
	partA:SetAttribute("Ref", root)

	local deserialized = roundTrip(root) :: any
	expect(getAttributeInstance(deserialized.A, "Ref")).toBe(deserialized)
end)

it("should preserve instance attributes referencing themselves.", function()
	local root, partA = createAttributeTestRoot()
	partA:SetAttribute("Ref", partA)

	local deserialized = roundTrip(root) :: any
	expect(getAttributeInstance(deserialized.A, "Ref")).toBe(deserialized.A)
end)

it("should drop instance attributes referencing instances outside the root.", function()
	local root, partA = createAttributeTestRoot()
	local outside = Instance.new("Part")
	partA:SetAttribute("Ref", outside)
	partA:SetAttribute("Other", 5)

	local deserialized = roundTrip(root) :: any
	expect(deserialized.A:GetAttribute("Ref")).toBeNil()
	expect(deserialized.A:GetAttribute("Other")).toBe(5)
	outside:Destroy()
end)
