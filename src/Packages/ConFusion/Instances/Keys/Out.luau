local Types = require "../../Types"

local xtypeof = require "../../Utility/xtypeof"

local SpecialKey = require "./SpecialKey"

local keyCache = {}

local function Out(property: string): Types.SpecialKey<"Out">
	local key = keyCache[property]

	if not key then
		key = SpecialKey "Out" {
			stage = "observer",
			apply = function(
				scope: Types.Scope,
				applyTo: Instance,
				value: Types.Value<any>
			)
				if xtypeof(value) ~= "Value" then
					return error(`Invalid Out type.`, 2)
				end

				local event = applyTo:GetPropertyChangedSignal(property)

				table.insert(
					scope,
					event:Connect(function()
						value:set(applyTo[property])
					end)
				)

				return
			end,
		}

		keyCache[property] = key
	end

	return key
end

return Out
