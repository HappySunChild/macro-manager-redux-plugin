-- this is ridiculous... how is this still not a feature??
-- bump this post RIGHT NOW!
-- https://devforum.roblox.com/t/allow-plugins-to-use-color-picker/63257/

local Fusion = require "@packages/Fusion"
local t = require "@packages/t"

local PluginShared = require "@plugin/Shared"
local scope = PluginShared.Scope

local Widget = require "@self/Widget"

local peek = Fusion.peek

local validate = t.optional(t.Color3)

local isEnabled = scope:Value(false)
local currentValue = scope:Value(Color3.new(1, 1, 1))
local currentThread = nil

local ColorPicker = {}

function ColorPicker:Initialize(plugin: Plugin)
	local inner = scope:innerScope { Widget = Widget }

	inner:Widget {
		Plugin = plugin,
		OutputColor = currentValue,
		Enabled = isEnabled,

		ConfirmCallback = function()
			isEnabled:set(false)
			coroutine.resume(currentThread, peek(currentValue))
		end,
		CancelCallback = function()
			isEnabled:set(false)
			coroutine.resume(currentThread)
		end,
	}
end

function ColorPicker:Prompt(startingColor: Color3?): Color3?
	if ColorPicker:IsActive() then
		return
	end

	assert(validate(startingColor))

	if startingColor then
		currentValue:set(startingColor)
	end

	isEnabled:set(true)

	currentThread = coroutine.running()

	return coroutine.yield(currentThread)
end

function ColorPicker:Cancel(defaultColor: Color3?)
	if ColorPicker:IsActive() then
		return
	end

	assert(validate(defaultColor))

	isEnabled:set(false)

	coroutine.resume(currentThread, defaultColor)
end

function ColorPicker:IsActive()
	return peek(isEnabled) and currentThread ~= nil
end

return ColorPicker
