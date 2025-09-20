local calc = require "../../calc/types"
local memory = require "../../memory/types"

export type SubObject<S, IK, IV, OK, OV> = {
	scope: memory.Scope<S>?,
	inputKey: IK,
	inputValue: IV,
	roamKeys: boolean,
	roamValues: boolean,
	invalidateInputKey: (SubObject<S, IK, IV, OK, OV>) -> (),
	invalidateInputValue: (SubObject<S, IK, IV, OK, OV>) -> (),
	useOutputPair: (SubObject<S, IK, IV, OK, OV>, calc.Use) -> (OK?, OV?),
}

export type Disassembly<S, IK, IV, OK, OV> = calc.StateObject<{ [OK]: OV }> & {
	populate: (Disassembly<S, IK, IV, OK, OV>, calc.Use, output: { [OK]: OV }) -> (),
}

return nil
