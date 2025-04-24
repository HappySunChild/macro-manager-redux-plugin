local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local applyProperties = require(package.Instance.applyProperties)

local function DescendantOfClass(scope: Types.Scope, className: string)
	return function(props: Types.Properties)
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

return DescendantOfClass
