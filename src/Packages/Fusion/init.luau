--!strict

--[[
ConFusion - A fork of Fusion

GitHub Repository: https://github.com/HappySunChild/ConFusion
Fusion: https://github.com/dphfox/Fusion
--]]

local External = require "@self/External"
local Types = require "@self/Types"

type Fusion = Types.Fusion

export type Scope<Constructors = Fusion> = Types.Scope<Constructors>
export type UsedAs<V> = Types.UsedAs<V>
export type Use = Types.Use

export type SpecialKey<T> = Types.SpecialKey<T>

export type ScopedObject = Types.ScopedObject
export type GraphObject = Types.GraphObject
export type StateObject<V> = Types.StateObject<V>

export type Animated<V> = Types.Animated<V>
export type Value<V> = Types.Value<V>
export type Computed<V> = Types.Computed<V>
export type For<K, V> = Types.For<K, V>
export type Observer = Types.Observer

export type Child = Types.Child

local Fusion = table.freeze {
	-- Memory
	scoped = require "@self/Memory/scoped",
	deriveScope = require "@self/Memory/deriveScope",
	innerScope = require "@self/Memory/innerScope",
	doCleanup = require "@self/Memory/doCleanup",

	-- State
	Eventual = require "@self/State/Eventual",
	Computed = require "@self/State/Computed",
	Value = require "@self/State/Value",
	Table = require "@self/State/Table",
	ForPairs = require "@self/State/ForPairs",
	ForKeys = require "@self/State/ForKeys",
	ForValues = require "@self/State/ForValues",
	peek = require "@self/State/peek",

	map = require "@self/Utility/map",
	flatten = require "@self/Utility/flatten",

	Observer = require "@self/Graph/Observer",

	-- Animation
	Timer = require "@self/Animation/Timer",
	Animated = require "@self/Animation/Animated",
	Tween = require "@self/Animation/Tween",
	Spring = require "@self/Animation/Spring",
	Delay = require "@self/Animation/Delay",

	-- Instance
	New = require "@self/Instances/New",
	Hydrate = require "@self/Instances/Hydrate",
	WithChild = require "@self/Instances/WithChild",
	WithChildOfClass = require "@self/Instances/WithChildOfClass",
	WithDescendant = require "@self/Instances/WithDescendant",
	WithDescendantOfClass = require "@self/Instances/WithDescendantOfClass",

	-- Instance Keys
	Children = require "@self/Instances/Keys/Children",
	OnStartup = require "@self/Instances/Keys/OnStartup",
	OnRemoval = require "@self/Instances/Keys/OnRemoval",
	Ref = require "@self/Instances/Keys/Ref",
	Passthrough = require "@self/Instances/Keys/Passthrough",
	Attribute = require "@self/Instances/Keys/Attribute",
	AttributeChange = require "@self/Instances/Keys/AttributeChange",
	AttributeOut = require "@self/Instances/Keys/AttributeOut",
	Tag = require "@self/Instances/Keys/Tag",
	Out = require "@self/Instances/Keys/Out",
	OnEvent = require "@self/Instances/Keys/OnEvent",
	OnChange = require "@self/Instances/Keys/OnChange",

	-- External
	setProvider = External.setProvider,
}

local RobloxProvider = require "@self/RobloxProvider"
External.setProvider(RobloxProvider)

return Fusion :: Fusion
