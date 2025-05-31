local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local applyProperties = require(package.Instance.applyProperties)

local function Child(scope: Types.Scope, name: string)
	return function(props: Types.Properties)
		return function(parent: Instance)
			local child = parent:FindFirstChild(name)

			if not child then
				External.logErrorNonFatal("missingChild", nil, name, parent.Name)

				return
			end

			applyProperties(scope, child, props)

			return child
		end
	end
end

return Child
