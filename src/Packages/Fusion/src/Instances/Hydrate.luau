local Types = require "../Types"

local applyProperties = require "./applyProperties"

local function Hydrate(
	scope: Types.Scope,
	instance: Instance
): (props: Types.Properties) -> Instance
	return function(props: Types.Properties)
		table.insert(scope, instance)

		applyProperties(scope, instance, props)

		return instance
	end
end

return Hydrate
