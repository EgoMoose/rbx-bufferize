local TableHelper = {}

-- Private

local function standardProcessKV(kv: any)
	return kv
end

local function standardCompare(a: any, b: any)
	return a == b
end

-- Public

function TableHelper.getUniqueTblsArray(rootTbl: { [any]: any })
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

function TableHelper.replaceKV(rootTbl: { [any]: any }, replaceKV: (any) -> any)
	local uniqueTblsArr = TableHelper.getUniqueTblsArray(rootTbl)

	local indexByTbl = {}
	for i, tbl in uniqueTblsArr do
		indexByTbl[tbl] = i
	end

	for i, tbl in uniqueTblsArr do
		for key, value in tbl do
			local newKey = key
			if not indexByTbl[key] then
				newKey = replaceKV(key)
			end

			local newValue = value
			if not indexByTbl[value] then
				newValue = replaceKV(value)
			end

			tbl[key] = nil
			tbl[newKey] = newValue
		end
	end
end

function TableHelper.copyDeep(rootTbl: { [any]: any }, customProcessKV: ((any) -> any)?)
	local processKV = customProcessKV or standardProcessKV

	local uniqueTblsArrCopy = {}
	local uniqueTblsArr = TableHelper.getUniqueTblsArray(rootTbl)

	local indexByTbl = {}
	for i, tbl in uniqueTblsArr do
		indexByTbl[tbl] = i
		uniqueTblsArrCopy[i] = {}
	end

	for i, tbl in uniqueTblsArr do
		local tblCopy = uniqueTblsArrCopy[i]
		for key, value in tbl do
			local newKey = uniqueTblsArrCopy[indexByTbl[key]]
			if not newKey then
				newKey = processKV(key)
			end

			local newValue = uniqueTblsArrCopy[indexByTbl[value]]
			if not newValue then
				newValue = processKV(value)
			end

			tblCopy[newKey] = newValue
		end
	end

	return uniqueTblsArrCopy[1]
end

function TableHelper.equalsDeep(
	rootTblA: { [any]: any },
	rootTblB: { [any]: any },
	customCompare: ((any, any) -> boolean)?
)
	local compare = customCompare or standardCompare

	local uniqueTblsArrA = TableHelper.getUniqueTblsArray(rootTblA)
	local uniqueTblsArrB = TableHelper.getUniqueTblsArray(rootTblB)

	local uniqueCount = #uniqueTblsArrA
	if uniqueCount ~= #uniqueTblsArrB then
		return false
	end

	local refSet = {}
	local refByTbl = {}
	for i = 1, uniqueCount do
		local ref = { index = i }
		refSet[ref] = true
		refByTbl[uniqueTblsArrA[i]] = ref
		refByTbl[uniqueTblsArrB[i]] = ref
	end

	for i, tbl in uniqueTblsArrA do
		local newTbl = {}
		for key, value in tbl do
			newTbl[refByTbl[key] or key] = refByTbl[value] or value
		end
		uniqueTblsArrA[i] = newTbl
	end

	for i, tbl in uniqueTblsArrB do
		local newTbl = {}
		for key, value in tbl do
			newTbl[refByTbl[key] or key] = refByTbl[value] or value
		end
		uniqueTblsArrB[i] = newTbl
	end

	for i = 1, uniqueCount do
		local tblA = uniqueTblsArrA[i]
		local tblB = uniqueTblsArrB[i]

		local visitedKeysSet = {}
		for keyA, valueA in tblA do
			if refSet[valueA] then
				if valueA ~= tblB[keyA] then
					return false
				end
			elseif not compare(valueA, tblB[keyA]) then
				return false
			end
			visitedKeysSet[keyA] = true
		end

		for key, value in tblB do
			if not visitedKeysSet[key] then
				return false
			end
		end
	end

	return true
end

--

return TableHelper
