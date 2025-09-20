local calc = require "../calc/types"
local memory = require "../memory/types"

export type ExternalTime = calc.StateObject<number> & {
	type: "ExternalTime",

	setActive: (ExternalTime, active: boolean) -> (),
	isActive: (ExternalTime) -> boolean,
}

export type Timer = calc.StateObject<number> & {
	type: "Timer",

	pause: (Timer) -> (),
	unpause: (Timer) -> (),
	reset: (Timer) -> (),
}
export type TimerConstructor = (scope: memory.Scope) -> Timer

return nil
