-- this is ridiculous... how is this still not a feature??
-- bump this post RIGHT NOW!
-- https://devforum.roblox.com/t/allow-plugins-to-use-color-picker/63257/

local PluginShared = require "@plugin/Shared"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local Widget = require "@self/Widget"

local peek = ConFusion.peek

local validate = t.strict(t.optional(t.Color3))

local pickerScope = PluginShared.scope:innerScope {
	Widget = Widget,
}

local isEnabled = pickerScope:Value(false)
local currentValue = pickerScope:Value(Color3.new(1, 1, 1))
local currentStatus = pickerScope:Value(nil)
local currentThread = nil

local function isActive()
	return peek(isEnabled) and currentThread ~= nil
end

local function _confirm()
	isEnabled:set(false)
	coroutine.resume(currentThread, peek(currentValue))
end

local function _cancel()
	isEnabled:set(false)
	coroutine.resume(currentThread)
end

return table.freeze {
	isActive = isActive,
	initialize = function(plugin: Plugin)
		pickerScope:Widget {
			plugin = plugin,
			output = currentValue,

			status = currentStatus,
			enabled = isEnabled,

			confirm = _confirm,
			cancel = _cancel,
		}
	end,
	prompt = function(startingColor: Color3?, status: string?): Color3?
		if isActive() then
			return
		end

		validate(startingColor)

		if startingColor then
			currentValue:set(startingColor)
		end

		currentStatus:set(status)
		isEnabled:set(true)

		currentThread = coroutine.running()

		return coroutine.yield(currentThread)
	end,
	cancel = function(defaultColor: Color3?)
		if isActive() then
			return
		end

		validate(defaultColor)

		isEnabled:set(false)

		coroutine.resume(currentThread, defaultColor)
	end,
}
