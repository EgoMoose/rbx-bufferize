local dataTypesRoot = script.Parent
local BufferStream = require(dataTypesRoot.Parent.BufferStream)

local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)
local UserdataDefinition = require(dataTypesRoot.Standalone.Userdata.UserdataDefinition)

local DataTypePackerStatic = {}

local DataTypePackerClass = {}
DataTypePackerClass.__index = DataTypePackerClass
DataTypePackerClass.ClassName = "DataTypePacker"

export type DataTypeDefinition<T> = DataTypeDefinition.DataTypeDefinition<T>

export type DataTypePacker = typeof(setmetatable(
	{} :: {
		definitionsByTypeOf: { [string]: DataTypeDefinition<any> },
		definitionsByTypeId: { [number]: DataTypeDefinition<any> },
	},
	DataTypePackerClass
))

function DataTypePackerStatic.new(inputs: { DataTypeDefinition<any> | DataTypePacker })
	local self = setmetatable({}, DataTypePackerClass) :: DataTypePacker

	self.definitionsByTypeOf = {}
	self.definitionsByTypeId = {}

	local definitions: { DataTypeDefinition<any> } = {}
	for _, input in inputs do
		local className: string? = if typeof(input) == "table" then input.ClassName else nil
		if className == "DataTypeDefinition" then
			table.insert(definitions, input :: DataTypeDefinition<any>)
		elseif className == "DataTypePacker" then
			local packer = input :: DataTypePacker
			for _, definition in packer.definitionsByTypeOf do
				table.insert(definitions, definition :: DataTypeDefinition.DataTypeDefinition<any>)
			end
		end
	end

	for _, definition in definitions do
		local typeOf = definition.typeOf
		assert(not self.definitionsByTypeOf[typeOf], `Overlapping TypeName for '{typeOf}'`)
		self.definitionsByTypeOf[typeOf] = definition :: any

		local typeId = definition.typeId
		assert(not self.definitionsByTypeId[typeId], `Overlapping TypeId for '{typeId}'.`)
		self.definitionsByTypeId[typeId] = definition :: any
	end

	return self
end

function DataTypePackerStatic.packModules(instances: { Instance })
	local inputs = {}
	for _, instance in instances do
		if instance:IsA("ModuleScript") and instance.Name:sub(-5) ~= ".spec" then
			table.insert(inputs, require(instance) :: any)
		end
	end
	return DataTypePackerStatic.new(inputs)
end

-- Methods

function DataTypePackerClass.readStream(self: DataTypePacker, stream: BufferStream.BufferStream)
	local prevCursor = stream.cursor
	local typeId = stream:readTypeId()
	stream.cursor = prevCursor
	local definition = assert(self.definitionsByTypeId[typeId], `No type definition exists for typeId '{typeId}'.`)
	return definition:readStream(stream)
end

function DataTypePackerClass.writeStream(self: DataTypePacker, stream: BufferStream.BufferStream, value: any)
	local typeofValue = typeof(value)
	if typeofValue == "userdata" then
		local subTypeOf = UserdataDefinition.subTypeOf(value)
		if subTypeOf then
			typeofValue = "userdata:" .. subTypeOf
		end
	end

	local definition =
		assert(self.definitionsByTypeOf[typeofValue], `No type definition exists for type '{typeofValue}'.`)
	definition:writeStream(stream, value)
end

return DataTypePackerStatic
