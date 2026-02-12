local bufferizeRoot = script.Parent.Parent
local DataTypes = require(bufferizeRoot.DataTypes)
local TableHelper = require(bufferizeRoot.DataTypes.Helpers.TableHelper)
local pointerUserdata = DataTypes.Userdata.DeduplicationPointer

local Deduplicator = {}

function Deduplicator.serialize(supportedSet: { [any]: boolean }, rootTbl: { [any]: any }): { { [any]: any } }
	if not next(supportedSet) then
		return { {}, rootTbl }
	end
	local pointerByKV = {}
	local deduplicatedArr = {}
	local deduplicatedCount = 0
	for kv, _ in supportedSet do
		deduplicatedCount = deduplicatedCount + 1
		deduplicatedArr[deduplicatedCount] = kv
		pointerByKV[kv] = pointerUserdata:create(deduplicatedCount)
	end

	local rootTblCopy = TableHelper.copyDeep(rootTbl, function(kv)
		return pointerByKV[kv] or kv
	end)

	return { deduplicatedArr, rootTblCopy }
end

function Deduplicator.serializeTypeof(typeOfs: { string }, rootTbl: { [any]: any }): { { [any]: any } }
	if not next(typeOfs) then
		return Deduplicator.serialize({}, rootTbl)
	end

	local typeOfsSet = {}
	for _, typeOf in typeOfs do
		typeOfsSet[typeOf] = true
	end

	local countByKV = {}
	TableHelper.replaceKV(rootTbl, function(kv)
		countByKV[kv] = (countByKV[kv] or 0) + 1
		return kv
	end)

	local supportedSet = {}
	for kv, count in countByKV do
		if typeOfsSet[typeof(kv)] and count > 1 then
			supportedSet[kv] = true
		end
	end

	return Deduplicator.serialize(supportedSet, rootTbl)
end

function Deduplicator.deserialize(compressed: { { [any]: any } })
	local deduplicatedArr = compressed[1]
	return TableHelper.copyDeep(compressed[2], function(kv)
		if pointerUserdata:isTypeOf(kv) then
			return deduplicatedArr[pointerUserdata:read(kv).index]
		end
		return kv
	end)
end

return Deduplicator
