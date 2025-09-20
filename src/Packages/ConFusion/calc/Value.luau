local calc = require "./types"
local memory = require "../memory/types"

local change = require "../graph/change"

local destructor = require "../memory/destructor"

local isSimilar = require "./isSimilar"

type Self<V> = calc.Value<V>

local class = table.freeze {
	type = "Value",
	kind = "state",
	timeliness = "lazy",

	_using = table.freeze {},

	set = function<V>(self: Self<V>, newValue: V): V
		if not isSimilar(newValue, self._internalValue) then
			self._internalValue = newValue

			change(self)
		end

		return newValue
	end,
	update = function<V>(self: Self<V>, updater: (V) -> V): V
		return self:set(updater(self._internalValue))
	end,
	_evaluate = function()
		return true
	end,
}
local METATABLE = table.freeze { __index = class }

local function Value<V>(scope: memory.Scope, initialValue: V): calc.Value<V>
	local newValue: Self<V> = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_internalValue = initialValue,

		_users = {},
	}, METATABLE) :: any

	table.insert(scope, destructor(newValue))

	return newValue
end

return Value
