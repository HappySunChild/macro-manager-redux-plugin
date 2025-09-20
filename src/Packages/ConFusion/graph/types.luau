local memory = require "../memory/types"

export type Validity = "busy" | "invalid" | "valid"
export type Timeliness = "lazy" | "eager"

export type GraphObject = {
	type: string?,
	kind: string?,

	createdAt: number?,
	validity: Validity?,
	timeliness: Timeliness,

	_lastChange: number?,
	_lastCompute: number?,
	_users: { [GraphObject]: true },
	_using: { [GraphObject]: true },
	_observers: { [{}]: () -> () }?,

	_evaluate: (GraphObject) -> boolean,
} & memory.ScopedObject

return nil
