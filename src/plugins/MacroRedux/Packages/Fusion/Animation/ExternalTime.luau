local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local change = require(package.Graph.change)
local destructor = require(package.Memory.destructor)

type ExternalTime = Types.StateObject<number> & {
	type: "ExternalTime",
}

type Self = ExternalTime

local class = {
	type = "ExternalTime",
	kind = "state",
	timeliness = "lazy",
	_using = table.freeze {},
	_internalValue = External.lastUpdateStep(),
}

local METATABLE = table.freeze { __index = class }

local activeTimers = {}

local function ExternalTime(scope: Types.Scope): ExternalTime
	local newExternalTime = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_users = {},
	}, METATABLE)

	table.insert(scope, {
		destructor(newExternalTime),
		function()
			local index = table.find(activeTimers, newExternalTime)

			if index ~= nil then
				table.remove(activeTimers, index)
			end
		end,
	})
	table.insert(activeTimers, newExternalTime)

	return newExternalTime
end

function class._evaluate()
	return true
end

External.bindToUpdate(function(now)
	class._internalValue = now

	for _, timer in activeTimers do
		change(timer)
	end
end)

return ExternalTime
