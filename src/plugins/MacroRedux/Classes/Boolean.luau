local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local PluginShared = require(Libraries.Shared)

local Theme = require(Components.Theme)
local Label = require(Components.NameLabel)
local Button = require(Components.Button)

local height = PluginShared.DEFAULT_ITEM_HEIGHT

local BooleanComponent = Roact.Component:extend('BooleanMacroComponent')

function BooleanComponent:init(macroItem)
	self.Item = macroItem
	self:setState({
		Value = macroItem.Value,
		Name = macroItem.Name
	})
	
	local component = self
	
	function macroItem:SetValue(newValue: boolean)
		component:setState({
			Value = newValue
		})
		
		local oldValue = self.Value
		
		self.Value = newValue
		self:Changed(newValue, oldValue)
	end
end

function BooleanComponent:render()
	return Theme.with(function(theme)
		local state = self.state
		
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, height),
			BackgroundTransparency = 1,
		}, {
			Label = Roact.createElement(Label, {
				Text = state.Name,
				Size = UDim2.fromScale(0, 1),
				-- Position = UDim2.fromOffset(27, 0) -- +1 because border is one pixel
			}),
			
			Box = Roact.createElement(Button, {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromOffset(height, height),
				
				BackgroundColor3 = theme.ButtonBackground,
				BorderColor3 = theme.ButtonBorder,
				
				Text = state.Value and '✓' or '',
				TextSize = height + 4,
				
				Callback = function()
					self.Item:SetValue(not self.Item.Value)
				end
			})
		})
	end)
end

local booleanClass = {}
booleanClass.Name = 'Boolean'
booleanClass.Value = false

booleanClass.__Component = BooleanComponent
booleanClass.__FunctionDetails = {
	Changed = '(newValue: boolean, oldValue: boolean) -> nil',
	SetValue = '(newValue: boolean) -> nil!',
	Set = '(newValue: boolean) -> nil!'
}

------------------------------------------------------------
------------------------------------------------------------

function booleanClass:Changed(newValue: boolean, oldValue: boolean)
	return newValue, oldValue
end

function booleanClass:SetValue(value: boolean)
	return value
end

--- Compatibility Methods ---

function booleanClass:Set(value: boolean)
	self:SetValue(value)
end

return booleanClass