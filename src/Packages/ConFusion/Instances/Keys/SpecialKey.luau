local Types = require "../../Types"

type SpecialKeyProperties = {
	stage: Types.SpecialKeyStage,
	apply: (scope: Types.Scope, applyTo: Instance, ...any) -> (),
}

local function SpecialKey(name: string)
	return function(props: SpecialKeyProperties): Types.SpecialKey
		local newKey = table.freeze {
			type = name,
			kind = "key",

			stage = props.stage,
			apply = props.apply,
		}

		return newKey
	end
end

return SpecialKey
