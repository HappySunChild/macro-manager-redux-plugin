local package = script.Parent.Parent

local Types = require(package.Types)

local applyProperties = require(package.Instance.applyProperties)

local function Hydrate(scope: Types.Scope, instance: Instance)
	return function(props: Types.Properties)
		table.insert(scope, instance)

		applyProperties(scope, instance, props)

		return instance
	end
end

return Hydrate
