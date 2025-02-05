local pluginFolder = script.Parent.Parent.Parent

local Libraries = pluginFolder.Libraries
local Component = pluginFolder.Components
local Theme = require(Component.Theme)
local Roact = require(Libraries.Roact)

local Alert = Roact.Component:extend('AlertIcon')

function Alert:render()
	local visible, updateVisible = Roact.createBinding(false)
	
	return Theme.with(function(theme)
		return Roact.createElement('ImageLabel', {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -18, 0, 0),
			Size = UDim2.fromOffset(16, 16),
			BorderSizePixel = 0,
			
			AutomaticSize = Enum.AutomaticSize.X,
			
			BackgroundColor3 = theme.AlertBackground,
			ImageColor3 = theme.AlertForeground,
			Image = 'rbxassetid://103473624490005',
			ScaleType = Enum.ScaleType.Fit,
			
			[Roact.Event.MouseEnter] = function()
				updateVisible(true)
			end,
			[Roact.Event.MouseLeave] = function()
				updateVisible(false)
			end
		}, {
			Roact.createElement('TextLabel', {
				Size = UDim2.fromScale(1, 1),
				
				AutomaticSize = Enum.AutomaticSize.X,
				BorderSizePixel = 0,
				
				BackgroundColor3 = theme.AlertBackground,
				TextColor3 = theme.AlertForeground,
				
				Text = self.props.Count,
				TextSize = 16,
				FontFace = theme.Font,
				
				Visible = visible
			})
		})
	end)
end

return Alert