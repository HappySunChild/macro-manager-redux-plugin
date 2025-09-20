local instances = require "./types"
local memory = require "../memory/types"

local External = require "../External"

local destructor = require "../memory/destructor"

local change = require "../graph/change"

local class = table.freeze {
	type = "PropertyOf",
	kind = "state",
	timeliness = "lazy",
	_using = table.freeze {},

	_evaluate = function()
		return true
	end,
}
local METATABLE = table.freeze { __index = class }

local function PropertyOf(
	scope: memory.Scope,
	instance: Instance,
	property: string
): instances.PropertyOf<unknown>
	local ok, event: RBXScriptSignal =
		pcall(instance.GetPropertyChangedSignal, instance, property)

	if not ok then
		External.logError(
			"cannotConnectChange",
			nil,
			instance.ClassName,
			tostring(property)
		)
	end

	local newProperty: instances.PropertyOf<unknown> = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_users = {},

		_internalValue = instance[property],
	}, METATABLE) :: any

	table.insert(scope, {
		destructor(newProperty),
		event:Connect(function()
			newProperty._internalValue = instance[property]

			change(newProperty)
		end),
	})

	return newProperty
end

return PropertyOf
