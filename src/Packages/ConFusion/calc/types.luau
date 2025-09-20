local graph = require "../graph/types"
local memory = require "../memory/types"

export type StateObject<V> = {
	_internalValue: V,

	kind: "state",
	type: string,
} & graph.GraphObject

export type UsedAs<V> = V | StateObject<V>
export type Use = <V>(target: UsedAs<V>) -> V

-- A state object whose value can be set by the user at any time.
export type Value<T> = {
	type: "Value",
	timeliness: "lazy",

	set: (Value<T>, newValue: T) -> T,
	update: (Value<T>, predicate: (T) -> T) -> T,
} & StateObject<T>
export type ValueConstructor = <T>(scope: memory.Scope, initialValue: T) -> Value<T>

-- A state object whose value is derived from other objects using a callback.
export type Computed<T> = {
	type: "Computed",
	timeliness: "eager",
} & StateObject<T>
export type ComputedConstructor = <S, T>(
	scope: memory.Scope<S>,
	processor: (Use, memory.Scope<S>) -> T
) -> Computed<T> | T

-- A state object which maps over keys and/or values in another table.
export type For<OK, OV> = {
	type: "For",
	timeliness: "lazy",
} & StateObject<{ [OK]: OV }>

export type ForPairsProcessor<S, IK, IV, OK, OV> = (
	use: Use,
	scope: memory.Scope<S>,
	inputKey: IK,
	inputValue: IV
) -> (OK, OV)
export type ForPairsConstructor = <S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	inputTable: UsedAs<{ [IK]: IV }>,
	processor: ForPairsProcessor<S, IK, IV, OK, OV>
) -> For<OK, OV> | { [OK]: OV }

export type ForKeysProcessor<S, IK, OK> = (
	use: Use,
	scope: memory.Scope<S>,
	inputKey: IK
) -> OK
export type ForKeysConstructor = <S, IK, IV, OK>(
	scope: memory.Scope<S>,
	inputTable: UsedAs<{ [IK]: IV }>,
	processor: ForKeysProcessor<S, IK, OK>
) -> For<OK, IV> | { [OK]: IV }

export type ForValuesProcessor<S, IV, OV> = (
	use: Use,
	scope: memory.Scope<S>,
	inputValue: IV
) -> OV
export type ForValuesConstructor = <S, IK, IV, OV>(
	scope: memory.Scope<S>,
	inputTable: UsedAs<{ [IK]: IV }>,
	processor: ForValuesProcessor<S, IV, OV>
) -> For<IK, OV> | { [IK]: OV }

return nil
