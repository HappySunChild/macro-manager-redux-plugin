local Types = require "../Types"

local Animated = require "./Animated"
local packType = require "./packType"
local springCoefficients = require "./springCoefficients"
local unpackType = require "./unpackType"

local peek = require "../State/peek"

local EPSILON = 0.0001

local function springMover(speed: Types.UsedAs<number>, damping: Types.UsedAs<number>)
	local startP = {}
	local startV = {}

	local currentP = {}
	local currentV = {}

	local targetP = {}
	local numSprings = 0

	local activeType = ""

	return function(start: unknown, target: unknown)
		local discontinuous = typeof(target) ~= activeType

		targetP = unpackType(target)
		numSprings = #targetP

		if discontinuous then
			startP = table.clone(targetP)
			currentP = table.clone(targetP)

			startV = table.create(numSprings, 0)
			currentV = table.create(numSprings, 0)
		else
			startP = table.clone(currentP)
			startV = table.clone(currentV)
		end

		activeType = typeof(target)

		-- spring stepper
		return function(elapsed: number)
			local shouldSleep = false
			local newValue

			if elapsed <= 0 then
				newValue = start
			else
				local posPos, posVel, velPos, velVel =
					springCoefficients(elapsed, peek(damping), peek(speed))

				local isMoving = false

				for index = 1, numSprings do
					local startP = startP[index] :: number
					local targetP = targetP[index] :: number

					local startV = startV[index] :: number
					local startD = startP - targetP

					local latestD = startD * posPos + startV * posVel
					local newV = startD * velPos + startV * velVel

					if math.abs(latestD) > EPSILON or math.abs(newV) > EPSILON then
						isMoving = true
					end

					local newP = latestD + targetP

					currentP[index] = newP
					currentV[index] = newV
				end

				if not isMoving then
					for index = 1, numSprings do
						currentP[index] = targetP[index]
					end
				end

				shouldSleep = not isMoving
				newValue = packType(activeType, currentP)
			end

			return shouldSleep, newValue
		end
	end
end

local function Spring<V>(
	scope: Types.Scope,
	goal: Types.UsedAs<V>,
	speed: Types.UsedAs<number>?,
	damping: Types.UsedAs<number>?
): Types.Animated<V>
	speed = speed or 10
	damping = damping or 1

	local spring = Animated(scope, goal, springMover(speed, damping))
	spring.name = "Spring"

	return spring
end

return Spring
