local calc = require "../calc/types"
local memory = require "../memory/types"

export type Pipe<S, T> = {
	type: "Pipe",
	kind: "pipe",

	spring: (
		Pipe<S, T>,
		speed: calc.UsedAs<number>?,
		damping: calc.UsedAs<number>?
	) -> Pipe<S, T>,
	tween: (Pipe<S, T>, info: calc.UsedAs<TweenInfo>) -> Pipe<S, T>,

	map: <O>(
		Pipe<S, T>,
		processor: (value: T, use: calc.Use, scope: memory.Scope<S>) -> O
	) -> Pipe<S, T>, -- Pipe<O>, -- this isn't allowed?

	forPairs: <IK, IV, OK, OV>(
		Pipe<S, T>,
		processor: calc.ForPairsProcessor<S, IK, IV, OK, OV>
	) -> Pipe<S, T>, -- Pipe<{ [OK]: OV }>,
	forValues: <IK, IV, OV>(
		Pipe<S, T>,
		processor: calc.ForValuesProcessor<S, IV, OV>
	) -> Pipe<S, T>, -- Pipe<{ [IK]: OV }>,
	forKeys: <IK, IV, OK>(
		Pipe<S, T>,
		processor: calc.ForKeysProcessor<S, IK, OK>
	) -> Pipe<S, T>, -- Pipe<{ [OK]: IV }>,

	resolve: (Pipe<S, T>) -> calc.UsedAs<T>,
}

export type PipeConstructor = <S, T>(
	scope: memory.Scope<S>,
	initialValue: calc.UsedAs<T>
) -> Pipe<S, T>

return nil
