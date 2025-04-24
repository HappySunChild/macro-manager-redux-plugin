local package = script.Parent.Parent

local Types = require(package.Types)

local Animated = require(package.Animation.Animated)
local getTweenAlpha = require(package.Animation.getTweenAlpha)
local getTweenDuration = require(package.Animation.getTweenDuration)
local lerp = require(package.Animation.lerp)

local peek = require(package.State.peek)

local function tweenMover(info: Types.UsedAs<TweenInfo>)
	return function(start: unknown, target: unknown)
		local activeInfo = peek(info)
		local duration = getTweenDuration(activeInfo)
		
		-- tween stepper
		return function(elapsed: number)
			local alpha = getTweenAlpha(activeInfo, elapsed)

			return elapsed >= duration, lerp(start, target, alpha)
		end
	end
end

local function Tween<V>(
	scope: Types.Scope,
	goal: Types.UsedAs<V>,
	info: Types.UsedAs<TweenInfo>
): Types.Animated<V>
	local tween = Animated(scope, goal, tweenMover(info))
	tween.name = "Tween"

	return tween
end

return Tween
