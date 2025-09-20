local calc = require "../calc/types"
local instances = require "./types"
local memory = require "../memory/types"

local External = require "../External"

local Parent = require "./keys/_Parent"
local sortKeys = require "./keys/sortKeys"

local castToState = require "../calc/castToState"

local peek = require "../use/peek"

local observe = require "../graph/observe"

local parseError = require "../logging/parseError"

local kindof = require "../kindof"
local xtypeof = require "../xtypeof"

local function rawSetProperty(instance: Instance, property: string, value: any)
	instance[property] = value
end

local function testProperty(instance: Instance, property: string)
	instance[property] = instance[property]
end

local function setProperty(instance: Instance, property: string, value: any)
	local success, err = xpcall(rawSetProperty, parseError, instance, property, value)

	if not success then
		if not pcall(testProperty, instance, property) then
			External.logErrorNonFatal(
				"propertyCannotAssign",
				nil,
				instance.ClassName,
				property
			)
		else
			local givenType = typeof(value)
			local expectedType = typeof(instance[property])

			if givenType == expectedType then
				External.logErrorNonFatal("propertyAssignError", err)
			else
				External.logErrorNonFatal(
					"propertyInvalidType",
					nil,
					instance.ClassName,
					property,
					expectedType,
					givenType
				)
			end
		end
	end
end

local function applyProperty(
	scope: memory.Scope,
	instance: Instance,
	property: string,
	value: calc.UsedAs<any>
)
	if castToState(value) then
		observe(scope, value, function()
			setProperty(instance, property, peek(value))
		end, true)

		return
	end

	setProperty(instance, property, value)
end

local function applyProperties<T>(
	scope: memory.Scope<T>,
	instance: Instance,
	props: instances.Properties
)
	props = table.clone(props)

	local specialKeys: { instances.SpecialKey } = {}

	props[Parent] = props.Parent
	props.Parent = nil

	for key, value in props do
		local keyType = xtypeof(key)

		if keyType == "string" then
			applyProperty(scope, instance, key, value)
		elseif kindof(key) == "key" then
			table.insert(specialKeys, key)
		end
	end

	table.sort(specialKeys, sortKeys)

	for _, key in specialKeys do
		key.apply(scope, instance, props[key])
	end
end

return applyProperties
