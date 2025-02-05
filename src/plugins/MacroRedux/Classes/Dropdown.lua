local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local PluginShared = require(Libraries.Shared)

local Theme = require(Components.Theme)
local Label = require(Components.NameLabel)
local Button = require(Components.Button)
local Padding = require(Components.Padding)

local height = PluginShared.DEFAULT_ITEM_HEIGHT
local tostring = function(value: any)
	if typeof(value) == "EnumItem" then
		return value.Name
	end
	
	return tostring(value)
end

local DropdownComponent = Roact.Component:extend('DropdownMacroComponent')
DropdownComponent.AutoScale = false

function DropdownComponent:init(macroItem)
	local values = macroItem.Values or {}
	
	self.Item = macroItem
	self.SelectorRef = Roact.createRef()
	self.ArrowRef = Roact.createRef()
	
	self:setState({
		Name = macroItem.Name,
		Selected = values[1],
		Values = table.clone(values)
	})
	
	local component = self
	
	macroItem.Expanded = false
	macroItem.Value = nil
	
	function macroItem:Select(index: number, collapse: boolean?)
		if collapse or collapse == nil then
			self:Collapse()
		end
		
		local newValue = self.Values[index]
		local oldValue = self.Value
		
		component:setState({
			Selected = newValue
		})
		
		self.Value = newValue
		self:Changed(newValue, oldValue)
	end
	
	------------------------------------------------------------
	
	function macroItem:Expand()
		if self.Expanded then
			return
		end
		
		local arrow = component.ArrowRef:getValue()
		local selector = component.SelectorRef:getValue()
		
		self.Expanded = true
		
		arrow.Rotation = -90
		selector.Size = UDim2.new(1, 0, 0, math.min(#component.state.Values, 6) * 16)
		selector.Visible = true
	end
	
	function macroItem:Collapse()
		if not self.Expanded then
			return
		end
		
		local selector = component.SelectorRef:getValue()
		local arrow = component.ArrowRef:getValue()
		
		self.Expanded = false
		
		arrow.Rotation = 90
		selector.Visible = false
	end
	
	------------------------------------------------------------
	
	function macroItem:AddValue(newValue: any)
		table.insert(self.Values, newValue)
		
		component:setState(function(prevState)
			table.insert(prevState.Values, newValue)
			
			return prevState
		end)
	end
	
	function macroItem:SetValues(newValues: {any})
		self.Values = newValues
		
		component:setState({
			Selected = newValues[1],
			Values = newValues
		})
	end
	
	function macroItem:Clear()
		self.Values = {}
		
		component:setState({
			Selected = '...',
			Values = {}
		})
	end
end

function DropdownComponent:render()
	return Theme.with(function(theme)
		local state = self.state
		local item = self.Item
		
		local dropdownItems = {}
		
		for index, dropdownValue in state.Values do
			local element = Roact.createElement('TextButton', {
				Text = tostring(dropdownValue),
				TextSize = 16,
				TextColor3 = theme.SubText,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = theme.Font,
				
				Size = UDim2.new(1, 0, 0, 16),
				
				BackgroundColor3 = (index % 2 ~= 0) and theme.ButtonAltBackground or theme.ButtonBackground,
				BorderSizePixel = 0,
				
				ZIndex = 15,
				
				[Roact.Event.Activated] = function()
					item:Select(index, true)
				end
			}, {
				Roact.createElement(Padding, {Left = 2})
			})
			
			table.insert(dropdownItems, element)
		end
		
		local itemsFrag = Roact.createFragment(dropdownItems)
		
		return Roact.createElement('Frame', {
			Size = UDim2.new(1, 0, 0, height),
			BackgroundTransparency = 1
		}, {
			Label = Roact.createElement(Label, {Text = state.Name, Size = UDim2.fromScale(0, 1)}),
			
			Container = Roact.createElement('Frame', {
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(0.6, 1),
				AnchorPoint = Vector2.new(1, 0),
				
				BackgroundTransparency = 0.9
			}, {
				Button = Roact.createElement(Button, {
					Text = tostring(state.Selected),
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Left,
					
					Size = UDim2.fromScale(1, 1),
					
					Callback = function()
						if item.Expanded then
							item:Collapse()
						else
							item:Expand()
						end
					end
				}, {
					Roact.createElement(Padding, {Left = 2, Right = 10})
				}),
				
				Arrow = Roact.createElement('ImageLabel', {
					AnchorPoint = Vector2.new(1, 0.5),
					Size = UDim2.fromOffset(8, 8),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					
					Position = UDim2.new(1, -4, 0.5, 0),
					Rotation = 90,
					
					BackgroundTransparency = 1,
					Image = 'rbxassetid://4918373417',
					ImageColor3 = theme.SubText,
					
					[Roact.Ref] = self.ArrowRef
				}),
				
				Selector = Roact.createElement('ScrollingFrame', {
					Position = UDim2.new(0, 0, 1, 1),
					Size = UDim2.fromScale(1, 0),
					
					BackgroundColor3 = theme.ButtonBackground,
					BorderColor3 = theme.ButtonBorder,
					
					CanvasSize = UDim2.fromScale(0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ScrollBarThickness = 1,
					ZIndex = 10,
					
					Visible = false,
					
					[Roact.Ref] = self.SelectorRef
				}, {
					Layout = Roact.createElement('UIListLayout', {
						FillDirection = Enum.FillDirection.Vertical,
					}),
					
					Items = itemsFrag
				})
			}),
		})
	end)
end

local dropdownClass = {}
dropdownClass.Expanded = false
dropdownClass.Value = 'any'
dropdownClass.Name = 'Dropdown'
dropdownClass.Values = {'default1', 'default2', 'default3'}

dropdownClass.__Component = DropdownComponent
dropdownClass.__FunctionDetails = {
	Changed = '(newValue: any, oldValue: any) -> nil',
	
	Select = '(index: number, collapse: boolean?) -> nil!',
	
	SetValues = '(values: {string}) -> nil!',
	AddValue = '(value: any) -> nil!',
}

------------------------------------------------------------
------------------------------------------------------------

function dropdownClass:Expand()
	return
end

function dropdownClass:Collapse()
	return
end

------------------------------------------------------------
------------------------------------------------------------

function dropdownClass:Select(index: number, collapse: boolean?)
	return index, collapse
end

function dropdownClass:Changed(newValue, oldValue)
	return newValue, oldValue
end

------------------------------------------------------------
------------------------------------------------------------

function dropdownClass:Clear()
	return
end

function dropdownClass:AddValue(value: any)
	return value
end

function dropdownClass:SetValues(values: {string})
	return values
end

return dropdownClass