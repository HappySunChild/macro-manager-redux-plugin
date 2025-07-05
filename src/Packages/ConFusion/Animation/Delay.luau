local External = require "../External"
local Types = require "../Types"

local Animated = require "./Animated"

local peek = require "../State/peek"

local function delayMover<V>(delay: Types.UsedAs<number>)
	local current = nil
	local activeDelayed = {}

	local function update()
		local now = External.lastUpdateStep()

		local timestepValues = {}

		for index = #activeDelayed, 1, -1 do
			local data = activeDelayed[index]

			if data.timestamp <= now then
				table.insert(timestepValues, data)
				table.remove(activeDelayed, index)
			end
		end

		if #timestepValues > 0 then
			table.sort(timestepValues, function(a, b)
				return a.timestamp > b.timestamp
			end)

			current = timestepValues[1].goal
		end

		return #activeDelayed == 0, current
	end

	return function(start: V, target: V)
		local now = External.lastUpdateStep()
		local later = now + peek(delay)

		table.insert(activeDelayed, {
			timestamp = later,
			goal = target,
		})

		current = start

		return update
	end
end

local function Delay<V>(
	scope: Types.Scope,
	target: Types.UsedAs<V>,
	delay: Types.UsedAs<number>
): Types.Animated<V>
	return Animated(scope, target, delayMover(delay))
end

return Delay
