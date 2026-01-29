local dataTypesRoot = script:FindFirstAncestor("DataTypes")
local DataTypeDefinition = require(dataTypesRoot.DataTypeDefinition)

local number_nan = 1
local number_huge = 2
local number_int = 3
local number_f64 = 4

return DataTypeDefinition.new("number", {
	read = DataTypeDefinition.createReader({
		[number_nan] = function(_stream)
			return 0 / 0
		end,
		[number_huge] = function(stream)
			return math.huge * stream:readi8()
		end,
		[number_int] = function(stream)
			local signedBytes = stream:readi8()
			local bytes = math.abs(signedBytes)
			local sign = if signedBytes < 0 then -1 else 1
			return stream:readUnsignedBytes(bytes) * sign
		end,
		[number_f64] = function(stream)
			return stream:readf64()
		end,
	}),
	write = function(stream, num)
		if num ~= num then
			stream:writeu8(number_nan)
		else
			local abs = math.abs(num)
			if abs == math.huge then
				stream:writeu8(number_huge)
				stream:writei8(if num < 0 then -1 else 1)
			elseif num % 1 == 0 and abs <= 0xFFFFFFFF then
				stream:writeu8(number_int)

				local bytes = 4
				if abs <= 0xFF then
					bytes = 1
				elseif abs <= 0xFFFF then
					bytes = 2
				end

				stream:writei8(if num < 0 then -bytes else bytes)
				stream:writeUnsignedBytes(bytes, abs)
			else
				stream:writeu8(number_f64)
				stream:writef64(num)
			end
		end
	end,
})
