local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local RefUtil = require(Libraries.RefUtility)
local PluginShared = require(Libraries.Shared)

local Label = require(Components.NameLabel)
local Entry = require(Components.Entry)
local ReferenceGroup = require(Components.ReferenceGroup)

local height = PluginShared.DEFAULT_ITEM_HEIGHT

local Vector2Component = Roact.Component:extend('Vector2MacroComponent')

function Vector2Component:getValue()
	local xBox, yBox = self.Refs:get('X', 'Y')
	
	if not (xBox or yBox) then
		warn('Missing X or Y entry box!')
		
		return
	end
	
	local xVal = tonumber(xBox.Text) or 0
	local yVal = tonumber(yBox.Text) or 0
	
	return Vector2.new(xVal, yVal)
end

function Vector2Component:init(macroItem)
	self.Item = macroItem
	self.Refs = RefUtil.combine('X', 'Y')
	
	self:setState({
		Name = macroItem.Name,
		Value = macroItem.Value or Vector2.zero
	}) 
	
	local component = self
	
	function macroItem:SetValue(newValue: Vector2)
		component:setState({
			Value = newValue
		})
		
		local oldValue = self.Value
		
		self.Value = newValue
		self:Changed(newValue, oldValue)
	end
end

function Vector2Component:render()
	local state = self.state
	local macroItem = self.Item
	
	return Roact.createElement('Frame', {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1
	}, {
		Label = Roact.createElement(Label, {Text = state.Name, Size = UDim2.fromScale(0, 1)}),
		Group = Roact.createElement(ReferenceGroup, {
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.fromScale(0.6, 1),
			Position = UDim2.fromScale(1, 0),
			
			Refs = self.Refs:toInfo(),
			Render = function(ref, name, index)
				return Roact.createElement(Entry, {
					LayoutOrder = index,
				
					PlaceholderText = name,
					Text = string.format('%.2f', state.Value[name]),
					
					Size = UDim2.fromScale(0, 1),
					
					[Roact.Ref] = ref,
					
					Callback = function()
						macroItem:SetValue(self:getValue())
					end
				})
			end
		})
	})
end

local vector2Class = {}
vector2Class.Name = 'Vector2'
vector2Class.Value = Vector2.zero

vector2Class.__Component = Vector2Component
vector2Class.__FunctionDetails = {
	SetValue = '(newValue: Vector2) -> nil!',
	Set = '(newValue: Vector2) -> nil!',
	
	Changed = '(newValue: Vector2, oldValue: Vector2) -> nil'
}

------------------------------------------------------------
------------------------------------------------------------

function vector2Class:Changed(newValue: Vector2, oldValue: Vector2)
	return newValue, oldValue
end

function vector2Class:SetValue(value: Vector2)
	return value
end

--- Compatibility Methods ---

function vector2Class:Set(value: Vector2)
	self:SetValue(value)
end

return vector2Class