local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local change = require(package.Graph.change)
local depend = require(package.Graph.depend)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

local destructor = require(package.Memory.destructor)

local isSimilar = require(package.Utility.isSimilar)

local parseError = require(package.Logging.parseError)

type processor<V> = (use: Types.Use, become: (V) -> nil) -> ()
type Self<V> = Types.Eventual<V> & {
	_processor: processor<V>,
	_pendingValue: V,
	_becomeValue: V,
	_isBecoming: boolean,
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
	local newEventual = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_internalValue = pendingValue,
		_pendingValue = pendingValue,

		_isBecoming = false,
		_becomeValue = nil,

		_using = {},
		_users = {},

		_processor = processor,
	}, METATABLE)

	table.insert(scope, destructor(newEventual))

	return newEventual
end

function class._evaluate<V>(self: Self<V>)
	-- early return if we're becoming a value,
	-- so that we don't retrigger the entire evaluation.
	if self._isBecoming == true then
		self._isBecoming = false

		return not isSimilar(self._becomeValue, self._internalValue)
	end

	if self.scope == nil then
		return false
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

	-- still not entirely sure about reseting to the pending value assigned at Eventual construction,
	-- but i guess its saving keystrokes for the user, and that's what matters!
	self._internalValue = self._pendingValue

	local oldValue = self._internalValue

	External.doTaskImmediate(function()
		local ok, err = xpcall(self._processor, parseError, use, become)

		if not ok then
			External.logErrorNonFatal("callbackError", err)
		end
	end)

	local currentValue = self._internalValue

	-- immediate check in the case that the Eventual becomes something before yielding (if it does yield).
	return not isSimilar(currentValue, oldValue)
end

table.freeze(class)

return Eventual
