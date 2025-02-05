local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local RefUtil = require(Libraries.RefUtility)
local PluginShared = require(Libraries.Shared)

local Theme = require(Components.Theme)
local Label = require(Components.NameLabel)
local Entry = require(Components.Entry)
local ReferenceGroup = require(Components.ReferenceGroup)

local height = PluginShared.DEFAULT_ITEM_HEIGHT

local Color3Component = Roact.Component:extend('Color3MacroComponent')

function Color3Component:getValue()
	local rBox, gBox, bBox = self.Refs:get('R', 'G', 'B')
	
	if not (rBox and gBox and bBox) then
		warn('Missing R, G or B entry box!')
		
		return
	end
	
	local rVal = math.clamp(tonumber(rBox.Text:match('[%d%.]+')) or 0, 0, 255)
	local gVal = math.clamp(tonumber(gBox.Text:match('[%d%.]+')) or 0, 0, 255)
	local bVal = math.clamp(tonumber(bBox.Text:match('[%d%.]+')) or 0, 0, 255)
	
	return Color3.fromRGB(rVal, gVal, bVal)
end

function Color3Component:init(macroItem)
	self.Item = macroItem
	self.Refs = RefUtil.combine('R', 'G', 'B')
	
	self:setState({
		Name = macroItem.Name,
		Value = macroItem.Value or Color3.new()
	})
	
	local component = self
	
	function macroItem:SetValue(newValue: Color3)
		component:setState({
			Value = newValue
		})
		
		local oldValue = self.Value
		
		self.Value = newValue
		self:Changed(newValue, oldValue)
	end
end

function Color3Component:render()
	local state = self.state
	local macroItem = self.Item
	
	return Theme.with(function(theme)
		return Roact.createElement('Frame', {
			Size = UDim2.new(1, 0, 0, height),
			BackgroundTransparency = 1
		}, {
			Label = Roact.createElement(Label, {
				Text = state.Name,
				Size = UDim2.fromScale(0, 1)
			}),
			
			ColorDisplay = Roact.createElement('Frame', {
				AnchorPoint = Vector2.new(1, 0),
				Size = UDim2.fromOffset(height, height),
				Position = UDim2.new(1, 0, 0, 0),
				
				BackgroundColor3 = state.Value,
				BorderColor3 = theme.InputFieldBorder
			}),
			
			Group = Roact.createElement(ReferenceGroup, {
				AnchorPoint = Vector2.new(1, 0),
				Size = UDim2.new(0.6, -(height + 3), 1, 0),
				Position = UDim2.new(1, -(height + 3), 0, 0),
				
				Refs = self.Refs:toInfo(),
				Render = function(ref, name, index)
					return Roact.createElement(Entry, {
						LayoutOrder = index,
						
						PlaceholderText = name,
						Text = string.format(`{name}: %d`, state.Value[name] * 255),
						
						Size = UDim2.fromScale(0, 1),
						
						[Roact.Ref] = ref,
						
						Callback = function()
							macroItem:SetValue(self:getValue())
						end
					})
				end
			})
		})
	end)
end

local color3Class = {}
color3Class.Name = 'Color3'
color3Class.Value = Color3.new()

color3Class.__Component = Color3Component
color3Class.__FunctionDetails = {
	Changed = '(newValue: Color3, oldValue: Color3) -> nil',
	
	SetValue = '(newValue: Color3) -> nil!',
	Set = '(newValue: Color3) -> nil!',
}

------------------------------------------------------------
------------------------------------------------------------

function color3Class:Changed(newValue: Color3, oldValue: Color3)
	return newValue, oldValue
end

function color3Class:SetValue(value: Color3)
	return value
end

--- Compatibility Methods ---

function color3Class:Set(value: Color3)
	self:SetValue(value)
end

return color3Class