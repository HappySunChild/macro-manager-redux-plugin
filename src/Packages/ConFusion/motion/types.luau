local calc = require "../calc/types"
local memory = require "../memory/types"

export type AnimationCurve<V> = (elapsed: number) -> (boolean, V, ...any)
export type CurveGenerator<V> = (goal: V, start: V, ...any) -> AnimationCurve<V>

-- A state object whose value can be animated with a AnimatedMover callback.
export type Animated<V> = {
	type: "Animated",

	setDynamic: (self: Animated<V>, index: number, value: any) -> (),
	getDynamic: (self: Animated<V>, index: number) -> any?,
} & calc.StateObject<V>
export type AnimatedConstructor = <V>(
	scope: memory.Scope,
	goal: calc.UsedAs<V>,
	mover: calc.UsedAs<CurveGenerator<V>>
) -> Animated<V>

export type TweenConstructor = <V>(
	scope: memory.Scope,
	goal: calc.UsedAs<V>,
	info: calc.UsedAs<TweenInfo>
) -> Animated<V> | V
export type SpringConstructor = <V>(
	scope: memory.Scope,
	goal: calc.UsedAs<V>,
	speed: calc.UsedAs<number>?,
	damping: calc.UsedAs<number>?
) -> Animated<V>

return nil
