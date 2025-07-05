--!strict
local Types = require "../Types"

local peek = require "./peek"

local change = require "../Graph/change"

local destructor = require "../Memory/destructor"

local isSimilar = require "../Utility/isSimilar"

type Self<K, V> = Types.Table<K, V>

local class = {
	type = "Table",
	kind = "state",
	timeliness = "lazy",
	_using = table.freeze {},
}

local METATABLE = table.freeze { __index = class }

local function Table<K, V>(scope: Types.Scope, initialValue: { [K]: V }): Types.Table<K, V>
	local newTable: Self<K, V> = setmetatable({
		scope = scope,
		createdAt = os.clock(),
		_internalValue = initialValue,

		_users = {},
	}, METATABLE) :: any

	table.insert(scope, destructor(newTable))

	return newTable
end

function class.setKey<K, V>(self: Self<K, V>, key: any, newValue: any)
	local list = self._internalValue
	local oldValue = list[key]

	list[key] = newValue

	if not isSimilar(oldValue, newValue) then
		change(self)
	end

	return list
end

function class.getKey<K, V>(self: Self<K, V>, key: any)
	local list = peek(self) :: any

	return list[key]
end

function class.remove<K, V>(self: Self<K, V>, index: number)
	local list = self._internalValue

	local removedValue = table.remove(list, index)

	change(self)

	return removedValue
end

function class.insert<K, V>(self: Self<K, V>, index: number, value: any)
	local list = self._internalValue

	table.insert(list, index, value)

	change(self)

	return value
end

function class._evaluate()
	return true
end

table.freeze(class)

return Table
