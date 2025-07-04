local Types = require "../Types"

local peek = require "../State/peek"

local change = require "../Graph/change"
local depend = require "../Graph/depend"

local destructor = require "../Memory/destructor"

local ExternalTime = require "./ExternalTime"

type Self = Types.Timer & {
	_paused: boolean,
	_start: number,
	_timer: ExternalTime.ExternalTime,
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
	}, METATABLE) :: Self

	table.insert(scope, destructor(newTimer))

	depend(newTimer, externalTime)

	return newTimer
end

function class.unpause(self: Self)
	if not self._paused then
		return
	end

	self._timer:setActive(true)
	self._paused = false

	change(self)
end

function class.pause(self: Self)
	if self._paused then
		return
	end

	self._timer:setActive(false)
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
