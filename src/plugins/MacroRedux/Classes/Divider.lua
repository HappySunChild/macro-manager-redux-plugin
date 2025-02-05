local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)

local Theme = require(Components.Theme)
local Padding = require(Components.Padding)

local DividerComponent = Roact.Component:extend('DividerMacroComponent')

function DividerComponent:init(macroItem)
	self.Item = macroItem
	
	self:setState({
		Text = rawget(macroItem, 'Text')
	})
end

function DividerComponent:render()
	local state = self.state
	
	return Theme.with(function(theme)
		local label = nil
		
		if state.Text then
			label = Roact.createElement('TextLabel', {
				FontFace = theme.Font,
				Text = state.Text,
				TextSize = 16,
				TextColor3 = theme.SubText,
				
				BackgroundColor3 = theme.ItemBackground,
				BorderSizePixel = 0,
				
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X
			}, {
				Roact.createElement(Padding, {
					Left = 2,
					Right = 2
				})
			})
		end
		
		return Roact.createElement('Frame', {
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			--BackgroundColor3 = theme.ItemBackground,
			
			Size = UDim2.new(1, 0, 0, label and 18 or 9),
		}, {
			Label = label,
			Line = Roact.createElement('Frame', {
				BorderSizePixel = 0,
				BackgroundColor3 = theme.DimmedText,
				
				Size = UDim2.new(0.95, 0, 0, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5)
			})
		})
	end)
end

local dividerClass = {}
dividerClass.Text = ''

dividerClass.__Component = DividerComponent

return dividerClass