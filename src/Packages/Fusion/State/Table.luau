local package = script.Parent.Parent

local Types = require(package.Types)

local peek = require(package.State.peek)

local change = require(package.Graph.change)

local destructor = require(package.Memory.destructor)

local isSimilar = require(package.Utility.isSimilar)

type Self<K, V> = Types.Table<K, V>

local class = {
	type = "Table",
	kind = "state",
	timeliness = "lazy",
	_using = table.freeze {},
}

local METATABLE = table.freeze { __index = class }

local function Table<K, V>(scope: Types.Scope, initialValue: { [K]: V }): Types.Table<K, V>
	local newTable = setmetatable({
		scope = scope,
		createdAt = os.clock(),
		_internalValue = initialValue,

		_users = {},
	}, METATABLE)

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
	local list = peek(self)

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
