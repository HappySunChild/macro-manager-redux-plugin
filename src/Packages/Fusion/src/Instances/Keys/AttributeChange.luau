local Types = require "../../Types"

local SpecialKey = require "./SpecialKey"

local keyCache = {}

local function AttributeChange(attribute: string): Types.SpecialKey<"AttributeChange">
	local key = keyCache[attribute]

	if not key then
		key = SpecialKey "AttributeChanged" {
			stage = "observer",
			apply = function(
				scope: Types.Scope,
				applyTo: Instance,
				callback: (any) -> ()
			)
				local event = applyTo:GetAttributeChangedSignal(attribute)

				table.insert(
					scope,
					event:Connect(function()
						callback(applyTo:GetAttribute(attribute))
					end)
				)
			end,
		}

		keyCache[attribute] = key
	end

	return key
end

return AttributeChange
