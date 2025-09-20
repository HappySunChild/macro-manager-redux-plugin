local instances = require "./types"
local memory = require "../memory/types"

local External = require "../External"

local applyProperties = require "./applyProperties"

local function WithChild(scope: memory.Scope, name: string)
	return function(props: instances.Properties)
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
