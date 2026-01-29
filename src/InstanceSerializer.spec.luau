local ReflectionService = game:GetService("ReflectionService") :: ReflectionService
local InstanceSerializer = require(script.Parent.InstanceSerializer)

local TestHelper = require(game.ReplicatedStorage.DevPackages.TestHelper)

local function addUniques(instance: Instance)
	local descendants = instance:GetDescendants()
	table.insert(descendants, instance)
	for i, descendant in descendants do
		descendant:SetAttribute("__unique", i)
	end
	return instance
end

local function instanceTreesEqual(instanceA: Instance, instanceB: Instance)
	local uniqueMap = {}
	local descendantsB = instanceB:GetDescendants()
	table.insert(descendantsB, instanceB)
	for i, descendant in descendantsB do
		uniqueMap[descendant:GetAttribute("__unique") :: number] = descendant
	end

	local stack = { {
		a = instanceA,
		b = instanceB,
	} }

	while #stack > 0 do
		local popped = table.remove(stack) :: typeof(assert(table.remove(stack)))

		local properties = ReflectionService:GetPropertiesOfClass(popped.a.ClassName, {
			Security = SecurityCapabilities.fromCurrent(),
			ExcludeInherited = false,
			ExcludeDisplay = false,
		})

		for _, property in properties do
			if InstanceSerializer.shouldSerializeProperty(property) then
				local valueA, valueB
				local success = pcall(function()
					valueA = (popped.a :: any)[property.Name]
					valueB = (popped.b :: any)[property.Name]
				end)

				if not success then
					return false
				end

				local typeofA = typeof(valueA)
				if typeofA == "Instance" and typeof(valueB) == "Instance" then
					local unique = assert(valueA:GetAttribute("__unique") :: number?)
					local matched = assert(uniqueMap[unique])
					if valueB ~= matched then
						return false
					end
				elseif typeofA == "Instance" then
					continue
				elseif valueA ~= valueB then
					return false
				end
			end
		end

		for _, child in popped.a:GetChildren() do
			local unique = assert(child:GetAttribute("__unique") :: number?)
			local matched = assert(uniqueMap[unique])

			table.insert(stack, {
				a = child,
				b = matched,
			})
		end
	end

	return true
end

local testInstances = {}
local function createTestInstance(callback: () -> Instance)
	local instance = callback()
	addUniques(instance)
	table.insert(testInstances, instance)
end

-- INSTANCE TESTS

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

TestHelper.instances({
	values = table.pack(table.unpack(testInstances)),
	compare = instanceTreesEqual,
})
