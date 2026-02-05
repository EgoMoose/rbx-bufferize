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

local function equalsDeep(rootTblA: { [any]: any }, rootTblB: { [any]: any }, compare: (any, any) -> boolean)
	local uniqueTblsArrA = getUniqueTblsArray(rootTblA)
	local uniqueTblsArrB = getUniqueTblsArray(rootTblB)

	local uniqueCount = #uniqueTblsArrA
	if uniqueCount ~= #uniqueTblsArrB then
		return false
	end

	local pointerByTbl = {}
	for i = 1, uniqueCount do
		local pointer = { index = i }
		pointerByTbl[uniqueTblsArrA[i]] = pointer
		pointerByTbl[uniqueTblsArrB[i]] = pointer
	end

	for i, tbl in uniqueTblsArrA do
		local newTbl = {}
		for key, value in tbl do
			newTbl[pointerByTbl[key] or key] = pointerByTbl[value] or value
		end
		uniqueTblsArrA[i] = newTbl
	end

	for i, tbl in uniqueTblsArrB do
		local newTbl = {}
		for key, value in tbl do
			newTbl[pointerByTbl[key] or key] = pointerByTbl[value] or value
		end
		uniqueTblsArrB[i] = newTbl
	end

	for i = 1, #uniqueTblsArrA do
		local a = uniqueTblsArrA[i]
		local b = uniqueTblsArrB[i]

		local visitedKeysSet = {}
		for key, value in a do
			if pointerByTbl[value] then
				if b[key] ~= value then
					return false
				end
			elseif not compare(b[key], value) then
				return false
			end
			visitedKeysSet[key] = true
		end

		for key, value in b do
			if not visitedKeysSet[key] then
				return false
			end
		end
	end

	return true
end

return equalsDeep
