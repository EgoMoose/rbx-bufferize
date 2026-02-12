local ReflectionService = game:GetService("ReflectionService") :: ReflectionService

local DataTypes = require(script.Parent.Parent.DataTypes)
local pointerUserdata = DataTypes.Userdata.InstancePointer

local InstanceSerializer = {}

function InstanceSerializer.shouldSerializeProperty(property: { [string]: any })
	return property.Permits
		and property.Permits.Read
		and property.Permits.Write
		and property.Display
		and not property.Display.DeprecationMessage
end

function InstanceSerializer.serialize(rootInstance: Instance)
	local serializedArr = {}

	local pointerCount = 0
	local pointerByInstance = {}
	local instanceByPointerIndex = {}

	local nilPointer = pointerUserdata:create(0)
	local function assignPointer(instance: Instance)
		pointerCount = pointerCount + 1
		pointerByInstance[instance] = pointerUserdata:create(pointerCount)
		instanceByPointerIndex[pointerCount] = instance
	end

	assignPointer(rootInstance)
	for _, descendant in rootInstance:GetDescendants() do
		assignPointer(descendant)
	end

	for pointerIndex, instance in instanceByPointerIndex do
		local className = instance.ClassName

		local instanceAny = instance :: any
		local defaultInstance = Instance.new(className)
		local defaultInstanceAny = defaultInstance :: any

		-- technically not a true array b/c mismatched types, but this will encode more efficiently
		local serialized: { any } = { className }
		local properties = ReflectionService:GetPropertiesOfClass(className, {
			Security = SecurityCapabilities.fromCurrent(),
			ExcludeInherited = false,
			ExcludeDisplay = false,
		})

		local j = 2
		for _, property in properties do
			local shouldSerialize = InstanceSerializer.shouldSerializeProperty(property)
			if shouldSerialize and not (instance == rootInstance and property.Name == "Parent") then
				local success, err = pcall(function()
					local value = instanceAny[property.Name]
					local defaultValue = defaultInstanceAny[property.Name]
					if value ~= defaultValue then
						if typeof(value) == "Instance" then
							value = pointerByInstance[value] or nilPointer
						elseif value == nil then
							value = nilPointer
						end

						serialized[j + 1] = property.Name
						serialized[j + 2] = value
						j = j + 2
					end
				end)

				if not success then
					warn(err)
				end
			end
		end

		for attributeName, attributeValue in instance:GetAttributes() do
			serialized[j + 1] = "$" .. attributeName -- use dollar sign to identify attribute keys
			serialized[j + 2] = attributeValue
			j = j + 2
		end

		defaultInstance:Destroy()

		serialized[2] = (j - 2) // 2
		serializedArr[pointerIndex] = serialized
	end

	return serializedArr
end

function InstanceSerializer.deserialize(serializedArr: { any })
	local instances = {}

	for i, serialized in serializedArr do
		local className = serialized[1]
		local keyValueCount = serialized[2] * 2

		local instance = Instance.new(className)
		local instanceAny = instance :: any

		local isAttribute = false
		for i = 1, keyValueCount, 2 do
			local key = serialized[i + 2]
			local value = serialized[i + 3]

			if pointerUserdata:isTypeOf(value) then
				local pointer = pointerUserdata:read(value)
				value = instances[pointer.index]
			end

			if isAttribute or (typeof(key) == "string" and key:sub(1, 1) == "$") then
				isAttribute = true
				instance:SetAttribute(key:sub(2), value)
			else
				instanceAny[key] = value
			end
		end

		instances[i] = instance
	end

	return instances[1]
end

return InstanceSerializer
