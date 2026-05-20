--[=[
	@class Bufferize

	Bufferize losslessly encodes and decodes Roblox data types into
	[`buffer`](https://create.roblox.com/docs/reference/engine/libraries/buffer)
	objects.

	The module exposes a default encoder via the top-level `encode` / `decode`
	functions, along with helpers for serializing instances and deduplicating
	repeated values inside a table. For per-type encoding overrides, create a
	dedicated [Encoder] with [Bufferize.custom].

	```lua
	local b = Bufferize.encode("Hello world!", 123, true, { foo = "bar" })
	print(Bufferize.decode(b)) -- "Hello world!", 123, true, { foo = "bar" }
	```
]=]

local Encoder = require(script.Encoder)

local Deduplicator = require(script.Serializers.Deduplicator)
local InstanceSerializer = require(script.Serializers.InstanceSerializer)

export type Encoder = Encoder.Encoder
export type Supported = Encoder.Supported
export type Overridable = Encoder.Overridable

local Bufferize = {}
local defaultEncoder = Encoder.new()

--[=[
	@within Bufferize
	@prop VERSION string
	@tag Versioning

	The semantic version string of the running Bufferize module. This is the
	same value that gets written into the header of every buffer produced by
	`encode`. See the [versioning guide](/docs/versioning) for compatibility
	rules.
]=]
Bufferize.VERSION = Encoder.VERSION

--[=[
	@within Bufferize
	@function readVersion
	@tag Versioning
	@param b buffer -- A buffer previously produced by `Bufferize.encode`.
	@return string? -- The semantic version string written into the header, or `nil` if it could not be parsed.

	Inspects the version that was written into a buffer's header without
	attempting to decode the body. Useful for migration code that needs to
	branch on the producing version before decoding.
]=]
Bufferize.readVersion = Encoder.readVersion

--[=[
	@within Bufferize
	@function custom
	@return Encoder -- A new encoder with no overrides registered.

	Creates a new [Encoder] that you can configure with custom read/write
	functions for individual data types via [Encoder:override]. The returned
	encoder is independent of the module-level `encode` / `decode` functions —
	you must use the same encoder for both halves of a round-trip.

	See the [custom encoding guide](/docs/custom-encoding) for examples.
]=]
Bufferize.custom = Encoder.new

--[=[
	@within Bufferize
	@function deduplicateTypeof
	@tag Deduplication
	@param typeOfsSet { [string]: boolean } -- Set of type names (e.g. `"string"`, `"CFrame"`) to consider for deduplication.
	@param rootTbl { [any]: any } -- The table to deduplicate.
	@return { { [any]: any } } -- A `{ deduplicated, root }` pair to pass to `encode`.

	Scans `rootTbl` for keys and values whose `typeof` is in `typeOfsSet` and
	that appear more than once, and replaces each duplicate with a pointer to a
	single shared entry. Use this when you don't know up front which specific
	values are duplicated.

	The returned table can be passed directly to `Bufferize.encode`. After
	decoding, use [Bufferize.reduplicate] to expand the pointers back into the
	original values.

	See the [deduplication guide](/docs/deduplication) for usage examples.
]=]
Bufferize.deduplicateTypeof = Deduplicator.serializeTypeof

--[=[
	@within Bufferize
	@function deduplicate
	@tag Deduplication
	@param supportedSet { [any]: boolean } -- Set of exact values that should be deduplicated.
	@param rootTbl { [any]: any } -- The table to deduplicate.
	@return { { [any]: any } } -- A `{ deduplicated, root }` pair to pass to `encode`.

	Replaces every occurrence of each value in `supportedSet` (as a key or as a
	value) with a pointer into a shared array of deduplicated values. Use this
	when you know exactly which values you want to collapse.

	The returned table can be passed directly to `Bufferize.encode`. After
	decoding, use [Bufferize.reduplicate] to expand the pointers back into the
	original values.
]=]
Bufferize.deduplicate = Deduplicator.serialize

--[=[
	@within Bufferize
	@function reduplicate
	@tag Deduplication
	@param compressed { { [any]: any } } -- A table previously produced by `deduplicate` / `deduplicateTypeof`, after a round-trip through `encode` / `decode`.
	@return { [any]: any } -- The expanded table with deduplication pointers replaced by their original values.

	Reverses [Bufferize.deduplicate] / [Bufferize.deduplicateTypeof], producing
	a plain table you can use exactly as you would have used the input to the
	deduplication call.
]=]
Bufferize.reduplicate = Deduplicator.deserialize

--[=[
	@within Bufferize
	@function serializeInstance
	@tag Instances
	@param rootInstance Instance -- The root of the instance tree to serialize.
	@return { any } -- A plain table representation that can be passed to `encode`.

	Walks `rootInstance` and all of its descendants and produces a table that
	captures each instance's `ClassName`, non-default writable properties,
	attributes, and tags. References between instances within the tree are
	preserved; references to instances outside the tree are dropped.

	See the [instances guide](/docs/instances) for the full set of rules and
	examples.
]=]
Bufferize.serializeInstance = InstanceSerializer.serialize

--[=[
	@within Bufferize
	@function deserializeInstance
	@tag Instances
	@param serializedArr { any } -- A table previously produced by `serializeInstance`, after a round-trip through `encode` / `decode`.
	@return Instance -- The reconstructed root instance, with all descendants parented underneath.

	Recreates the instance tree captured by [Bufferize.serializeInstance].
	Properties, attributes, tags, and intra-tree references are restored on the
	new instances.
]=]
Bufferize.deserializeInstance = InstanceSerializer.deserialize

--[=[
	@within Bufferize
	@param ... Supported -- One or more values of supported data types.
	@return buffer -- A buffer that round-trips through `Bufferize.decode` to the same values.

	Encodes the given values into a buffer using the module-level default
	encoder. The buffer is prefixed with the running Bufferize version so that
	`decode` can refuse to read data produced by an incompatible version.

	Tables are walked recursively; shared sub-tables are preserved as shared
	references in the decoded output.
]=]
function Bufferize.encode(...: Supported)
	return defaultEncoder:encode(...)
end

--[=[
	@within Bufferize
	@param b buffer -- A buffer previously produced by `Bufferize.encode`.
	@return ...Supported -- The original values, in the same order they were passed to `encode`.

	Decodes a buffer produced by `Bufferize.encode`. Raises an error if the
	buffer was encoded with an incompatible major version, or with a newer
	version of Bufferize than the one currently loaded.
]=]
function Bufferize.decode(b: buffer)
	return defaultEncoder:decode(b)
end

return Bufferize
