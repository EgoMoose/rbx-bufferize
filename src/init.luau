local Encoder = require(script.Encoder)
local BufferStream = require(script.BufferStream)
local InstanceSerializer = require(script.InstanceSerializer)

export type Encoder = Encoder.Encoder
export type BufferStream = BufferStream.BufferStream

export type Supported = Encoder.Supported
export type Overridable = Encoder.Overridable

local Bufferize = {}
local defaultEncoder = Encoder.new()

Bufferize.VERSION = Encoder.VERSION
Bufferize.readVersion = Encoder.readVersion

Bufferize.custom = Encoder.new
Bufferize.stream = BufferStream.new

Bufferize.serializeInstance = InstanceSerializer.serialize
Bufferize.deserializeInstance = InstanceSerializer.deserialize

function Bufferize.encode(...: Supported)
	return defaultEncoder:encode(...)
end

function Bufferize.decode(b: buffer)
	return defaultEncoder:decode(b)
end

return Bufferize
