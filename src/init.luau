local Encoder = require(script.Encoder)
local BufferStream = require(script.BufferStream)

local Deduplicator = require(script.Serializers.Deduplicator)
local InstanceSerializer = require(script.Serializers.InstanceSerializer)

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

Bufferize.deduplicateTypeof = Deduplicator.serializeTypeof
Bufferize.deduplicate = Deduplicator.serialize
Bufferize.reduplicate = Deduplicator.deserialize

Bufferize.serializeInstance = InstanceSerializer.serialize
Bufferize.deserializeInstance = InstanceSerializer.deserialize

function Bufferize.encode(...: Supported)
	return defaultEncoder:encode(...)
end

function Bufferize.decode(b: buffer)
	return defaultEncoder:decode(b)
end

return Bufferize
