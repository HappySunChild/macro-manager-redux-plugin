local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local observe = require(package.Graph.observe)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

local keyCache = {}

local function Attribute(attribute: string): Types.SpecialKey
	local key = keyCache[attribute]

	if not key then
		key = table.freeze {
			type = "Attribute",
			kind = "key",
			stage = "self",

			apply = function(_: Types.Scope, applyTo: Instance, value: Types.UsedAs<any>)
				if castToState(value) then
					observe(value, function()
						applyTo:SetAttribute(attribute, peek(value))
					end)
				end

				applyTo:SetAttribute(attribute, peek(value))
			end,
		}

		keyCache[attribute] = key
	end

	return key
end

return Attribute
