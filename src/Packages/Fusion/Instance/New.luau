local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local applyProperties = require(package.Instance.applyProperties)
local defaultProperties = require(package.Instance.defaultProperties)

local function New<T>(scope: Types.Scope<T>, classNameOrTemplate: string | Instance)
	local instance

	if typeof(classNameOrTemplate) == "Instance" then
		instance = classNameOrTemplate:Clone()

		if not instance then
			External.logError(
				"cannotCreateTemplate",
				nil,
				classNameOrTemplate:GetFullName()
			)

			return
		end
	else
		local success, newInstance = pcall(Instance.new, classNameOrTemplate)

		if not success then
			External.logError("cannotCreateClass", nil, classNameOrTemplate)

			return
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
