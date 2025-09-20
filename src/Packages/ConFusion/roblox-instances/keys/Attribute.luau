local calc = require "../../calc/types"
local instances = require "../types"
local memory = require "../../memory/types"

local observe = require "../../graph/observe"

local castToState = require "../../calc/castToState"

local peek = require "../../use/peek"

local SpecialKey = require "./SpecialKey"

local keyCache = {}

local function Attribute(attribute: string): instances.SpecialKey<"Attribute">
	local key = keyCache[attribute]

	if not key then
		key = SpecialKey "Attribute" {
			stage = "self",
			apply = function(
				scope: memory.Scope,
				applyTo: Instance,
				value: calc.UsedAs<any>
			)
				if castToState(value) then
					observe(scope, value, function()
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
