local calc = require "./types"
local memory = require "../memory/types"

local External = require "../External"

local depend = require "../graph/depend"

local castToState = require "./castToState"
local isSimilar = require "./isSimilar"

local dissolvingUse = require "../use/dissolvingUse"
local peek = require "../use/peek"

local checkArity = require "../memory/checkArity"
local deriveScope = require "../memory/deriveScope"
local destructor = require "../memory/destructor"
local doCleanup = require "../memory/doCleanup"
local innerScope = require "../memory/innerScope"

local parseError = require "../logging/parseError"

type ComputedProcessor<S, T> = (use: calc.Use, scope: memory.Scope<S>) -> T
type Self<T, S> = calc.Computed<T> & {
	_innerScope: memory.Scope<S>?,
	_processor: ComputedProcessor<S, T>,
}

local function auxiliaryDestructor<T, S>(computed: Self<T, S>)
	if computed._innerScope ~= nil then
		doCleanup(computed._innerScope)

		computed._innerScope = nil
	end
end

local function checkDissolvable<T, S>(
	scope: memory.Scope<S>,
	processor: ComputedProcessor<S, T>
): (boolean, T?)
	local dissolvingScope = innerScope(scope)
	local success, value = pcall(processor, dissolvingUse, dissolvingScope)

	if success then
		-- scope went unused, we can clean it up
		if #dissolvingScope == 1 then
			doCleanup(dissolvingScope)
		end

		return true, value
	end

	doCleanup(dissolvingScope)

	return false
end

local class = table.freeze {
	type = "Computed",
	kind = "state",
	timeliness = "lazy",

	_evaluate = function<T, S>(self: Self<T, S>): boolean
		if self.scope == nil then
			return false
		end

		local outerScope = self.scope
		local innerScope = deriveScope(outerScope)

		local function use<V>(target: calc.UsedAs<V>): V
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
	end,
}
local METATABLE = table.freeze { __index = class }

local function Computed<T, S>(
	scope: memory.Scope<S>,
	processor: ComputedProcessor<S, T>
): calc.Computed<T>
	checkArity(processor)

	local canDissolve, constant = checkDissolvable(scope, processor)

	if canDissolve then
		return constant
	end

	local newComputed: Self<T, S> = setmetatable({
		scope = scope,
		createdAt = os.clock(),
		_internalValue = nil,

		_using = {},
		_users = {},

		_innerScope = nil,
		_processor = processor,
	}, METATABLE) :: any

	table.insert(scope, destructor(newComputed, auxiliaryDestructor))

	return newComputed
end

return Computed
