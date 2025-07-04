local External = require "../External"
local Types = require "../Types"

local change = require "../Graph/change"
local depend = require "../Graph/depend"

local castToState = require "./castToState"
local peek = require "./peek"

local destructor = require "../Memory/destructor"

local isSimilar = require "../Utility/isSimilar"

local parseError = require "../Logging/parseError"

type processor<V> = (use: Types.Use, become: (V) -> nil) -> ()
type Self<V> = Types.Eventual<V> & {
	_processor: processor<V>,

	_pendingValue: V,
	_becomeValue: V,

	_isBecoming: boolean,
	_active: thread?,
}

local class = {
	type = "Eventual",
	kind = "state",
	timeliness = "lazy",
}

local METATABLE = table.freeze { __index = class }

local function Eventual<V>(
	scope: Types.Scope,
	processor: processor<V>,
	pendingValue: V
): Types.Eventual<V>
	local newEventual: Self<V> = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_internalValue = pendingValue,
		_pendingValue = pendingValue,

		_isBecoming = false,
		_becomeValue = nil,

		_using = {},
		_users = {},

		_processor = processor,
	}, METATABLE) :: any

	table.insert(scope, {
		destructor(newEventual),
		function()
			if newEventual._active ~= nil then
				External.cancelTask(newEventual._active)
			end
		end,
	})

	return newEventual
end

function class.isPending<V>(self: Self<V>)
	return self._active ~= nil
end

function class._evaluate<V>(self: Self<V>): boolean
	if self.scope == nil then
		return false
	end

	if self._isBecoming == true then
		self._isBecoming = false

		return not isSimilar(self._becomeValue, self._internalValue)
	end

	if self._active ~= nil then
		External.cancelTask(self._active)

		self._active = nil
	end

	local used = {}

	local function use<T>(target: Types.UsedAs<T>): T
		if castToState(target) then
			depend(self, target)

			table.insert(used, target)
		end

		return peek(target)
	end

	local function become(value: V)
		self._becomeValue = self._internalValue
		self._internalValue = value

		if self.validity ~= "busy" then
			self._isBecoming = true

			-- i just realized how unsafe it is to call `change` on a object in a seperate thread.
			-- this will lead to some very weird and confusing errors that will be impossible to debug.
			-- maybe i could add a parameter to `change` that allows you to skip the busy checks, but that already
			-- sounds like a very, very bad idea and will probably lead to pain and suffering later on.
			change(self)
		end

		-- "re-depend" on used objects after becoming something.
		-- because calling `evaluate` (and by extension `change`) on an object causes all of its dependencies to be invalidated
		for _, target in used do
			depend(self, target)
		end
	end

	self._internalValue = self._pendingValue

	local bCompleted = false
	local originalValue = self._internalValue

	local activeThread = External.doTaskImmediate(function()
		local ok, err = xpcall(self._processor, parseError, use, become)

		if not ok then
			External.logErrorNonFatal("callbackError", err)
		end

		self._active = nil

		bCompleted = true
	end)

	if not bCompleted then
		self._active = activeThread
	end

	local currentValue = self._internalValue

	return not isSimilar(currentValue, originalValue)
end

table.freeze(class)

return Eventual
