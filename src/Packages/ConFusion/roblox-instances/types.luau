local calc = require "../calc/types"
local memory = require "../memory/types"

export type SpecialKeyStage =
	"self"
	| "descendants"
	| "properties"
	| "ancestor"
	| "observer"
	| "last"

export type SpecialKey<T = string> = {
	type: T,
	kind: "key",
	stage: SpecialKeyStage,

	apply: (scope: memory.Scope, instance: Instance, value: any) -> (),
}

export type Properties = {
	[SpecialKey]: any,
}

export type Child =
	Instance
	| ((Instance) -> Instance?)
	| { Child }
	| calc.StateObject<Child>

export type NewConstructor = (
	scope: memory.Scope,
	className: string
) -> (Properties) -> Instance
export type FromTemplateConstructor = <InstanceT>(
	scope: memory.Scope,
	template: InstanceT
) -> (Properties) -> InstanceT
export type HydrateConstructor = <InstanceT>(
	scope: memory.Scope,
	instance: InstanceT
) -> (Properties) -> InstanceT

export type WithChildConstructor = (
	scope: memory.Scope,
	name: string
) -> (Properties) -> (parent: Instance) -> Instance?
export type WithChildOfClassConstructor = (
	scope: memory.Scope,
	className: string
) -> (Properties) -> (parent: Instance) -> Instance?

export type PropertyOf<V> = calc.StateObject<V> & {
	type: "PropertyOf",
}
export type AttributeOf<V> = calc.StateObject<V> & {
	type: "AttributeOf",
}

export type PropertyOfConstructor = (
	scope: memory.Scope,
	instance: Instance,
	property: string
) -> PropertyOf<unknown>
export type AttributeOfConstructor = (
	scope: memory.Scope,
	instance: Instance,
	attribute: string
) -> AttributeOf<unknown>

return nil
