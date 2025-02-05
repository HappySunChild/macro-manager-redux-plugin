local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local PluginShared = require(Libraries.Shared)

local Label = require(Components.NameLabel)
local Entry = require(Components.Entry)

local height = PluginShared.DEFAULT_ITEM_HEIGHT

local StringComponent = Roact.Component:extend('StringMacroComponent')

function StringComponent:init(macroItem)
	self.Item = macroItem
	self:setState({
		Value = macroItem.Value,
		Name = macroItem.Name
	})
	
	local component = self
	
	function macroItem:SetValue(newValue: string)
		component:setState({
			Value = newValue
		})
		
		local oldValue = self.Value
		
		self.Value = newValue
		self:Changed(newValue, oldValue)
	end
end

function StringComponent:render()
	local state = self.state
	
	return Roact.createElement('Frame', {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1
	}, {
		Label = Roact.createElement(Label, {Text = state.Name, Size = UDim2.fromScale(0, 1)}),
		Entry = Roact.createElement(Entry, {
			Text = state.Value,
			PlaceholderText = state.Name,
			
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(0.6, 1),
			
			Callback = function(element)
				self.Item:SetValue(element.Text)
			end
		})
	})
end

local stringClass = {}
stringClass.Name = 'String'
stringClass.Value = ''

stringClass.__Component = StringComponent
stringClass.__FunctionDetails = {
	SetValue = '(newValue: string) -> nil!',
	Set = '(newValue: string) -> nil!',
	
	Changed = '(newValue: string, oldValue: string) -> nil',
}

------------------------------------------------------------
------------------------------------------------------------

function stringClass:Changed(newValue: string, oldValue: string)
	return newValue, oldValue
end

function stringClass:SetValue(value: string)
	return value
end

--- Compatibility Methods ---

function stringClass:Set(value: string)
	self:SetValue(value)
end

return stringClass