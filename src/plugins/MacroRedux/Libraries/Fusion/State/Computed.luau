local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local depend = require(package.Graph.depend)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

local deriveScope = require(package.Memory.deriveScope)
local destructor = require(package.Memory.destructor)
local doCleanup = require(package.Memory.doCleanup)

local isSimilar = require(package.Utility.isSimilar)

local parseError = require(package.Logging.parseError)

type Self<S, V> = Types.Computed<V> & {
	_innerScope: Types.Scope<S>?,
	_processor: (use: Types.Use, scope: Types.Scope<S>) -> V,
}

local class = {
	type = "Computed",
	kind = "state",
	timeliness = "lazy",
}

local METATABLE = table.freeze { __index = class }

local function Computed<S, VO>(
	scope: Types.Scope,
	processor: (Types.Use, Types.Scope<S>) -> VO
): Types.Computed<VO>
	local newComputed = setmetatable({
		scope = scope,
		createdAt = os.clock(),
		_internalValue = nil,

		_using = {},
		_users = {},

		_innerScope = nil,
		_processor = processor,
	}, METATABLE)

	table.insert(scope, {
		destructor(newComputed),
		function()
			if newComputed._innerScope then
				doCleanup(newComputed._innerScope)

				newComputed._innerScope = nil
			end
		end,
	})

	return newComputed
end

function class._evaluate<S, V>(self: Self<S, V>)
	if self.scope == nil then
		return false
	end

	local outerScope = self.scope
	local innerScope = deriveScope(outerScope)

	local function use<T>(target: Types.UsedAs<T>): T
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
