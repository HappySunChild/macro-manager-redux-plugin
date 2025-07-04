local External = require "../External"
local Types = require "../Types"

local depend = require "../Graph/depend"

local castToState = require "./castToState"
local peek = require "./peek"

local deriveScope = require "../Memory/deriveScope"
local destructor = require "../Memory/destructor"
local doCleanup = require "../Memory/doCleanup"

local isSimilar = require "../Utility/isSimilar"

local parseError = require "../Logging/parseError"

type Self<T, S> = Types.Computed<T> & {
	_innerScope: Types.Scope<S>?,
	_processor: (use: Types.Use, scope: Types.Scope<S>) -> T,
}

local class = {
	type = "Computed",
	kind = "state",
	timeliness = "lazy",
}

local METATABLE = table.freeze { __index = class }

local function Computed<T, S>(
	scope: Types.Scope,
	processor: (Types.Use, Types.Scope<S>) -> T
): Types.Computed<T>
	local newComputed: Self<T, S> = setmetatable({
		scope = scope,
		createdAt = os.clock(),
		_internalValue = nil,

		_using = {},
		_users = {},

		_innerScope = nil,
		_processor = processor,
	}, METATABLE) :: any

	table.insert(scope, {
		destructor(newComputed),
		function()
			if newComputed._innerScope ~= nil then
				doCleanup(newComputed._innerScope)

				newComputed._innerScope = nil
			end
		end,
	})

	return newComputed
end

function class._evaluate<T, S>(self: Self<T, S>): boolean
	if self.scope == nil then
		return false
	end

	local outerScope = self.scope
	local innerScope = deriveScope(outerScope)

	local function use<V>(target: Types.UsedAs<V>): V
		if castToState(target) then
			depend(self, target)
		end

		return peek(target)
	end

	local ok, newValue = xpcall(self._processor, parseError, use, innerScope)

	if ok then
		local similar = isSimilar(self._internalValue, newValue)

		if self._innerScope ~= nil then
			doCleanup(self._innerScope)

			self._innerScope = nil
		end

		self._innerScope = innerScope
		self._internalValue = newValue

		return not similar
	else
		doCleanup(innerScope)

		External.logErrorNonFatal("callbackError", newValue)
	end

	return false
end

table.freeze(class)

return Computed
