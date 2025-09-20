local chrono = require "./types"
local memory = require "../memory/types"

local peek = require "../use/peek"

local change = require "../graph/change"
local depend = require "../graph/depend"

local destructor = require "../memory/destructor"

local ExternalTime = require "./ExternalTime"

type Self = chrono.Timer & {
	_paused: boolean,
	_start: number,
	_timer: chrono.ExternalTime,
}

local class = table.freeze {
	type = "Timer",
	kind = "state",
	timeliness = "lazy",

	unpause = function(self: Self)
		if not self._paused then
			return
		end

		self._timer:setActive(true)
		self._paused = false

		change(self)
	end,
	pause = function(self: Self)
		if self._paused then
			return
		end

		self._timer:setActive(false)
		self._paused = true

		change(self)
	end,
	reset = function(self: Self)
		self._start = peek(self._timer) :: number
		self._internalValue = 0

		change(self)
	end,
	_evaluate = function(self: Self)
		if self._paused then
			return false
		end

		depend(self, self._timer)

		local now = peek(self._timer) :: number

		local oldValue = self._internalValue
		local newValue = now - self._start

		self._internalValue = newValue

		return oldValue ~= newValue
	end,
}
local METATABLE = table.freeze { __index = class }

local function Timer(scope: memory.Scope): chrono.Timer
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

return Timer
