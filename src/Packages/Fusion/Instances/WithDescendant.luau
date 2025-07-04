local External = require "../External"
local Types = require "../Types"

local applyProperties = require "./applyProperties"

local function WithDescendant(scope: Types.Scope, name: string)
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

return WithDescendant
