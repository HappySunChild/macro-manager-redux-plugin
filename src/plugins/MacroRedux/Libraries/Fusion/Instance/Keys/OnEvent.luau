local package = script.Parent.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local function getProperty(instance: Instance, key: string)
	return instance[key]
end

local keyCache = {}

local function OnEvent(eventName: string): Types.SpecialKey
	local key = keyCache[eventName]

	if not key then
		key = table.freeze {
			type = "OnEvent",
			kind = "key",
			stage = "observer",

			apply = function(scope: Types.Scope, applyTo: Instance, callback)
				local ok, event = pcall(getProperty, applyTo, eventName)

				if not ok or typeof(event) ~= "RBXScriptSignal" then
					External.logError(
						"cannotConnectEvent",
						nil,
						applyTo.ClassName,
						eventName
					)
				end

				table.insert(scope, event:Connect(callback))
			end,
		}

		keyCache[eventName] = key
	end

	return key
end

return OnEvent
