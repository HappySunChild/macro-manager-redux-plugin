local StudioService = game:GetService("StudioService")
local Selection = game:GetService('Selection')

local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local PluginShared = require(Libraries.Shared)

local Theme = require(Components.Theme)
local NameLabel = require(Components.NameLabel)

local height = PluginShared.DEFAULT_ITEM_HEIGHT

local InstanceComponent = Roact.Component:extend('InstanceMacroComponent')

function InstanceComponent:startSelection()
	local macroItem = self.Item
	
	self:setState({
		IsSelecting = true
	})
	
	self.SelectionConnection = Selection.SelectionChanged:Connect(function()
		local selected = Selection:Get()[1]
		
		if not selected then
			return
		end
		
		Selection:Set({})
		
		macroItem:SetValue(selected)
		
		self:stopSelection()
	end)
end

function InstanceComponent:stopSelection()
	if self.SelectionConnection then
		self.SelectionConnection:Disconnect()
		self.SelectionConnection = nil
	end
	
	self:setState({
		IsSelecting = false
	})
end


function InstanceComponent:init(macroItem)
	self.Item = macroItem
	
	local inst = rawget(macroItem, 'Value')
	self:setState({
		Name = macroItem.Name,
		Value = typeof(inst) == "Instance" and inst or nil,
		
		IsSelecting = false
	})
	
	local component = self
	
	function macroItem:SetValue(newValue: Instance?)
		if typeof(newValue) ~= "Instance" then
			newValue = nil
		end
		
		component:setState({
			Value = newValue or false
		})
		
		local oldValue = self.Value
		
		self.Value = newValue
		self:Changed(newValue, oldValue)
	end
	
	self.SelectionConnection = nil
end

function InstanceComponent:willUnmount()
	if self.SelectionConnection then
		self.SelectionConnection:Disconnect()
		self.SelectionConnection = nil
	end
end

function InstanceComponent:render()
	local state = self.state
	local macroItem = self.Item
	
	return Theme.with(function(theme)
		local inst = state.Value :: Instance?
		
		if inst == false then
			inst = nil
		end
		
		local icon = nil
		local clearButton = nil
		
		if not state.IsSelecting then
			local classIcon = StudioService:GetClassIcon(tostring(inst and inst.ClassName))
			local image = classIcon and classIcon.Image or ""
			
			icon = Roact.createElement('ImageLabel', {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromOffset(height - 4, height - 4),
				
				BackgroundTransparency = 1,
				Image = image
			})
		elseif state.IsSelecting then
			clearButton = Roact.createElement('TextButton', {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromOffset(height, height),
				
				BackgroundColor3 = theme.ButtonAltBackground,
				BorderColor3 = theme.ButtonBorder,
				
				Text = 'X',
				TextColor3 = Color3.new(1, 0, 0),
				TextScaled = true,
				FontFace = Font.fromName('Arimo', Enum.FontWeight.Heavy),
				
				[Roact.Event.Activated] = function()
					self:stopSelection()
					
					macroItem:SetValue(nil)
				end
			})
		end
		
		return Roact.createElement('Frame', {
			Size = UDim2.new(1, 0, 0, height),
			BackgroundTransparency = 1
		}, {
			Label = Roact.createElement(NameLabel, {
				Text = state.Name,
				Size = UDim2.fromScale(0, 1)
			}),
			
			Clear = clearButton,
			Picker = Roact.createElement('TextButton', {
				Position = UDim2.fromScale(0.4, 0),
				Size = UDim2.new(0.6, clearButton and -height or 0, 1, 0),
				
				BackgroundColor3 = theme.ButtonBackground,
				BorderColor3 = theme.ButtonBorder,
				
				Text = '',
				
				[Roact.Event.Activated] = function()
					if state.IsSelecting then
						self:stopSelection()
						
						return
					end
					
					self:startSelection()
				end
			}, {
				--Padding = Roact.createElement(Padding, {Left = 1, Right = 1}),
				
				Icon = icon,
				Label = Roact.createElement('TextLabel', {
					Position = icon and UDim2.fromOffset(height - 2, 0),
					Size = UDim2.new(1, icon and -(height - 2) or 0, 1, 0),
					
					BackgroundTransparency = 1,
					
					Text = state.IsSelecting and '...' or (inst and inst:GetFullName() or 'nil'),
					TextSize = 16,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextColor3 = theme.SubText,
					FontFace = theme.Font
				})
			})
		})
	end)
end

local instanceClass = {}
instanceClass.Value = game
instanceClass.Name = 'Instance'

instanceClass.__Component = InstanceComponent
instanceClass.__FunctionDetails = {
	SetValue = '(newValue: Instance?) -> nil!',
	Set = '(newValue: Instance?) -> nil!',
	
	Changed = '(newValue: Instance?, oldValue: Instance?) -> nil',
}

function instanceClass:Changed(newValue: Instance?, oldValue: Instance?)
	return newValue, oldValue
end

function instanceClass:SetValue(newValue: Instance?)
	return newValue
end

function instanceClass:Set(newValue: Instance?)
	self:SetValue(newValue)
end

return instanceClass