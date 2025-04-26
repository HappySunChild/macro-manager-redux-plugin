local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local applyProperties = require(package.Instance.applyProperties)

local function Descendant(scope: Types.Scope, name: string)
	return function(props: Types.Properties)
		return function(parent: Instance)
			local child = parent:FindFirstChild(name, true)

			if not child then
				External.logErrorNonFatal("missingDescendant", nil, name, parent.Name)

				return
			end

			applyProperties(scope, child, props)

			return child
		end
	end
end

return Descendant
