local dataTypesRoot = script.Parent
local TypeIds = require(dataTypesRoot.TypeIds)
local BufferStream = require(dataTypesRoot.Parent.BufferStream)

local DataTypeDefinitionStatic = {}

local DataTypeDefinitionClass = {}
DataTypeDefinitionClass.__index = DataTypeDefinitionClass
DataTypeDefinitionClass.ClassName = "DataTypeDefinition"

export type BufferStream = BufferStream.BufferStream

type Definition<T> = {
	write: (BufferStream, T) -> (),
	read: (BufferStream) -> T,
}

export type DataTypeDefinition<T> = typeof(setmetatable(
	{} :: {
		typeId: number,
		typeOf: string,
		definition: Definition<T>,
		overridable: boolean,
		unimplemented: boolean,
	},
	DataTypeDefinitionClass
))

function DataTypeDefinitionStatic.new<T>(typeOf: string, definition: Definition<T>)
	local self = setmetatable({}, DataTypeDefinitionClass) :: DataTypeDefinition<T>

	self.typeId = TypeIds.assert(typeOf)
	self.typeOf = typeOf
	self.definition = table.clone(definition)
	self.overridable = true
	self.unimplemented = false

	return self
end

function DataTypeDefinitionStatic.unsupported(typeOf: string)
	local definition = DataTypeDefinitionStatic.new(typeOf, {
		read = function(_stream)
			error(`Reading the '{typeOf}' type is not supported.`)
			return nil :: any
		end,
		write = function(_stream, _value)
			error(`Writing the '{typeOf}' type is not supported.`)
		end,
	})

	definition.overridable = false
	definition.unimplemented = true

	return definition
end

function DataTypeDefinitionStatic.createReader<T...>(readsById: { [number]: (BufferStream) -> T... })
	return function(stream: BufferStream)
		local readId = stream:readu8()
		return readsById[readId](stream)
	end
end

function DataTypeDefinitionClass.isOverridable<T>(self: DataTypeDefinition<T>)
	return self.overridable
end

function DataTypeDefinitionClass.readStream<T>(self: DataTypeDefinition<T>, stream: BufferStream)
	local typeId = stream:readTypeId()
	assert(typeId == self.typeId, "TypeId does not match.")
	return self.definition.read(stream)
end

function DataTypeDefinitionClass.writeStream<T>(self: DataTypeDefinition<T>, stream: BufferStream, value: T)
	stream:writeTypeId(self.typeId)
	self.definition.write(stream, value)
end

return DataTypeDefinitionStatic
