local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local PluginShared = require(Libraries.Shared)

local Theme = require(Components.Theme)

local height = PluginShared.DEFAULT_ITEM_HEIGHT

local LabelComponent = Roact.Component:extend('LabelMacroComponent')

function LabelComponent:init(macroItem)
	self.Item = macroItem
	
	self:setState({
		Text = macroItem.Text or 'Label',
		Selectable = macroItem.Selectable
	})
	
	local component = self
	
	function macroItem:SetText(newText: string)
		self.Text = newText
		
		component:setState({
			Text = newText
		})
	end
end

function LabelComponent:render()
	local macroItem = self.Item
	local state = self.state
	
	return Theme.with(function(theme)
		local selectable = state.Selectable
		
		local props = {
			Text = state.Text,
			TextSize = 16,
			TextColor3 = theme.MainText,
			FontFace = theme.Font,
			RichText = true,
			TextWrapped = true,
			
			BackgroundTransparency = 1,
			
			Size = UDim2.new(1, 0, 0, height),
			AutomaticSize = Enum.AutomaticSize.Y,
			
			TextXAlignment = macroItem.Alignment
		}
		
		if selectable then
			props.TextEditable = false
			props.ClearTextOnFocus = false
		end
		
		return Roact.createElement(state.Selectable and 'TextBox' or 'TextLabel', props)
	end)
end

local labelClass = {}
labelClass.Text = 'Label'
labelClass.Alignment = Enum.TextXAlignment.Center
labelClass.Selectable = false

labelClass.__Component = LabelComponent
labelClass.__FunctionDetails = {
	GetText = '() -> string!',
	SetText = '(newText: string) -> nil!',
	UpdateText = '(newText: string) -> nil!'
}

------------------------------------------------------------
------------------------------------------------------------

function labelClass:GetText()
	return self.Text
end

function labelClass:SetText(newText: string)
	return newText
end

--- Compatibility Methods ---

function labelClass:UpdateText(newText: string)
	self:SetText(newText)
end

return labelClass