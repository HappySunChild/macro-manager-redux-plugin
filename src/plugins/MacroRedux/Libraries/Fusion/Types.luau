--!strict

export type Error = {
	type: "Error",
	raw: string,
	message: string,
	trace: string,
}

export type CleanupTask = Instance | RBXScriptConnection | () -> () | { CleanupTask }
export type Child = Instance | ((Instance) -> Instance?) | { Child } | UsedAs<Child>

export type Validity = "busy" | "invalid" | "valid"
export type Timeliness = "lazy" | "eager"

export type Properties = { [SpecialKey | string]: any }

export type Scope<T = unknown> = T & { CleanupTask? }

export type UsedAs<V> = StateObject<V> | V
export type Use = <V>(target: StateObject<V>) -> V

type Disconnect = () -> ()

export type ScopedObject = {
	scope: Scope<unknown>,
}

export type GraphObject = ScopedObject & {
	type: string?,
	kind: string?,

	createdAt: number?,
	validity: Validity?,
	timeliness: Timeliness,

	_lastChange: number?,
	_users: { [GraphObject]: true },
	_using: { [GraphObject]: true },
	_observers: { [{}]: Observer }?,

	_evaluate: (GraphObject) -> boolean,
}

export type StateObject<V> = {
	_internalValue: V,

	kind: "state",
	type: string,
} & GraphObject

-- A state object whose value can be set by the user at any time.
export type Value<V> = {
	type: "Value",
	timeliness: "lazy",

	set: (Value<V>, newValue: V) -> V,
	update: (Value<V>, predicate: (V) -> V) -> V,

	bindToInstanceProperty: (
		Value<V>,
		instance: Instance,
		property: string
	) -> Disconnect,
} & StateObject<V>

type ValueConstructor = <V>(scope: Scope<unknown>, initialValue: V?) -> Value<V>

-- A state object that's similar to Value, but specifically for tables. It contains methods for modifying and reading specific keys.
export type Table<K, V> = {
	type: "Table",
	timeliness: "lazy",

	setKey: (Table<K, V>, key: K, value: V) -> V,
	getKey: (Table<K, V>, key: K) -> V,

	insert: (Table<K, V>, index: number, value: V) -> V,
	remove: (Table<K, V>, index: number) -> V,
} & StateObject<{ [K]: V }>

type TableConstructor = <K, V>(
	scope: Scope<unknown>,
	initialValue: { [K]: V }
) -> Table<K, V>

-- A state object whose value is derived from other objects using a callback.
export type Computed<V> = {
	type: "Computed",
	timeliness: "eager",
} & StateObject<V>

type ComputedConstructor = <V, S>(
	scope: Scope<S>,
	processor: (Use, S) -> V
) -> Computed<V>

-- A state object which maps over keys and/or values in another table.
export type For<OK, OV> = {
	type: "For",
	timeliness: "lazy",
} & StateObject<{ [OK]: OV }>

type ForPairsConstructor = <S, IK, IV, OK, OV>(
	scope: Scope<S>,
	input: UsedAs<{ [IK]: IV }>,
	processor: (Use, S, key: IK, value: IV) -> (OK, OV)
) -> For<OK, OV>

type ForKeysConstructor = <S, IK, IV, OK>(
	scope: Scope<S>,
	input: UsedAs<{ [IK]: IV }>,
	processor: (Use, S, key: IK) -> OK
) -> For<OK, IV>

type ForValuesConstructor = <S, IK, IV, OV>(
	scope: Scope<S>,
	input: UsedAs<{ [IK]: IV }>,
	processor: (S, value: IV) -> OV
) -> For<IK, OV>

-- A state object that's similar to Computed, but is asynchronous.
export type Eventual<V> = {
	type: "Eventual",
	timeliness: "lazy",
} & StateObject<V>

type EventualConstructor = <V>(
	scope: Scope<unknown>,
	processor: (Use, become: (V) -> ()) -> (),
	default: V?
) -> Eventual<V>

-- An object which can listen for updates on another state object.
export type Observer = {
	type: "Observer",
	kind: "observer",

	createdAt: number,
	callback: () -> (),
}

export type Timer = StateObject<number> & {
	type: "Timer",

	pause: (Timer) -> (),
	unpause: (Timer) -> (),
	reset: (Timer) -> (),
}

export type MoverStepper<V> = (elapsed: number) -> (boolean, V)
export type AnimatedMover<V> = (start: V, goal: V) -> MoverStepper<V>

-- A state object whose value can be animated with a AnimatedMover callback.
export type Animated<V> = {
	type: "Animated",
} & StateObject<V>

type AnimatedConstructor = <V>(
	scope: Scope<unknown>,
	goal: UsedAs<V>,
	mover: AnimatedMover<V>
) -> Animated<V>

type TweenConstructor = <V>(
	scope: Scope<unknown>,
	goal: UsedAs<V>,
	info: UsedAs<TweenInfo>
) -> Animated<V>

type SpringConstructor = <V>(
	scope: Scope<unknown>,
	goal: UsedAs<V>,
	speed: UsedAs<number>,
	damping: UsedAs<number>
) -> Animated<V>

type DelayConstructor = <V>(
	scope: Scope<unknown>,
	goal: UsedAs<V>,
	amount: UsedAs<number>
) -> Animated<V>

export type SpecialKey<T = string> = {
	type: T,
	kind: "key",
	stage: string,

	apply: (scope: Scope, instance: Instance, value: any) -> (),
}

export type ExternalProvider = {
	startScheduler: () -> (),
	stopScheduler: () -> (),

	logErrorNonFatal: (message: string) -> (),
	logWarn: (message: string) -> (),

	doTaskImmediate: (resume: (...unknown) -> (), ...unknown) -> (),
	doTaskDeferred: (resume: (...unknown) -> (), ...unknown) -> (),
}

export type Fusion = {
	read scoped: <B, M>(base: B, methods: M?) -> Scope<B> & M,
	read deriveScope: <T, M>(existing: T, methods: M?) -> T & M,
	read innerScope: <T, M>(existing: T, methods: M?) -> T & M,
	read doCleanup: (CleanupTask) -> (),

	read setProvider: (newProvider: ExternalProvider?) -> ExternalProvider?,

	read peek: <V>(value: UsedAs<V> | V) -> V,
	read observe: <V>(
		value: StateObject<V>,
		callback: () -> (),
		immediate: boolean?
	) -> Disconnect,
	read map: <V, O>(value: StateObject<V>, callback: (V) -> O) -> Computed<O>,

	read Eventual: EventualConstructor,
	read Computed: ComputedConstructor,
	read Value: ValueConstructor,
	read Table: TableConstructor,

	read ForPairs: ForPairsConstructor,
	read ForKeys: ForKeysConstructor,
	read ForValues: ForValuesConstructor,

	read Timer: (scope: Scope) -> Timer,

	read Animated: AnimatedConstructor,
	read Tween: TweenConstructor,
	read Spring: SpringConstructor,
	read Delay: DelayConstructor,

	New: (
		scope: Scope,
		classNameOrTemplate: Instance | string
	) -> (props: Properties) -> Instance,
	read Hydrate: (scope: Scope, instance: Instance) -> (props: Properties) -> Instance,
	read Child: (
		scope: Scope,
		name: string
	) -> (props: Properties) -> (parent: Instance) -> Instance?,
	read ChildOfClass: (
		scope: Scope,
		className: string
	) -> (props: Properties) -> (parent: Instance) -> Instance?,
	read Descendant: (
		scope: Scope,
		name: string
	) -> (props: Properties) -> (parent: Instance) -> Instance?,
	read DescendantOfClass: (
		scope: Scope,
		className: string
	) -> (props: Properties) -> (parent: Instance) -> Instance?,

	-- Keys
	read Children: SpecialKey<"Children">,
	read Startup: SpecialKey<"Startup">,
	read Removal: SpecialKey<"Removal">,
	read Ref: SpecialKey<"Ref">,
	read Apply: SpecialKey<"Apply">,
	read Attribute: (attribute: string) -> SpecialKey<"Attribute">,
	read AttributeChange: (attribute: string) -> SpecialKey<"AttributeChange">,
	read AttributeOut: (attribute: string) -> SpecialKey<"AttributeOut">,
	read Tag: (tag: string) -> SpecialKey<"Tag">,
	read Out: (property: string) -> SpecialKey<"Out">,
	read OnChange: (property: string) -> SpecialKey<"OnChange">,
	read OnEvent: (event: string) -> SpecialKey<"OnEvent">,
}

return nil
