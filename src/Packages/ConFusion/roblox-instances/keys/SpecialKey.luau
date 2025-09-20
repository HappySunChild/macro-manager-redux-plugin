local instances = require "../types"
local memory = require "../../memory/types"

type SpecialKeyProperties = {
	stage: instances.SpecialKeyStage,
	apply: (scope: memory.Scope, applyTo: Instance, ...any) -> (),
}

local function SpecialKey(name: string)
	return function(props: SpecialKeyProperties): instances.SpecialKey
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
