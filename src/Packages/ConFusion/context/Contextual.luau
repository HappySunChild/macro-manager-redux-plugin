local context = require "./types"

local External = require "../External"

local parseError = require "../logging/parseError"

type Self<T> = context.Contextual<T> & {
	_default: T,
	_values: { [thread]: { T } },
}

local class = table.freeze {
	class = "Contextual",
	kind = "contextual",

	now = function<T>(self: Self<T>): T
		local thread = coroutine.running()
		local value = self._values[thread]

		if value == nil then
			return self._default
		end

		return value[1]
	end,
	executeWith = function<T, R, A...>(self: Self<T>, new: T, callback: (A...) -> R, ...: A...): R
		local thread = coroutine.running()
		local original = self._values[thread]

		self._values[thread] = { new }

		local ok, value = xpcall(callback, parseError, ...)

		self._values[thread] = original

		if not ok then
			External.logError("callbackError", value)
		end

		return value
	end,
}
local METATABLE = table.freeze { __index = class }
local WEAK_KEYS_METATABLE = table.freeze { __mode = "k" }

local function Contextual<T>(default: T): context.Contextual<T>
	local newContextual: Self<T> = setmetatable({
		_default = default,
		_values = setmetatable({}, WEAK_KEYS_METATABLE),
	}, METATABLE) :: any

	return newContextual
end

return Contextual
