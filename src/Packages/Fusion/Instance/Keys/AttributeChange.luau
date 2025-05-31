local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local keyCache = {}

local function AttributeChange(attribute: string): Types.SpecialKey
	local key = keyCache[attribute]

	if not key then
		key = table.freeze {
			type = "OnChanged",
			kind = "key",
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
