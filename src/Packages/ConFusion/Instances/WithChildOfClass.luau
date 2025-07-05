local External = require "../External"
local Types = require "../Types"

local applyProperties = require "./applyProperties"

local function WithChildOfClass(scope: Types.Scope, className: string)
	return function(props: Types.Properties)
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
