local calc = require "../calc/types"
local chrono = require "../chrono/types"
local memory = require "../memory/types"
local motion = require "./types"

local External = require "../External"

local Timer = require "../chrono/Timer"

local change = require "../graph/change"
local depend = require "../graph/depend"
local evaluate = require "../graph/evaluate"

local destructor = require "../memory/destructor"

local castToState = require "../calc/castToState"

local peek = require "../use/peek"

type Self<V> = motion.Animated<V> & {
	_goal: calc.UsedAs<V>,
	_activeGoal: V,

	_activeDynamics: { any },
	_regenerate: boolean?,

	_generator: calc.UsedAs<motion.CurveGenerator<V>>,
	_activeGenerator: motion.CurveGenerator<V>,
	_activeCurve: motion.AnimationCurve<V>,

	_timer: chrono.Timer,
}

local function _syncFromCurve<V>(
	dynamics: { any },
	shouldSleep: boolean,
	outputValue: V,
	...: any
): (V, boolean)
	table.clear(dynamics)

	for i = 1, select("#", ...) do
		dynamics[i + 1] = select(i, ...)
	end

	return outputValue, shouldSleep
end

local class = table.freeze {
	type = "Animated",
	kind = "state",
	timeliness = "eager",

	setDynamic = function<V>(self: Self<V>, index: number, value: any)
		self._activeDynamics[index] = value
		self._regenerate = true

		change(self)
	end,
	getDynamic = function<V>(self: Self<V>, index: number)
		return self._activeDynamics[index]
	end,
	_evaluate = function<V>(self: Self<V>)
		local goal = self._goal

		local generator = self._generator
		local timer = self._timer

		local nextGoal = peek(goal)

		if castToState(goal) then
			depend(self, goal)
		end

		-- protect against NaN goals
		if nextGoal ~= nextGoal then
			External.logWarn("animatedInvalidGoal", nextGoal)

			return false
		end

		local nextGenerator = peek(generator) :: motion.CurveGenerator<V>

		if castToState(generator) then
			depend(self, generator :: any)
		end

		depend(self, timer)

		-- wake
		if
			nextGoal ~= self._activeGoal :: any
			or nextGenerator ~= self._activeGenerator
			or self._regenerate == true
		then
			self._regenerate = nil

			self._activeGoal = nextGoal

			self._activeGenerator = nextGenerator
			self._activeCurve =
				nextGenerator(self._activeGoal, unpack(self._activeDynamics))

			timer:reset()
			timer:unpause()
		end

		local elapsed = peek(timer) :: number

		-- fix Animateds following eachother
		if elapsed == 0 then
			elapsed = External.getDeltaTime()
		end

		local oldValue = self._internalValue :: any
		local newValue, shouldSleep =
			_syncFromCurve(self._activeDynamics, self._activeCurve(elapsed))

		if (newValue :: any) ~= (newValue :: any) then
			External.logWarn("animatedInvalidMotion", newValue, self._activeGoal)

			newValue = self._activeGoal
		end

		self._activeDynamics[1] = newValue
		self._internalValue = newValue

		if shouldSleep then
			timer:pause()
		end

		return (oldValue :: any) ~= (newValue :: any)
	end,
}
local METATABLE = table.freeze { __index = class }

local function Animated<V>(
	scope: memory.Scope,
	goal: calc.UsedAs<V>,
	mover: calc.UsedAs<motion.CurveGenerator<V>>
): motion.Animated<V>
	local timer = Timer(scope)
	local newAnimated: Self<V> = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_internalValue = nil,

		_using = {},
		_users = {},

		_goal = goal,
		_activeGoal = nil,

		_activeDynamics = { peek(goal) },

		_generator = mover,
		_activeGenerator = nil,
		_activeCurve = nil,

		_timer = timer,
	}, METATABLE) :: any

	table.insert(scope, destructor(newAnimated))

	evaluate(newAnimated, true)

	return newAnimated
end

return Animated
