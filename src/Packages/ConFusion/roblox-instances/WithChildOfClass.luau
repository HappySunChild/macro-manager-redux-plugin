local instances = require "./types"
local memory = require "../memory/types"

local External = require "../External"

local applyProperties = require "./applyProperties"

local function WithChildOfClass(scope: memory.Scope, className: string)
	return function(props: instances.Properties)
		return function(parent: Instance)
			local child = parent:FindFirstChildWhichIsA(className)

			if not child then
				External.logErrorNonFatal(
					"missingChildClass",
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

return WithChildOfClass
