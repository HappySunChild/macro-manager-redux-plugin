local instances = require "./types"
local memory = require "../memory/types"

local External = require "../External"

local applyProperties = require "./applyProperties"

local function WithDescendantOfClass(scope: memory.Scope, className: string)
	return function(props: instances.Properties)
		return function(parent: Instance)
			local child = parent:FindFirstChildWhichIsA(className, true)

			if not child then
				External.logErrorNonFatal(
					"missingDescendantClass",
					nil,
					className,
					parent.Name
				)

				return
			end

			applyProperties(scope, child, props)

			return child
		end
	end
end

return WithDescendantOfClass
