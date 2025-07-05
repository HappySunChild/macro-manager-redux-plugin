local External = require "../../External"
local Types = require "../../Types"

local SpecialKey = require "./SpecialKey"

local keyCache = {}

local function OnChange(property: string): Types.SpecialKey<"OnChange">
	local key = keyCache[property]

	if not key then
		key = SpecialKey "OnChange" {
			stage = "observer",
			apply = function(
				scope: Types.Scope,
				applyTo: Instance,
				callback: (any) -> ()
			)
				local ok, event =
					pcall(applyTo.GetPropertyChangedSignal, applyTo, property)

				if not ok then
					External.logError(
						"cannotConnectChange",
						nil,
						applyTo.ClassName,
						property
					)
				end

				table.insert(
					scope,
					event:Connect(function()
						callback(applyTo[property])
					end)
				)
			end,
		}

		keyCache[property] = key
	end

	return key
end

return OnChange
