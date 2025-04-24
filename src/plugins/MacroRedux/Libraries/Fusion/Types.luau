--!strict

type Disconnect = () -> ()

export type Properties = { [SpecialKey | string]: any }

export type Task =
	Instance
	| RBXScriptConnection
	| () -> ()
	| { destroy: (any) -> () }
	| { Destroy: (any) -> () }
	| { Task }
export type Scope<T = unknown> = { Task } & T

export type Child = Instance | ((Instance) -> Instance?) | { Child } | UsedAs<Child>
export type UsedAs<V> = StateObject<V> | V
export type Use = <V>(target: StateObject<V>) -> V

export type MoverStepper<V> = (elapsed: number) -> (boolean, V)
export type AnimatedMover<V> = (start: V, goal: V) -> MoverStepper<V>

export type Error = {
	type: "Error",
	raw: string,
	message: string,
	trace: string,
}

-- Objects

type Observer = {
	type: "Observer",
	kind: "observer",

	createdAt: number,
	callback: () -> (),
}

export type ScopedObject = {
	scope: Scope<unknown>,
}

export type GraphObject = ScopedObject & {
	type: string?,
	kind: string?,

	createdAt: number?,
	validity: string?,
	timeliness: "lazy" | "eager",

	_lastChange: number?,
	_users: { [GraphObject]: true },
	_using: { [GraphObject]: true },
	_observers: { [{}]: Observer }?,

	_evaluate: (GraphObject) -> boolean,
}

-- State

export type StateObject<V> = GraphObject & {
	_internalValue: V,

	kind: "state",
	type: string,
}

export type Computed<V> = StateObject<V> & {
	type: "Computed",
}

export type Value<V> = StateObject<V> & {
	type: "Value",

	set: (Value<V>, newValue: V) -> V,
	update: (Value<V>, predicate: (V) -> V) -> V,

	bindToInstanceProperty: (
		Value<V>,
		instance: Instance,
		property: string
	) -> Disconnect,
}

export type Eventual<V> = StateObject<V> & {
	type: "Eventual",
}

export type Table<K, V> = StateObject<{ [K]: V }> & {
	type: "Table",

	setKey: (Table<K, V>, key: K, value: V) -> V,
	getKey: (Table<K, V>, key: K) -> V,

	insert: (Table<K, V>, index: number, value: V) -> V,
	remove: (Table<K, V>, index: number) -> V,
}

export type For<OK, OV> = StateObject<{ [OK]: OV }> & {
	type: "For",
}

-- Animation

export type Timer = StateObject<number> & {
	type: "Timer",

	pause: (Timer) -> (),
	unpause: (Timer) -> (),
	reset: (Timer) -> (),
}

export type Animated<V> = StateObject<V> & {
	type: "Animated",
}

-- Extra

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
	scoped: <B, M>(base: B, methods: M?) -> Scope<B> & M,
	deriveScope: <T, M>(existing: T, methods: M?) -> T & M,
	innerScope: <T, M>(existing: T, methods: M?) -> T & M,
	doCleanup: (Task) -> (),

	peek: <V>(value: UsedAs<V> | V) -> V,
	observe: <V>(
		value: StateObject<V>,
		callback: () -> (),
		immediate: boolean?
	) -> Disconnect,
	map: <V>(value: StateObject<V>, callback: (V) -> any?) -> Computed<V>,

	Eventual: <S, V>(
		scope: Scope<S>,
		processor: (use: Use, become: (V) -> ()) -> (),
		default: V
	) -> Eventual<V>,
	Computed: <S, V>(
		scope: Scope<S>,
		processor: (use: Use, scope: Scope<S>) -> V
	) -> Computed<V>,
	Value: <V>(scope: Scope, initialValue: V) -> Value<V>,
	Table: <K, V>(scope: Scope, initialValue: { [K]: V }) -> Table<K, V>,

	ForPairs: <S, IK, IV, OK, OV>(
		scope: Scope<S>,
		inputTable: UsedAs<{ [IK]: IV }>,
		processor: (use: Use, scope: Scope<S>, key: IK, value: IV) -> (OK, OV)
	) -> For<OK, OV>,
	ForKeys: <S, IK, IV, OK>(
		scope: Scope<S>,
		inputTable: UsedAs<{ [IK]: IV }>,
		processor: (use: Use, scope: Scope<S>, key: IK) -> OK
	) -> For<OK, IV>,
	ForValues: <S, IK, IV, OV>(
		scope: Scope<S>,
		inputTable: UsedAs<{ [IK]: IV }>,
		processor: (use: Use, scope: Scope<S>, value: IV) -> OV
	) -> For<IK, OV>,

	Timer: (scope: Scope) -> Timer,
	Animated: <V>(scope: Scope, goal: UsedAs<V>, mover: AnimatedMover<V>) -> Animated<V>,
	Tween: <V>(scope: Scope, goal: UsedAs<V>, info: UsedAs<TweenInfo>) -> Animated<V>,
	Spring: <V>(
		scope: Scope,
		goal: UsedAs<V>,
		speed: UsedAs<number>,
		damping: UsedAs<number>
	) -> Animated<V>,
	Delay: <V>(scope: Scope, goal: UsedAs<V>, delay: UsedAs<number>) -> Animated<V>,

	New: (
		scope: Scope,
		classNameOrTemplate: Instance | string
	) -> (props: Properties) -> Instance,
	Child: (
		scope: Scope,
		name: string
	) -> (props: Properties) -> (parent: Instance) -> Instance?,
	ChildOfClass: (
		scope: Scope,
		className: string
	) -> (props: Properties) -> (parent: Instance) -> Instance?,
	Descendant: (
		scope: Scope,
		name: string
	) -> (props: Properties) -> (parent: Instance) -> Instance?,
	DescendantOfClass: (
		scope: Scope,
		className: string
	) -> (props: Properties) -> (parent: Instance) -> Instance?,

	Children: SpecialKey<"Children">,
	Startup: SpecialKey<"Startup">,
	Removal: SpecialKey<"Removal">,
	Ref: SpecialKey<"Ref">,
	Apply: SpecialKey<"Apply">,
	Attribute: (attribute: string) -> SpecialKey<"Attribute">,
	AttributeChange: (attribute: string) -> SpecialKey<"AttributeChange">,
	AttributeOut: (attribute: string) -> SpecialKey<"AttributeOut">,
	Tag: (tag: string) -> SpecialKey<"Tag">,
	Out: (property: string) -> SpecialKey<"Out">,
	OnChange: (property: string) -> SpecialKey<"OnChange">,
	OnEvent: (event: string) -> SpecialKey<"OnEvent">,

	setProvider: (newProvider: ExternalProvider?) -> ExternalProvider?,
}

return nil
