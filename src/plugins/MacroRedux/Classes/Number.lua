local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local PluginShared = require(Libraries.Shared)

local Label = require(Components.NameLabel)
local Entry = require(Components.Entry)

local height = PluginShared.DEFAULT_ITEM_HEIGHT

local NumberComponent = Roact.Component:extend('NumberMacroComponent')

function NumberComponent:init(macroItem)
	self.Item = macroItem
	self:setState({
		Name = macroItem.Name,
		Value = macroItem.Value or 0
	})
	
	local component = self
	
	function macroItem:SetValue(newValue: number)
		component:setState({
			Value = newValue
		})
		
		local oldValue = self.Value
		
		self.Value = newValue
		self:Changed(newValue, oldValue)
	end
end

function NumberComponent:render()
	local state = self.state
	
	return Roact.createElement('Frame', {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
	}, {
		Label = Roact.createElement(Label, {Text = state.Name, Size = UDim2.fromScale(0, 1)}),
		Entry = Roact.createElement(Entry, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(0.6, 1),
			
			Text = string.format('%.2f', state.Value),
			PlaceholderText = state.Name,
			
			Callback = function(element)
				self.Item:SetValue(tonumber(element.Text) or 0)
			end
		})
	})
end

local numberClass = {}
numberClass.Name = 'Number'
numberClass.Value = 0

numberClass.__Component = NumberComponent
numberClass.__FunctionDetails = {
	Changed = '(newValue: number, oldValue: number) -> nil',
	SetValue = '(newValue: number) -> nil!',
	Set = '(newValue: number) -> nil!'
}

------------------------------------------------------------
------------------------------------------------------------

function numberClass:Changed(newValue: number, oldValue: number)
	return newValue, oldValue
end

function numberClass:SetValue(newValue: number)
	return newValue
end

--- Compatibility Methods ---

function numberClass:Set(value: number)
	self:SetValue(value)
end

return numberClass