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
		typing: string,
		definition: Definition<T>,
		overridable: boolean,
		support: "implemented" | "unimplemented" | "never",
	},
	DataTypeDefinitionClass
))

function DataTypeDefinitionStatic.new<T>(typeOf: string, definition: Definition<T>)
	local self = setmetatable({}, DataTypeDefinitionClass) :: DataTypeDefinition<T>

	self.typeId = TypeIds.assert(typeOf)
	self.typeOf = typeOf
	self.typing = typeOf
	self.definition = table.clone(definition)
	self.overridable = true
	self.support = "implemented"

	return self
end

function DataTypeDefinitionStatic.unimplemented(typeOf: string)
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
	definition.support = "unimplemented"

	return definition
end

function DataTypeDefinitionStatic.never(typeOf: string)
	local definition = DataTypeDefinitionStatic.unimplemented(typeOf)
	definition.support = "never"
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
	local typeId = BufferStream.readTypeId(stream)
	assert(typeId == self.typeId, "TypeId does not match.")
	return self.definition.read(stream)
end

function DataTypeDefinitionClass.writeStream<T>(self: DataTypeDefinition<T>, stream: BufferStream, value: T)
	BufferStream.writeTypeId(stream, self.typeId)
	self.definition.write(stream, value)
end

-- raw reads / writes skip the typeId and operate directly on a buffer at an offset

function DataTypeDefinitionClass.readRaw<T>(self: DataTypeDefinition<T>, b: buffer, offset: number): (T, number)
	local stream = BufferStream.static(b)
	assert(offset >= 0 and offset <= stream:getLength(), `Offset '{offset}' is out of bounds.`)
	stream:setCursor(offset)
	local value = self.definition.read(stream)
	return value, stream:getCursor()
end

function DataTypeDefinitionClass.writeRaw<T>(self: DataTypeDefinition<T>, b: buffer, offset: number, value: T)
	assert(offset >= 0, `Offset '{offset}' is out of bounds.`)
	local stream = BufferStream.dynamic(b)
	local length = stream:getLength()
	if offset > length then
		stream:expand(offset - length)
	end
	stream:setCursor(offset)
	self.definition.write(stream, value)
	return stream.buffer, stream:getCursor()
end

return DataTypeDefinitionStatic
