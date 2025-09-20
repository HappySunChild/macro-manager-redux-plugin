local chrono = require "./types"
local memory = require "../memory/types"

local External = require "../External"

local change = require "../graph/change"

local destructor = require "../memory/destructor"

type Self = chrono.ExternalTime & {
	_active: boolean,
}

local ALL_TIMERS = {}

local function auxiliaryDestructor(externalTime: Self)
	local index = table.find(ALL_TIMERS, externalTime)

	if index ~= nil then
		table.remove(ALL_TIMERS, index)
	end
end

local class = {
	type = "ExternalTime",
	kind = "state",
	timeliness = "lazy",
	_using = table.freeze {},
	_internalValue = External.getLastUpdate(),

	setActive = function(self: Self, active: boolean)
		self._active = active
	end,
	isActive = function(self: Self)
		return self._active
	end,
	_evaluate = function(self: Self)
		return true
	end,
}
local METATABLE = table.freeze { __index = class }

local function ExternalTime(scope: memory.Scope): chrono.ExternalTime
	local newExternalTime = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_users = {},
		_active = true,
	}, METATABLE) :: Self

	table.insert(ALL_TIMERS, newExternalTime)
	table.insert(scope, destructor(newExternalTime, auxiliaryDestructor))

	return newExternalTime
end

External.bindToUpdateStep(function(now: number)
	class._internalValue = now

	for _, timer in ALL_TIMERS do
		if timer:isActive() then
			change(timer)
		end
	end
end)

return ExternalTime
