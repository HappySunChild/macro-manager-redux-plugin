--!strict
local External = require("../External")
local Types = require("../Types")

local Timer = require("./Timer")

local depend = require("../Graph/depend")
local evaluate = require("../Graph/evaluate")

local castToState = require("../State/castToState")
local peek = require("../State/peek")

type Self<V> = Types.Animated<V> & {
	_goal: Types.UsedAs<V>,
	_activeStart: V,
	_activeGoal: V,

	_mover: Types.UsedAs<Types.AnimatedMover<V>>,
	_activeMover: Types.AnimatedMover<V>,
	_activeStepper: Types.MoverStepper<V>,

	_timer: Types.Timer,
}

local class = {
	type = "Animated",
	kind = "state",
	timeliness = "eager",
}

local METATABLE = table.freeze { __index = class }

local function Animated<V>(
	scope: Types.Scope,
	goal: Types.UsedAs<V>,
	mover: Types.UsedAs<Types.AnimatedMover<V>>
): Types.Animated<V>
	local timer = Timer(scope)
	local newAnimated: Self<V> = setmetatable({
		scope = scope,
		createdAt = os.clock(),
		_internalValue = peek(goal),

		_using = {},
		_users = {},

		_mover = mover,
		_goal = goal,

		_activeStart = nil,
		_activeGoal = nil,
		_activeMover = nil,
		_activeStepper = nil,

		_timer = timer,
	}, METATABLE) :: any

	evaluate(newAnimated, true)

	return newAnimated
end

function class._evaluate<V>(self: Self<V>)
	local goal = self._goal

	if not castToState(self._goal) then
		return false
	end

	local mover = self._mover
	local timer = self._timer
	
	local nextGoal = peek(goal)
	local nextMover = peek(mover) :: Types.AnimatedMover<V>

	if castToState(mover) then
		depend(self, mover :: any)
	end

	depend(self, timer)
	depend(self, goal)

	if nextGoal ~= (self._activeGoal :: any) or nextMover ~= self._activeMover then
		self._activeStart = self._internalValue
		self._activeGoal = nextGoal
		
		self._activeMover = nextMover
		self._activeStepper = nextMover(self._activeStart, self._activeGoal)
		
		--[[
			The Animated *needs* to be dependant on the timer AND the goal,
			so that when the goal updates we can wake the Animated and change
			course if the goal changes while awake, but this has some problems;
			
			Whenever the goal changes, the timer gets reset to 0. Which means that any Animated
			following another awake Animated (or rapidly changing value) would appear to be "frozen".
			
			This issue is also prevelant in base Fusion, which makes me think that nobody
			has tried to make a spring/tween follow another spring/tween, or possibly this is actively discouraged (*)
			in the docs and I just haven't noticed.
			
			Either way I believe this behavior is unacceptable, but I seriously can not think of a way to
			fix this without having to make some radical changes.
			
			Maybe deferring the resetting to after the mover runs could work (?), so that there could be atleast *some*
			progress made in the animated, instead of it just freezing.
			
			(*) After taking a look at the docs it seems that this is actually *actively* encouraged. On the springs page (https://elttob.uk/Fusion/0.3/tutorials/animation/springs/#interruption)
			it mentions how springs are, "suitable for following rapidly changing values." Maybe it doesn't mean Springs/Tweens as "rapidly changing values", but it also doesn't explicitly state
			that using Springs/Tweens as goals causes freezing to occur.
		--]]

		timer:reset()
		timer:unpause()
	end

	local elapsed = peek(timer) :: number
	
	if elapsed == 0 then
		elapsed = External.deltaTime()
	end

	local shouldSleep, newValue = self._activeStepper(elapsed)

	if shouldSleep or (self._activeStart :: any) == nextGoal then
		timer:pause()
		timer:reset()
	end

	local oldValue = self._internalValue :: any

	self._internalValue = newValue

	return (oldValue :: any) ~= (newValue :: any)
end

return Animated
