local DataTypes = require(script.Parent.Parent.DataTypes)
local pointerUserdata = DataTypes.Userdata.DeduplicationPointer

local DeduplicatorSerializer = {}

local function getUniqueTblsArray(rootTbl: { [any]: any })
	local i = 1
	local uniqueArr = { rootTbl }

	local visited = {}
	local inArray = { [rootTbl] = true }

	while uniqueArr[i] do
		visited[uniqueArr[i]] = true

		for key, value in uniqueArr[i] do
			if typeof(key) == "table" and not inArray[key] then
				inArray[key] = true
				table.insert(uniqueArr, key)
			end
			if typeof(value) == "table" and not inArray[value] then
				inArray[value] = true
				table.insert(uniqueArr, value)
			end
		end

		while visited[uniqueArr[i + 1]] do
			i = i + 1
		end
		i = i + 1
	end

	return uniqueArr
end

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

	local uniqueTblsArr = getUniqueTblsArray(rootTbl)

	local pointerCount = 0
	local isPointerSet = {}
	local pointerIndexByTbl = {}
	for _, tbl in uniqueTblsArr do
		pointerCount = pointerCount + 1
		local pointer = { index = pointerCount }
		isPointerSet[pointer] = true
		pointerIndexByTbl[tbl] = pointer
	end

	local countByKV = {}
	local uniqueTblsArrCopy = {}
	for i, tbl in uniqueTblsArr do
		local tblCopy = {}
		for key, value in tbl do
			local newKey = key
			local pointerKey = pointerIndexByTbl[key]
			if pointerKey then
				newKey = pointerKey
			else
				countByKV[key] = (countByKV[key] or 0) + 1
			end

			local newValue = value
			local pointerValue = pointerIndexByTbl[value]
			if pointerValue then
				newValue = pointerValue
			else
				countByKV[value] = (countByKV[value] or 0) + 1
			end

			tblCopy[newKey] = newValue
		end
		uniqueTblsArrCopy[i] = tblCopy
	end

	local pointerByKV = {}
	local deduplicated = {}
	local deduplicatedCount = 0
	for kv, count in countByKV do
		if supportedSet[typeof(kv)] and count > 1 then
			deduplicatedCount = deduplicatedCount + 1
			pointerByKV[kv] = pointerUserdata:create(deduplicatedCount)
			deduplicated[deduplicatedCount] = kv
		end
	end

	for _, tblCopy in uniqueTblsArrCopy do
		for key, value in tblCopy do
			local newKey = pointerByKV[key] or key
			if isPointerSet[key] then
				newKey = uniqueTblsArrCopy[key.index]
			end

			local newValue = pointerByKV[value] or value
			if isPointerSet[value] then
				newValue = uniqueTblsArrCopy[value.index]
			end

			tblCopy[key] = nil
			tblCopy[newKey] = newValue
		end
	end

	return { deduplicated, uniqueTblsArrCopy[1] }
end

function DeduplicatorSerializer.deserialize(compressed: { { [any]: any } })
	local deduplicated = compressed[1]
	local uniqueTblsArr = getUniqueTblsArray(compressed[2])

	local pointerCount = 0
	local pointerByTbl = {}
	local pointerIndexByPointer = {}
	for _, tbl in uniqueTblsArr do
		pointerCount = pointerCount + 1
		local pointer = { index = pointerCount }
		pointerByTbl[tbl] = pointer
		pointerIndexByPointer[pointer] = pointer.index
	end

	local uniqueTblsArrCopy = {}
	for i, tbl in uniqueTblsArr do
		local tblCopy = {}
		for key, value in tbl do
			local newKey = pointerByTbl[key] or key
			if pointerUserdata:isTypeOf(key) then
				newKey = deduplicated[pointerUserdata:read(key).index]
			end

			local newValue = pointerByTbl[value] or value
			if pointerUserdata:isTypeOf(value) then
				newValue = deduplicated[pointerUserdata:read(value).index]
			end

			tblCopy[newKey] = newValue
		end
		uniqueTblsArrCopy[i] = tblCopy
	end

	for _, tblCopy in uniqueTblsArrCopy do
		for key, value in tblCopy do
			local newKey = uniqueTblsArrCopy[pointerIndexByPointer[key]] or key
			local newValue = uniqueTblsArrCopy[pointerIndexByPointer[value]] or value
			tblCopy[key] = nil
			tblCopy[newKey] = newValue
		end
	end

	return uniqueTblsArrCopy[1]
end

return DeduplicatorSerializer
