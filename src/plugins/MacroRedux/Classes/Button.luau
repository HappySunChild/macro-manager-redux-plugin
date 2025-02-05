local ChangeHistoryService = game:GetService("ChangeHistoryService")
local RunService = game:GetService("RunService")

local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local PluginShared = require(Libraries.Shared)

local Button = require(Components.Button)

local height = PluginShared.DEFAULT_ITEM_HEIGHT

local ButtonComponent = Roact.Component:extend('ButtonMacroComponent')

function ButtonComponent:init(macroItem)
	self.Item = macroItem
	
	self:setState({
		Text = macroItem.Text
	})
	
	local component = self
	
	function macroItem:SetText(newText: string)
		component:setState({
			Text = newText
		})
		
		self.Text = newText
	end
end

function ButtonComponent:render()
	local state = self.state
	local macroItem = self.Item
	
	return Roact.createElement(Button, {
		Size = UDim2.new(1, 0, 0, height),
		Text = state.Text,
		
		Callback = function()
			local recordingId = ChangeHistoryService:TryBeginRecording('Activate Macro Button', `Pressed Macro Button ({state.Text})`)
			
			if not recordingId and not RunService:IsRunMode() then
				return
			end
			
			local success, err = pcall(function()
				macroItem:Activate()
			end)
			
			if not success then
				warn(err)
			end
			
			if recordingId then
				ChangeHistoryService:FinishRecording(recordingId, Enum.FinishRecordingOperation.Commit)
			end
		end
	})
end

local buttonClass = {}
buttonClass.Text = 'Button'

buttonClass.__Component = ButtonComponent
buttonClass.__FunctionDetails = {
	SetText = '(newText: string) -> nil!',
	UpdateText = '(newText: string) -> nil!'
}

------------------------------------------------------------
------------------------------------------------------------

function buttonClass:SetText(newText: string)
	return newText
end

------------------------------------------------------------
------------------------------------------------------------

function buttonClass:Activated()
	return
end

function buttonClass:Activate()
	self:Activated()
end

--- Compatibility Methods ---

function buttonClass:UpdateText(newText: string)
	self:SetText(newText)
end

return buttonClass