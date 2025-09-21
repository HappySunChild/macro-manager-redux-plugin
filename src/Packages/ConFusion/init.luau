--[[
package: confusion-for-roblox

ConFusion - A fork of Fusion

GitHub Repository: https://github.com/HappySunChild/ConFusion
Fusion on GitHub: https://github.com/dphfox/Fusion
--]]

local async = require "@self/async/types"
local calc = require "@self/calc/types"
local chrono = require "@self/chrono/types"
local context = require "@self/context/types"
local graph = require "@self/graph/types"
local instances = require "@self/roblox-instances/types"
local memory = require "@self/memory/types"
local motion = require "@self/motion/types"
local pipeline = require "@self/pipeline/types"

export type Scope<T = ConFusion> = memory.Scope<T>

export type GraphObject = graph.GraphObject

export type StateObject<T> = calc.StateObject<T>
export type Value<V> = calc.Value<V>
export type Computed<V> = calc.Computed<V>
export type For<OK, OV> = calc.For<OK, OV>
export type Use = calc.Use
export type UsedAs<T> = calc.UsedAs<T>

export type Animated<T> = motion.Animated<T>

export type Eventual<T> = async.Eventual<T>

export type Contextual<T> = context.Contextual<T>

export type Timer = chrono.Timer

export type Pipe<T, S = unknown> = pipeline.Pipe<S, T>

export type SpecialKey<T = string> = instances.SpecialKey
export type Child = instances.Child

type ConFusion = {
	read version: {
		read major: number,
		read minor: number,
	},

	-- Memory
	read scoped: <B, M>(base: B, methods: M?) -> memory.Scope<B> & M,
	read deriveScope: <T, M>(existing: T, methods: M?) -> T & M,
	read innerScope: <T, M>(existing: T, methods: M?) -> T & M,
	read doCleanup: (action: memory.CleanupTask) -> (),
	read insert: <Tasks...>(scope: memory.Scope, Tasks...) -> Tasks...,

	-- State/Calculated State
	read Computed: calc.ComputedConstructor,
	read Value: calc.ValueConstructor,
	read ForPairs: calc.ForPairsConstructor,
	read ForKeys: calc.ForKeysConstructor,
	read ForValue: calc.ForValuesConstructor,

	-- Async
	read Eventual: async.EventualConstructor,
	read await: (subject: graph.GraphObject) -> (),

	-- Contextual
	read Contextual: context.ContextConstructor,

	-- Use
	read peek: calc.Use,
	read flatten: <T>(calc.Use, calc.UsedAs<T>) -> T,

	-- Graph
	read observe: (
		scope: memory.Scope,
		subject: graph.GraphObject,
		callback: () -> (),
		immediate: boolean?
	) -> () -> (),

	-- Chrono
	read Timer: chrono.TimerConstructor,

	-- Motion
	read Animated: motion.AnimatedConstructor,
	read Tween: motion.TweenConstructor,
	read Spring: motion.SpringConstructor,

	-- Pipeline
	read Pipe: pipeline.PipeConstructor,

	-- Instances
	read New: instances.NewConstructor,
	read FromTemplate: instances.FromTemplateConstructor,
	read Hydrate: instances.HydrateConstructor,
	read WithChild: instances.WithChildConstructor,
	read WithChildOfClass: instances.WithChildOfClassConstructor,
	read WithDescendant: instances.WithChildConstructor,
	read WithDescendantOfClass: instances.WithChildOfClassConstructor,

	read PropertyOf: instances.PropertyOfConstructor,
	read AttributeOf: instances.AttributeOfConstructor,

	read Children: instances.SpecialKey<"Children">,
	read OnStartup: instances.SpecialKey<"OnStartup">,
	read OnRemoval: instances.SpecialKey<"OnRemoval">,
	read Passthrough: instances.SpecialKey<"Passthrough">,
	read Ref: instances.SpecialKey<"Ref">,
	read Attribute: (attribute: string) -> instances.SpecialKey<"Attribute">,
	read AttributeChange: (attribute: string) -> instances.SpecialKey<"AttributeChange">,
	read AttributeOut: (attribute: string) -> instances.SpecialKey<"AttributeOut">,
	read Tag: (tag: string) -> instances.SpecialKey<"Tag">,
	read Out: (property: string) -> instances.SpecialKey<"Out">,
	read OnEvent: (event: string) -> instances.SpecialKey<"OnEvent">,
	read OnChange: (property: string) -> instances.SpecialKey<"OnChange">,
}

local External = require "@self/External"

local RobloxProvider = require "@self/RobloxProvider"
External.setProvider(RobloxProvider)

local ConFusion = table.freeze {
	version = table.freeze {
		major = 0,
		minor = 4,
	},

	-- Memory
	scoped = require "@self/memory/scoped",
	deriveScope = require "@self/memory/deriveScope",
	innerScope = require "@self/memory/innerScope",
	doCleanup = require "@self/memory/doCleanup",
	insert = require "@self/memory/insert",

	-- State/Calculated State
	Computed = require "@self/calc/Computed",
	Value = require "@self/calc/Value",
	ForPairs = require "@self/calc/ForPairs",
	ForKeys = require "@self/calc/ForKeys",
	ForValues = require "@self/calc/ForValues",

	-- Async
	Eventual = require "@self/async/Eventual",
	await = require "@self/async/await",

	-- Context
	Contextual = require "@self/context/Contextual",

	-- Use
	peek = require "@self/use/peek",
	flatten = require "@self/use/flatten",

	-- Graph
	observe = require "@self/graph/observe",

	-- Chrono
	Timer = require "@self/chrono/Timer",

	-- Motion
	Animated = require "@self/motion/Animated",
	Tween = require "@self/motion/Tween",
	Spring = require "@self/motion/Spring",

	-- Pipeline
	Pipe = require "@self/pipeline/Pipe",

	-- Instances
	New = require "@self/roblox-instances/New",
	Hydrate = require "@self/roblox-instances/Hydrate",
	WithChild = require "@self/roblox-instances/WithChild",
	WithChildOfClass = require "@self/roblox-instances/WithChildOfClass",
	WithDescendant = require "@self/roblox-instances/WithDescendant",
	WithDescendantOfClass = require "@self/roblox-instances/WithDescendantOfClass",

	PropertyOf = require "@self/roblox-instances/PropertyOf",
	AttributeOf = require "@self/roblox-instances/AttributeOf",

	-- Instance Keys
	Children = require "@self/roblox-instances/keys/Children",
	OnStartup = require "@self/roblox-instances/keys/OnStartup",
	OnRemoval = require "@self/roblox-instances/keys/OnRemoval",
	Passthrough = require "@self/roblox-instances/keys/Passthrough",
	Ref = require "@self/roblox-instances/keys/Ref",
	Attribute = require "@self/roblox-instances/keys/Attribute",
	AttributeChange = require "@self/roblox-instances/keys/AttributeChange",
	AttributeOut = require "@self/roblox-instances/keys/AttributeOut",
	Tag = require "@self/roblox-instances/keys/Tag",
	Out = require "@self/roblox-instances/keys/Out",
	OnEvent = require "@self/roblox-instances/keys/OnEvent",
	OnChange = require "@self/roblox-instances/keys/OnChange",
}

return ConFusion :: ConFusion
