local instances = require "./types"
local memory = require "../memory/types"

local destructor = require "../memory/destructor"

local change = require "../graph/change"

local class = table.freeze {
	type = "AttributeOf",
	kind = "state",
	timeliness = "lazy",
	_using = table.freeze {},

	_evaluate = function()
		return true
	end,
}
local METATABLE = table.freeze { __index = class }

local function AttributeOf(
	scope: memory.Scope,
	instance: Instance,
	attribute: string
): instances.AttributeOf<unknown>
	local event = instance:GetAttributeChangedSignal(attribute)

	local newAttribute: instances.AttributeOf<unknown> = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_users = {},

		_internvalValue = instance:GetAttribute(attribute),
	}, METATABLE) :: any

	table.insert(scope, {
		destructor(newAttribute),
		event:Connect(function()
			newAttribute._internalValue = instance:GetAttribute(attribute)

			change(newAttribute)
		end),
	})

	return newAttribute
end

return AttributeOf
