local package = script.Parent.Parent

local Types = require(package.Types)

local peek = require(package.State.peek)

local change = require(package.Graph.change)
local depend = require(package.Graph.depend)

local destructor = require(package.Memory.destructor)

local ExternalTime = require(package.Animation.ExternalTime)

type Self = Types.Timer & {
	_paused: boolean,
	_start: number,
	_timer: Types.StateObject<number>,
}

local class = {
	type = "Timer",
	kind = "state",
	timeliness = "lazy",
}

local METATABLE = table.freeze { __index = class }

local function Timer(scope: Types.Scope): Types.Timer
	local externalTime = ExternalTime(scope)

	local newTimer = setmetatable({
		scope = scope,
		createdAt = os.clock(),
		_internalValue = 0,

		_paused = false,
		_start = peek(externalTime),

		_using = {},
		_users = {},
		_timer = externalTime,
	}, METATABLE) :: any

	table.insert(scope, { destructor(newTimer) })

	depend(newTimer, externalTime)

	return newTimer
end

function class.unpause(self: Self)
	if not self._paused then
		return
	end

	self._paused = false

	change(self)
end

function class.pause(self: Self)
	if self._paused then
		return
	end

	self._paused = true

	change(self)
end

function class.reset(self: Self)
	self._start = peek(self._timer) :: number
	self._internalValue = 0

	change(self)
end

function class._evaluate(self: Self)
	if self._paused then
		return false
	end

	depend(self, self._timer)

	local now = peek(self._timer) :: number

	local oldValue = self._internalValue
	local newValue = now - self._start

	self._internalValue = newValue

	return oldValue ~= newValue
end

return Timer
