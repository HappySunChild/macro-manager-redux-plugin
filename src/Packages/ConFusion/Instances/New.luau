local External = require "../External"
local Types = require "../Types"

local applyProperties = require "./applyProperties"
local defaultProperties = require "./defaultProperties"

local function New<T>(
	scope: Types.Scope<T>,
	classNameOrTemplate: string | Instance
): (props: Types.Properties) -> Instance
	local instance

	if typeof(classNameOrTemplate) == "Instance" then
		instance = classNameOrTemplate:Clone()

		if not instance then
			External.logError(
				"cannotCreateTemplate",
				nil,
				classNameOrTemplate:GetFullName()
			)
		end
	else
		local success, newInstance = pcall(Instance.new, classNameOrTemplate)

		if not success then
			External.logError("cannotCreateClass", nil, classNameOrTemplate)
		end

		local classProps = defaultProperties[classNameOrTemplate]

		if classProps then
			for key, value in classProps do
				newInstance[key] = value
			end
		end

		instance = newInstance
	end

	return function(props: Types.Properties): Instance
		table.insert(scope, instance)

		applyProperties(scope, instance, props)

		return instance
	end
end

return New
