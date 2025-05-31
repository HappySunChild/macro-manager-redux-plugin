local package = script.Parent.Parent.Parent

local Types = require(package.Types)

export type SubObject<S, IK, IV, OK, OV> = {
	scope: Types.Scope<S>?,
	inputKey: IK,
	inputValue: IV,
	roamKeys: boolean,
	roamValues: boolean,
	invalidateInputKey: (SubObject<S, IK, IV, OK, OV>) -> (),
	invalidateInputValue: (SubObject<S, IK, IV, OK, OV>) -> (),
	useOutputPair: (SubObject<S, IK, IV, OK, OV>, Types.Use) -> (OK?, OV?),
}

export type Disassembly<S, IK, IV, OK, OV> = Types.GraphObject & {
	populate: (Disassembly<S, IK, IV, OK, OV>, Types.Use, output: { [OK]: OV }) -> (),
}

return nil
