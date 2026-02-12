local bufferizeRoot = script.Parent.Parent
local DataTypes = require(bufferizeRoot.DataTypes)
local TableHelper = require(bufferizeRoot.DataTypes.Helpers.TableHelper)
local pointerUserdata = DataTypes.Userdata.DeduplicationPointer

local DeduplicatorSerializer = {}

function DeduplicatorSerializer.serialize(supportedDataTypes: { string }, rootTbl: { [any]: any }): { { [any]: any } }
	local supportedSet = {}
	for _, typeOf in supportedDataTypes do
		if typeOf ~= "table" then
			supportedSet[typeOf] = true
		end
	end

	if not next(supportedSet) then
		return { {}, rootTbl }
	end

	local countByKV = {}
	TableHelper.replaceKV(rootTbl, function(kv)
		countByKV[kv] = (countByKV[kv] or 0) + 1
		return kv
	end)

	local pointerByKV = {}
	local deduplicatedArr = {}
	local deduplicatedCount = 0
	for kv, count in countByKV do
		if supportedSet[typeof(kv)] and count > 1 then
			deduplicatedCount = deduplicatedCount + 1
			deduplicatedArr[deduplicatedCount] = kv
			pointerByKV[kv] = pointerUserdata:create(deduplicatedCount)
		end
	end

	local rootTblCopy = TableHelper.copyDeep(rootTbl, function(kv)
		return pointerByKV[kv] or kv
	end)

	return { deduplicatedArr, rootTblCopy }
end

function DeduplicatorSerializer.deserialize(compressed: { { [any]: any } })
	local deduplicatedArr = compressed[1]
	return TableHelper.copyDeep(compressed[2], function(kv)
		if pointerUserdata:isTypeOf(kv) then
			return deduplicatedArr[pointerUserdata:read(kv).index]
		end
		return kv
	end)
end

return DeduplicatorSerializer
