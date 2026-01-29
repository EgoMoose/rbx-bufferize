local SUB_TYPE_OF_KEY = "_$_$_bufferize_typeof"

local UserdataDefinitionStatic = {}

local UserdataDefinitionClass = {}
UserdataDefinitionClass.__index = UserdataDefinitionClass
UserdataDefinitionClass.ClassName = "UserdataDefinition"

type userdata<T> = {
	["_$_$_bufferize_typeof"]: string,
	value: T,
}

type Options<T> = {
	write: () -> T,
	read: (userdata<T>) -> T,
}

export type UserdataDefinition<T, U...> = typeof(setmetatable(
	{} :: {
		subTypeOf: string,
		typeOf: string,
		write: (U...) -> T,
	},
	UserdataDefinitionClass
))

function UserdataDefinitionStatic.new<T, U...>(subTypeOf: string, write: (U...) -> T)
	local self = setmetatable({}, UserdataDefinitionClass) :: UserdataDefinition<T, U...>

	self.subTypeOf = subTypeOf
	self.typeOf = "userdata:" .. subTypeOf
	self.write = write

	return self
end

function UserdataDefinitionStatic.subTypeOf(userdata: any): string?
	local mt = typeof(userdata) == "userdata" and getmetatable(userdata)
	local mtIndex = typeof(mt) == "table" and rawget(mt, "__index")
	return typeof(mtIndex) == "table" and rawget(mtIndex :: any, SUB_TYPE_OF_KEY) or nil
end

function UserdataDefinitionClass.isTypeOf<T, U...>(self: UserdataDefinition<T, U...>, userdata: any)
	return UserdataDefinitionStatic.subTypeOf(userdata) == self.subTypeOf
end

function UserdataDefinitionClass.read<T, U...>(self: UserdataDefinition<T, U...>, userdata: userdata<T>)
	assert(typeof(userdata) == "userdata", "Cannot read non-userdata.")
	local subTypeOf = UserdataDefinitionStatic.subTypeOf(userdata)
	assert(
		subTypeOf == self.subTypeOf,
		`Attempt to read userdata typeof '{subTypeOf}' with typeof '{self.subTypeOf}' reader.`
	)
	return userdata.value :: T
end

function UserdataDefinitionClass.create<T, U...>(self: UserdataDefinition<T, U...>, ...: U...)
	local userdata = newproxy(true) :: userdata<T>
	getmetatable(userdata :: any).__index = {
		[SUB_TYPE_OF_KEY] = self.subTypeOf,
		value = self.write(...),
	}
	return userdata
end

return UserdataDefinitionStatic
