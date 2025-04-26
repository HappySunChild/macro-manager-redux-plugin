--!strict

--[[
ConFusion - A fork of Fusion

GitHub Repository: https://github.com/HappySunChild/ConFusion
Fusion: https://github.com/dphfox/Fusion
--]]

local External = require(script.External)
local Types = require(script.Types)

type Fusion = Types.Fusion

export type Scope<Constructors = Fusion> = Types.Scope<Constructors>
export type UsedAs<V> = Types.UsedAs<V>

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

local Animation = script.Animation
local Graph = script.Graph
local State = script.State
local Memory = script.Memory
local Utility = script.Utility

local Instance = script.Instance
local Keys = Instance.Keys

local Fusion = table.freeze {
	-- Memory
	scoped = require(Memory.scoped),
	deriveScope = require(Memory.deriveScope),
	innerScope = require(Memory.innerScope),
	doCleanup = require(Memory.doCleanup),

	-- State
	Eventual = require(State.Eventual),
	Computed = require(State.Computed),
	Value = require(State.Value),
	Table = require(State.Table),
	ForPairs = require(State.ForPairs),
	ForKeys = require(State.ForKeys),
	ForValues = require(State.ForValues),

	peek = require(State.peek),
	map = require(Utility.map),

	observe = require(Graph.observe),

	-- Animation
	Timer = require(Animation.Timer),
	Animated = require(Animation.Animated),
	Tween = require(Animation.Tween),
	Spring = require(Animation.Spring),
	Delay = require(Animation.Delay),

	-- Instance
	New = require(Instance.New),
	Hydrate = require(Instance.Hydrate),
	Child = require(Instance.Child),
	ChildOfClass = require(Instance.ChildOfClass),
	Descendant = require(Instance.Descendant),
	DescendantOfClass = require(Instance.DescendantOfClass),

	-- Instance Keys
	Children = require(Keys.Children),
	Startup = require(Keys.Startup),
	Removal = require(Keys.Removal),
	Ref = require(Keys.Ref),
	Apply = require(Keys.Apply),
	Attribute = require(Keys.Attribute),
	AttributeChange = require(Keys.AttributeChange),
	AttributeOut = require(Keys.AttributeOut),
	Tag = require(Keys.Tag),
	Out = require(Keys.Out),
	OnEvent = require(Keys.OnEvent),
	OnChange = require(Keys.OnChange),

	-- External
	setProvider = External.setProvider,
}

local RobloxProvider = require(script.RobloxProvider)
External.setProvider(RobloxProvider)

return Fusion :: Fusion
