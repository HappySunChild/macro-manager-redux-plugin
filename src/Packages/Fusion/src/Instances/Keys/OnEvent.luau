local External = require "../../External"
local Types = require "../../Types"

local SpecialKey = require "./SpecialKey"

local function getProperty(instance: Instance, key: string)
	return instance[key]
end

local keyCache = {}

local function OnEvent(eventName: string): Types.SpecialKey<"OnEvent">
	local key = keyCache[eventName]

	if not key then
		key = SpecialKey "OnEvent" {
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
