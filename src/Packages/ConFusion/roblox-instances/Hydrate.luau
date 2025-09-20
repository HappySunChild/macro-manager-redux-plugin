local instances = require "./types"
local memory = require "../memory/types"

local applyProperties = require "./applyProperties"

local function Hydrate<InstanceT>(
	scope: memory.Scope,
	instance: InstanceT
): (props: instances.Properties) -> InstanceT
	return function(props: instances.Properties)
		table.insert(scope, instance)

		applyProperties(scope, instance, props)

		return instance
	end
end

return Hydrate
