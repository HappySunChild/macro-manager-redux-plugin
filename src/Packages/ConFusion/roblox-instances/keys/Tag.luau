local calc = require "../../calc/types"
local instances = require "../types"
local memory = require "../../memory/types"

local observe = require "../../graph/observe"

local castToState = require "../../calc/castToState"

local peek = require "../../use/peek"

local SpecialKey = require "./SpecialKey"

local keyCache = {}

local function Tag(tag: string): instances.SpecialKey<"Tag">
	local key = keyCache[tag]

	if not key then
		key = SpecialKey "Tag" {
			stage = "self",
			apply = function(
				scope: memory.Scope,
				instance: Instance,
				enabled: calc.UsedAs<boolean>
			)
				if castToState(enabled) then
					observe(scope, enabled, function()
						local value = peek(enabled)

						if value == true then
							instance:AddTag(tag)
						elseif instance:HasTag(tag) then
							instance:RemoveTag(tag)
						end
					end)
				end

				if peek(enabled) then
					instance:AddTag(tag)
				end
			end,
		}

		keyCache[tag] = key
	end

	return key
end

return Tag
