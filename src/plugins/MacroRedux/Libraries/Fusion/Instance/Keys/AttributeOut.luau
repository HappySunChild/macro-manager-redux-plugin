local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local xtypeof = require(package.Utility.xtypeof)

local keyCache = {}

local function AttributeOut(attribute: string): Types.SpecialKey
	local key = keyCache[attribute]

	if not key then
		key = table.freeze {
			type = "Out",
			kind = "key",
			stage = "observer",

			apply = function(
				scope: Types.Scope,
				applyTo: Instance,
				value: Types.Value<any>
			)
				if xtypeof(value) ~= "Value" then
					return error(`Invalid Out type.`, 2)
				end

				local event = applyTo:GetAttributeChangedSignal(attribute)

				table.insert(
					scope,
					event:Connect(function()
						value:set(applyTo:GetAttribute(attribute))
					end)
				)

				return
			end,
		}

		keyCache[attribute] = key
	end

	return key
end

return AttributeOut
