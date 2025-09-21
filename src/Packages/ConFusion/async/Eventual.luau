local async = require "./types"
local calc = require "../calc/types"
local memory = require "../memory/types"

local External = require "../External"

local change = require "../graph/change"
local depend = require "../graph/depend"
local evaluate = require "../graph/evaluate"

local castToState = require "../calc/castToState"
local isSimilar = require "../calc/isSimilar"

local peek = require "../use/peek"

local deriveScope = require "../memory/deriveScope"
local destructor = require "../memory/destructor"
local doCleanup = require "../memory/doCleanup"

local parseError = require "../logging/parseError"

type processor<S, T> = (use: calc.Use, scope: memory.Scope<S>, become: (T) -> ()) -> ()
type Self<T, S> = async.Eventual<T> & {
	_innerScope: memory.Scope<S>,
	_processor: processor<S, T>,

	_pendingValue: T,
	_becomeValue: T?,

	_isBecoming: boolean?,
	_activeThread: thread?,
}

local function auxiliaryDestructor<T, S>(eventual: Self<T, S>)
	if eventual._activeThread ~= nil then
		External.cancelTask(eventual._activeThread)
	end

	if eventual._innerScope ~= nil then
		doCleanup(eventual._innerScope)

		eventual._innerScope = nil
	end
end

local class = table.freeze {
	type = "Eventual",
	kind = "state",
	timeliness = "eager",

	isPending = function<T, S>(self: Self<T, S>)
		return self._activeThread ~= nil
	end,
	_evaluate = function<T, S>(self: Self<T, S>): boolean
		if self.scope == nil then
			return false
		end

		-- calling `become` causes the Eventual to be reevaluated, but we don't want to completely reevaluate everything
		if self._isBecoming == true then
			self._isBecoming = false

			return not isSimilar(self._becomeValue, self._internalValue)
		end

		-- cancel any currently active computations
		if self._activeThread ~= nil then
			if self._innerScope ~= nil then
				doCleanup(self._innerScope)

				self._innerScope = nil
			end

			External.cancelTask(self._activeThread)

			self._activeThread = nil
		end

		local outerScope = self.scope
		local innerScope = deriveScope(outerScope)

		local sessionUsed = {}

		local function use<V>(target: calc.UsedAs<V>): V
			if castToState(target) then
				depend(self, target)

				sessionUsed[target] = true
			end

			return peek(target)
		end

		local function become(targetValue: T)
			-- becomeValue is not the value it's becoming! it is the value the Eventual was at the time of becoming another value!!
			-- should probably give this a better name...
			local becomeValue = self._internalValue

			self._internalValue = targetValue

			if self.validity ~= "busy" then
				-- i just realized how unsafe it is to call `change` on a object in a seperate thread.
				-- this will lead to some very weird and confusing errors that will be impossible to debug.
				-- maybe i could add a parameter to `change` that allows you to skip the busy checks, but that already
				-- sounds like a very, very bad idea and will probably lead to pain and suffering later on.

				-- actually if we're already busy then that means that we haven't yielded yet during our processor, which is totally fine
				-- we don't need to call change since we're already being evaluated...

				-- ignore everything, this is actually completely safe (i think???) and i was just overreacting...

				self._becomeValue = becomeValue
				self._isBecoming = true

				change(self)

				-- release value, i think this reduces memoization??
				self._becomeValue = nil

				-- re-depend on everything we've used in this computation session
				for target in sessionUsed do
					depend(self, target)
				end
			end
		end

		self._internalValue = self._pendingValue

		local didYield = true

		local activeThread = External.doTaskImmediate(function()
			local ok, err = xpcall(self._processor, parseError, use, innerScope, become)

			if ok then
				if self._innerScope ~= nil then
					doCleanup(self._innerScope)
				end

				self._innerScope = innerScope
			else
				doCleanup(innerScope)

				External.logErrorNonFatal("callbackError", err)
			end

			self._activeThread = nil

			didYield = false
		end)

		-- if we yielded then update _activeThread
		-- this was false for some reason???? i think i was very sleep deprived when i wrote this...
		if didYield == true then
			self._activeThread = activeThread
		end

		return not isSimilar(self._internalValue, self._pendingValue)
	end,
}
local METATABLE = table.freeze { __index = class }

local function Eventual<T, S>(
	scope: memory.Scope<S>,
	processor: processor<S, T>,
	pendingValue: T
): async.Eventual<T>
	local newEventual: Self<T, S> = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_internalValue = pendingValue,
		_pendingValue = pendingValue,

		_using = {},
		_users = {},

		_innerScope = nil,
		_processor = processor,
	}, METATABLE) :: any

	table.insert(scope, destructor(newEventual, auxiliaryDestructor))

	evaluate(newEventual, true)

	return newEventual
end

return Eventual
