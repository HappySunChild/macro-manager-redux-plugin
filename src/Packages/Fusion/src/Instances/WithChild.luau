local External = require "../External"
local Types = require "../Types"

local applyProperties = require "./applyProperties"

local function WithChild(scope: Types.Scope, name: string)
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

return WithChild
