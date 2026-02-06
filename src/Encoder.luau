local packagesRoot = script.Parent.Parent
local CargoSemver = require(packagesRoot.CargoSemver)

local Wally = require(script.Parent.Wally)
local DataTypes = require(script.Parent.DataTypes)
local BufferStream = require(script.Parent.BufferStream)

type CopyStackEntry<T> = {
	original: T,
	copy: T,
}

type CustomEncoder<T> = {
	read: (buffer) -> T,
	write: (T) -> buffer,
}

local function getWallySemVer()
	local ver = CargoSemver.Version.parse(Wally.package.version)
	local isSameMajor = CargoSemver.Comparator.parse(`~{ver.major}`)
	local isLessThanOrEqual = CargoSemver.Comparator.parse("<=" .. tostring(ver))

	local length = #tostring(ver)
	assert(length <= 255, "Wally version cannot exceed 255 characters.")
	local stream = BufferStream.new(buffer.create(0))
	stream:writeu8(length)
	stream:writeString(tostring(ver), length)

	return {
		ver = ver,
		header = stream.b,
		isSameMajorAsCurrent = isSameMajor,
		isLessThanOrEqualToCurrent = isLessThanOrEqual,
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

	local stream = BufferStream.new(buffer.create(0))
	stream:writeBuffer(WALLY_SEMVER.header)
	DataTypes.Encoder:writeStream(stream, rootTbl)
	return stream.b
end

local function decodeInternal(b: buffer, encoders: { [string]: CustomEncoder<any> })
	local stream = BufferStream.new(b)
	local length = stream:readu8()
	local wallyVersion = stream:readString(length)

	local ver = assert(CargoSemver.Version.parse(wallyVersion), "Failed to read header version.")
	assert(
		WALLY_SEMVER.isSameMajorAsCurrent:matches(ver),
		`Attempted to decode a buffer encoded with a different major version '{ver}'.`
	)

	assert(
		WALLY_SEMVER.isLessThanOrEqualToCurrent:matches(ver),
		`Attempted to decode a buffer encoded with a newer version of Bufferize '{ver}'.`
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

local EncoderStatic = {}
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

function EncoderStatic.new()
	local self = setmetatable({}, EncoderClass) :: Encoder

	self.encoders = {}

	return self
end

function EncoderStatic.readVersion(b: buffer)
	local stream = BufferStream.new(b)
	local length = stream:readu8()
	local wallyVersion = stream:readString(length)
	local ver = CargoSemver.Version.parse(wallyVersion)
	return if ver then tostring(ver) else nil
end

function EncoderClass.override<T>(self: Encoder, typeOf: string, encoder: CustomEncoder<T>)
	local definition = DataTypes.Encoder.definitionsByTypeOf[typeOf]
	if definition then
		assert(definition:isOverridable(), `Cannot override encoding for the '{typeOf}' type.`)
	end
	self.encoders[typeOf] = encoder
end

function EncoderClass.encode(self: Encoder, ...: any)
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

function EncoderClass.decode(self: Encoder, b: buffer)
	local packed = decodeInternal(b, self.encoders)
	local packedN = packed.n or #packed
	return table.unpack(packed, 1, packedN)
end

--

return EncoderStatic
