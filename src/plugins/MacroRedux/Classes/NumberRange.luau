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

local NumberRangeComponent = Roact.Component:extend('NumberRangeMacroComponent')

function NumberRangeComponent:getValue()
	local minBox, maxBox = self.Refs:get('Min', 'Max')
	
	if not (minBox or maxBox) then
		warn('Missing Min or Max entry box!')
		
		return
	end
	
	local minValue = tonumber(minBox.Text) or 0
	local maxValue = math.max(tonumber(maxBox.Text) or 0, minValue)
	
	return NumberRange.new(minValue, maxValue)
end

function NumberRangeComponent:init(macroItem)
	self.Item = macroItem
	self.Refs = RefUtil.combine('Min', 'Max')
	
	self:setState({
		Name = macroItem.Name,
		Value = macroItem.Value or NumberRange.new(0, 1)
	})
	
	local component = self
	
	function macroItem:SetValue(newValue: NumberRange)
		component:setState({
			Value = newValue
		})
		
		local oldValue = self.Value
		
		self.Value = newValue
		self:Changed(newValue, oldValue)
	end
	
	macroItem.__ActiveComponent = self
end

function NumberRangeComponent:render()
	local state = self.state
	local macroItem = self.Item
	
	return Roact.createElement('Frame', {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
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

local numberRangeClass = {}
numberRangeClass.Name = 'NumberRange'
numberRangeClass.Value = NumberRange.new(0, 1)

numberRangeClass.__Component = NumberRangeComponent
numberRangeClass.__FunctionDetails = {
	Changed = '(newValue: NumberRange, oldValue: NumberRange) -> nil',
	
	SetValue = '(newValue: NumberRange) -> nil!',
	Set = '(newValue: NumberRange) -> nil!'
}

------------------------------------------------------------
------------------------------------------------------------

function numberRangeClass:Changed(newValue: NumberRange, oldValue: NumberRange)
	return newValue, oldValue
end

function numberRangeClass:SetValue(newValue: NumberRange)
	if self.Changed then
		self:Changed(newValue, self.Value)
	end
	
	self.Value = newValue
	
	self.__ActiveComponent:setState({
		Value = newValue
	})
end

--- Compatibility Methods ---

function numberRangeClass:Set(value: NumberRange)
	self:SetValue(value)
end

return numberRangeClass