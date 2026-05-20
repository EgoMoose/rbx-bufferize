local packagesRoot = script.Parent.Parent
local CargoSemver = require(packagesRoot.CargoSemver)

local Wally = require(script.Parent.Wally)
local DataTypes = require(script.Parent.DataTypes)
local BufferStream = require(script.Parent.BufferStream)

export type Supported = DataTypes.Supported
export type Overridable = DataTypes.Overridable

type CopyStackEntry<T> = {
	original: T,
	copy: T,
}

type CustomEncoder<T> = {
	read: (buffer) -> T,
	write: (T) -> buffer,
}

local function getWallySemVer()
	local parsed = CargoSemver.Version.parse(Wally.package.version)

	local ver = CargoSemver.Version.new(
		parsed.major,
		parsed.minor,
		parsed.patch,
		CargoSemver.Prerelease.EMPTY,
		CargoSemver.BuildMetadata.EMPTY
	)

	local majorVer =
		CargoSemver.Version.new(parsed.major, 0, 0, CargoSemver.Prerelease.EMPTY, CargoSemver.BuildMetadata.EMPTY)

	local nextMajorVer = CargoSemver.Version.new(
		parsed.major + 1,
		parsed.minor,
		parsed.patch,
		CargoSemver.Prerelease.EMPTY,
		CargoSemver.BuildMetadata.EMPTY
	)

	local length = #tostring(ver)
	assert(length <= 255, "Wally version cannot exceed 255 characters.")
	local stream = BufferStream.dynamic(buffer.create(0))
	stream:writeu8(length)
	stream:writeString(tostring(ver), length)

	return {
		ver = ver,
		majorVer = majorVer,
		nextMajorVer = nextMajorVer,
		header = stream.buffer,
	}
end

local WALLY_SEMVER = getWallySemVer()

local function encodeInternal(rootTbl: { [any]: any }, encoders: { [string]: CustomEncoder<any> })
	if next(encoders) then
		local stack = {} :: { CopyStackEntry<any> }

		local pointerCount = 0
		local pointersByOriginal = {}
		local copiesByPointerIndex = {}

		local function stackCopyTbl(tbl: { [any]: any })
			local copy: { [any]: any } = {}
			pointerCount = pointerCount + 1
			pointersByOriginal[tbl] = pointerCount
			copiesByPointerIndex[pointerCount] = copy
			table.insert(stack, {
				original = tbl,
				copy = copy,
			})
			return copy
		end

		local rootTblCopy = stackCopyTbl(rootTbl)
		while #stack > 0 do
			local popped = table.remove(stack) :: CopyStackEntry<any>
			for key, value in popped.original do
				local newKey = key
				local typeofKey = typeof(key)
				if typeofKey == "table" then
					local pointerIndex = pointersByOriginal[key]
					newKey = copiesByPointerIndex[pointerIndex] or stackCopyTbl(key)
				else
					local encoder = encoders[typeofKey]
					if encoder then
						newKey = DataTypes.Userdata.Userdefined:create(typeofKey, encoder.write(key))
					end
				end

				local newValue = value
				local typeofValue = typeof(value)
				if typeofValue == "table" then
					local pointerIndex = pointersByOriginal[value]
					newValue = copiesByPointerIndex[pointerIndex] or stackCopyTbl(value)
				else
					local encoder = encoders[typeofValue]
					if encoder then
						newValue = DataTypes.Userdata.Userdefined:create(typeofValue, encoder.write(value))
					end
				end

				popped.copy[newKey] = newValue
			end
		end

		rootTbl = rootTblCopy
	end

	local stream = BufferStream.dynamic(buffer.create(0))
	stream:writeBuffer(WALLY_SEMVER.header)
	DataTypes.Encoder:writeStream(stream, rootTbl)
	return stream.buffer
end

local function decodeInternal(b: buffer, encoders: { [string]: CustomEncoder<any> })
	local stream = BufferStream.static(b)
	local length = stream:readu8()
	local wallyVersion = stream:readString(length)

	local headerVer = assert(CargoSemver.Version.parse(wallyVersion), "Failed to read header version.")
	assert(
		headerVer >= WALLY_SEMVER.majorVer and headerVer < WALLY_SEMVER.nextMajorVer,
		`Attempted to decode a buffer encoded with a different major version '{headerVer}'.`
	)

	assert(
		headerVer <= WALLY_SEMVER.ver,
		`Attempted to decode a buffer encoded with a newer version of Bufferize '{headerVer}'.`
	)

	-- also don't want the version to be greater than WALLY_SEMVER.ver

	local rootTbl = DataTypes.Encoder:readStream(stream)

	if next(encoders) then
		local stack = { rootTbl }
		while #stack > 0 do
			local popped = table.remove(stack) :: { [any]: any }
			for key, value in popped do
				local newKey = key
				if typeof(key) == "table" then
					table.insert(stack, key)
				elseif DataTypes.Userdata.Userdefined:isTypeOf(key) then
					local userdefined = DataTypes.Userdata.Userdefined:read(key)
					local encoder = encoders[userdefined.kind]
					if encoder then
						newKey = encoder.read(userdefined.b)
					end
				end

				local newValue = value
				if typeof(value) == "table" then
					table.insert(stack, value)
				elseif DataTypes.Userdata.Userdefined:isTypeOf(value) then
					local userdefined = DataTypes.Userdata.Userdefined:read(value)
					local encoder = encoders[userdefined.kind]
					if encoder then
						newValue = encoder.read(userdefined.b)
					end
				end

				popped[key] = nil
				popped[newKey] = newValue
			end
		end
	end

	return rootTbl
end

-- Class

--[=[
	@class Encoder

	An `Encoder` is an isolated encode/decode context. Each instance carries
	its own table of custom per-type encoders, so two encoders configured
	differently can co-exist without interfering with each other or with the
	module-level [Bufferize.encode] / [Bufferize.decode] functions.

	Create one with [Bufferize.custom]\:

	```lua
	local myEncoder = Bufferize.custom()
	myEncoder:override("Color3", { read = ..., write = ... })

	local b = myEncoder:encode(Color3.new(1, 0, 0))
	local color = myEncoder:decode(b)
	```

	A buffer produced by an `Encoder` with overrides can only be decoded by an
	encoder configured with the same overrides — there is no way to recover the
	override information from the buffer alone.
]=]
local EncoderStatic = {}

--[=[
	@within Encoder
	@prop VERSION string

	The semantic version string of the running Bufferize module. Mirrors
	[Bufferize.VERSION].
]=]
EncoderStatic.VERSION = tostring(WALLY_SEMVER.ver)

local EncoderClass = {}
EncoderClass.__index = EncoderClass
EncoderClass.ClassName = "Encoder"

export type Encoder = typeof(setmetatable(
	{} :: {
		encoders: { [string]: CustomEncoder<any> },
	},
	EncoderClass
))

--[=[
	@within Encoder
	@function new
	@return Encoder

	Creates a new encoder with no overrides registered. Prefer calling this via
	[Bufferize.custom] for clarity at the call site.
]=]
function EncoderStatic.new()
	local self = setmetatable({}, EncoderClass) :: Encoder

	self.encoders = {}

	return self
end

--[=[
	@within Encoder
	@function readVersion
	@param b buffer -- A buffer previously produced by an encoder's `encode` method.
	@return string? -- The semantic version string written into the header, or `nil` if it could not be parsed.

	Reads the Bufferize version stored in the buffer's header without decoding
	the body. See [Bufferize.readVersion].
]=]
function EncoderStatic.readVersion(b: buffer)
	local stream = BufferStream.static(b)
	local length = stream:readu8()
	local wallyVersion = stream:readString(length)
	local ver = CargoSemver.Version.parse(wallyVersion)
	return if ver then tostring(ver) else nil
end

--[=[
	@within Encoder
	@method override
	@param typeOf string -- The `typeof` name of the data type to override (e.g. `"CFrame"`, `"Color3"`).
	@param encoder { read: (buffer) -> T, write: (T) -> buffer } -- A pair of conversion functions between the data type and a `buffer`.

	Registers a custom read/write pair for the given data type on this encoder.
	The same override must be present on whichever encoder decodes the buffer
	later — there is no way to recover it from the buffer itself.

	Attempting to override a type that is not overridable raises an error.
]=]
function EncoderClass.override<T>(self: Encoder, typeOf: string, encoder: CustomEncoder<T>)
	local definition = DataTypes.Encoder.definitionsByTypeOf[typeOf]
	if definition then
		assert(definition:isOverridable(), `Cannot override encoding for the '{typeOf}' type.`)
	end
	self.encoders[typeOf] = encoder
end

--[=[
	@within Encoder
	@method encode
	@param ... Supported -- One or more values of supported data types.
	@return buffer -- A buffer that round-trips through this encoder's `decode` to the same values.

	Encodes the given values into a buffer, applying any overrides registered
	via [Encoder:override]. The buffer is prefixed with the running Bufferize
	version.
]=]
function EncoderClass.encode(self: Encoder, ...: Supported)
	-- we always wrap our inputs in a table b/c it will ensure
	-- pointers are being used for duplicated tables
	local packed = table.pack(...)

	local hasGap = false
	for i = 1, packed.n do
		if packed[i] == nil then
			hasGap = true
			break
		end
	end

	if not hasGap then
		local packedAny = packed :: any
		packedAny.n = nil
	end

	return encodeInternal(packed, self.encoders)
end

--[=[
	@within Encoder
	@method decode
	@param b buffer -- A buffer previously produced by this encoder (or one with the same overrides).
	@return ...Supported -- The original values, in the same order they were passed to `encode`.

	Decodes a buffer produced by `encode`. Raises an error if the buffer was
	encoded with an incompatible major version, or with a newer version of
	Bufferize than the one currently loaded.
]=]
function EncoderClass.decode(self: Encoder, b: buffer)
	local packed = decodeInternal(b, self.encoders)
	local packedN = packed.n or #packed
	return table.unpack(packed, 1, packedN)
end

--

return EncoderStatic
