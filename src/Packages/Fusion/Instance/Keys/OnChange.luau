local package = script.Parent.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local keyCache = {}

local function OnChange(property: string)
	local key = keyCache[property]

	if not key then
		key = table.freeze {
			type = "OnChange",
			kind = "key",
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
