local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local PluginShared = require(Libraries.Shared)

local Theme = require(Components.Theme)
local Label = require(Components.NameLabel)

local height = PluginShared.DEFAULT_ITEM_HEIGHT

local SliderComponent = Roact.Component:extend('SliderMacroComponent')


local function lerp(a, b, t)
	return a + (b - a) * t
end

local function inverseLerp(v, a, b)
	return (v - a) / (b - a)
end


function SliderComponent:init(macroItem)
	self.Item = macroItem
	self.IsDragging = false
	
	self.BarRef = Roact.createRef()
	
	macroItem.Maximum = math.max(macroItem.Maximum, macroItem.Minimum)
	macroItem.Minimum = math.min(macroItem.Minimum, macroItem.Maximum)
	macroItem.Value = math.clamp(macroItem.Value, macroItem.Minimum, macroItem.Maximum)
	
	self:setState({
		Name = macroItem.Name,
		
		Minimum = macroItem.Minimum,
		Maximum = macroItem.Maximum,
		
		Snap = macroItem.Snap
	})
	
	local component = self
	
	function macroItem:SetMaximum(newMax: number)
		newMax = math.max(newMax, self.Minimum)
		
		self.Maximum = newMax
		self.Value = math.clamp(self.Value, self.Minimum, self.Maximum)
		
		component:setState({
			Maximum = newMax
		})
	end
	
	function macroItem:SetMinimum(newMin: number)
		newMin = math.min(newMin, self.Maximum)
		
		self.Minimum = newMin
		self.Value = math.clamp(self.Value, self.Minimum, self.Maximum)
		
		component:setState({
			Minimum = newMin
		})
	end
	
	function macroItem:SetValue(newValue: number)
		self.Value = math.clamp(newValue, self.Minimum, self.Maximum)
		
		component:setState({}) -- cause rerender, i think i should be doing reconcile but this works fine
	end
	
	function macroItem:SetSnap(newSnap: number)
		if newSnap < 1 and newSnap > 0 then
			newSnap = 1 / newSnap
		end
		
		newSnap = math.floor(newSnap)
		
		self.Snap = newSnap
		
		component:setState({
			Snap = newSnap
		})
	end
	
	macroItem:SetSnap(macroItem.Snap)
end

function SliderComponent:render()
	local state = self.state
	local macroItem = self.Item
	
	local lastAlpha = inverseLerp(macroItem.Value, state.Minimum, state.Maximum)
	
	local alphaBind, updateAlpha = Roact.createBinding(lastAlpha)
	local valueBind, updateValue = Roact.createBinding(macroItem.Value)
	
	return Theme.with(function(theme)
		-- tick generation
		local ticks = {}
		
		if state.Snap > 0 and state.Snap <= 25 then
			for i = 1, state.Snap - 1 do
				local tickFrame = Roact.createElement('Frame', {
					Size = UDim2.new(0, 2, 1, 0),
					Position = UDim2.fromScale(i/state.Snap, 0),
					AnchorPoint = Vector2.new(i/state.Snap, 0),
					
					BorderSizePixel = 0,
					BackgroundColor3 = theme.SliderBarTick
				})
				
				ticks[i] = tickFrame
			end
		end
		
		
		return Roact.createElement('Frame', {
			Size = UDim2.new(1, 0, 0, height + 17),
			BackgroundTransparency = 1
		}, {
			Label = Roact.createElement(Label, {
				Text = valueBind:map(function(value)
					return string.format(`{state.Name}: %.1f`, value)
				end),
				
				Size = UDim2.fromOffset(0, 16)
			}),
			
			Slider = Roact.createElement('Frame', {
				Position = UDim2.fromOffset(0, 17),
				Size = UDim2.new(1, 0, 0, height),
				
				BackgroundTransparency = 1,
				
				[Roact.Event.InputBegan] = function(_, input: InputObject)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
						return
					end
					
					self.IsDragging = true
				end,
				[Roact.Event.InputEnded] = function(_, input: InputObject)
					if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
						return
					end
					
					self.IsDragging = false
				end,
				[Roact.Event.InputChanged] = function(_, input: InputObject)
					if not self.IsDragging then
						return
					end
					
					if input.UserInputType ~= Enum.UserInputType.MouseMovement then
						return
					end
					
					local bar = self.BarRef:getValue() :: Frame?
					
					if not bar then
						return
					end
					
					local newAlpha = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					
					if state.Snap > 0 then
						newAlpha = math.round(newAlpha * state.Snap) / state.Snap
					end
					
					if lastAlpha == newAlpha then
						return
					end
					
					local newValue = lerp(state.Minimum, state.Maximum, newAlpha)
					
					if macroItem.Changed then
						xpcall(macroItem.Changed, warn, macroItem, newValue, macroItem.Value)
					end
					
					macroItem.Value = newValue
					
					updateAlpha(newAlpha)
					updateValue(newValue)
					
					lastAlpha = newAlpha
				end
			}, {
				Minimum = Roact.createElement('TextLabel', {
					BackgroundTransparency = 1,
					
					FontFace = theme.Font,
					Text = string.format('%.1f', state.Minimum),
					TextSize = 16,
					TextColor3 = theme.DimmedText,
					
					Size = UDim2.new(0, 35, 1, 0),
				}),
				Maximum = Roact.createElement('TextLabel', {
					BackgroundTransparency = 1,
					
					FontFace = theme.Font,
					Text = string.format('%.1f', state.Maximum),
					TextSize = 16,
					TextColor3 = theme.DimmedText,
					
					AnchorPoint = Vector2.new(1, 0),
					Size = UDim2.new(0, 35, 1, 0),
					Position = UDim2.fromScale(1, 0)
				}),
				
				Bar = Roact.createElement('Frame', {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.new(1, -70, 0, 4),
					
					BorderSizePixel = 1,
					BorderColor3 = theme.SliderBarTick,
					BackgroundColor3 = theme.SliderBar,
					
					[Roact.Ref] = self.BarRef
				}, {
					Ticks = Roact.createFragment(ticks),
					Handle = Roact.createElement('Frame', {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Size = UDim2.fromOffset(4, 16),
						Position = alphaBind:map(function(value)
							return UDim2.fromScale(value, 0.5)
						end),
						
						ZIndex = 2,
						BorderSizePixel = 1,
						BorderColor3 = theme.SliderBarTick,
						BackgroundColor3 = theme.SliderHandle
					})
				}),
			})
		})
	end)
end

local SliderClass = {}
SliderClass.Name = 'Slider'
SliderClass.Minimum = 0
SliderClass.Maximum = 1
SliderClass.Value = 0
SliderClass.Snap = 0

SliderClass.__Component = SliderComponent
SliderClass.__FunctionDetails = {
	SetValue = '(newValue: number) -> nil!',
	Set = '(newValue: number) -> nil!',
	
	SetMaximum = '(newMax: number) -> nil!',
	SetMinimum = '(newMin: number) -> nil!',
	SetSnap = '(newSnap: number) -> nil!',
	
	Changed = '(newValue: number, oldValue: number) -> nil'
}

function SliderClass:SetMaximum(newMaximum: number)
	return newMaximum
end

function SliderClass:SetMinimum(newMinimum: number)
	return newMinimum
end

function SliderClass:SetValue(newValue: number)
	return newValue
end

function SliderClass:SetSnap(newSnap: number)
	return newSnap
end

function SliderClass:Changed(newValue: number, oldValue: number)
	return newValue, oldValue
end

--- Compatibility Methods ---

function SliderClass:Set(newValue: number)
	self:SetValue(newValue)
end

return SliderClass