local ChangeHistoryService = game:GetService("ChangeHistoryService")
local RunService = game:GetService("RunService")
local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local PluginShared = require(Libraries.Shared)

local Group = require(Components.Group)
local Button = require(Components.Button)

local height = PluginShared.DEFAULT_ITEM_HEIGHT

local ButtonGroupComponent = Roact.Component:extend('ButtonGroupMacroComponent')

function ButtonGroupComponent:init(macroItem)
	self.Item = macroItem
	self:setState({
		Buttons = macroItem.Buttons
	})
	
	local component = self
	
	function macroItem:SetText(index: number, text: string)
		component:setState(function(prevState)
			local buttons = prevState.Buttons
			
			buttons[index] = text
			
			return {
				Buttons = buttons
			}
		end)
	end
end

function ButtonGroupComponent:render()
	local macroItem = self.Item
	local state = self.state
	
	local buttons = {}
	
	for index, text in ipairs(state.Buttons) do
		table.insert(buttons, Roact.createElement(Button, {
			Text = text,
			Size = UDim2.fromScale(0, 1),
			
			Callback = function()
				local recordingId = ChangeHistoryService:TryBeginRecording('Activate Macro Button', `Pressed Macro Button ({text})`)
			
				if not recordingId and not RunService:IsRunMode() then
					return
				end
				
				local success, err = pcall(function()
					macroItem:Activate(index)
				end)
				
				if not success then
					warn(err)
				end
				
				if recordingId then
					ChangeHistoryService:FinishRecording(recordingId, Enum.FinishRecordingOperation.Commit)
				end
			end
		}))
	end
	
	return Roact.createElement('Frame', {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1
	}, {
		Buttons = Roact.createElement(Group, {
			Size = UDim2.fromScale(1, 1)
		}, buttons)
	})
end

local buttonGroupClass = {}
buttonGroupClass.Buttons = {'Button1', 'Button2'}

buttonGroupClass.__Component = ButtonGroupComponent
buttonGroupClass.__FunctionDetails = {
	SetText = '(index: number, newText: string) -> nil!',
	UpdateText = '(index: number, newText: string) -> nil!',
	
	Activated = '(index: number) -> nil',
	Activate = '(index: number) -> nil!'
}

------------------------------------------------------------
------------------------------------------------------------

function buttonGroupClass:SetText(index: number, newText: string)
	return index, newText
end

------------------------------------------------------------
------------------------------------------------------------

function buttonGroupClass:Activated(index: number)
	return index
end

function buttonGroupClass:Activate(index: number)
	self:Activated(index)
end

--- Compatibility Methods ---

function buttonGroupClass:UpdateText(newIndex: number, newText: string)
	self:SetText(newIndex, newText)
end

return buttonGroupClass