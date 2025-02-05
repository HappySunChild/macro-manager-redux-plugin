local pluginFolder = script.Parent.Parent

local Roact = require(pluginFolder.Libraries.Roact)
local Theme = require(pluginFolder.Components.Theme)

local TopbarButton = Roact.Component:extend('TopbarButton')

function TopbarButton:render()
	return Theme.with(function(theme)
		local props = self.props
		
		return Roact.createElement('TextButton', {
			AutomaticSize = Enum.AutomaticSize.X,
			Size = props.Size,
			Position = props.Position,
			AnchorPoint = props.AnchorPoint,
			
			BorderSizePixel = 0,
			LayoutOrder = props.LayoutOrder,
			
			FontFace = theme.Font,
			Text = props.Text,
			TextSize = props.TextSize,
			TextColor3 = props.TextColor3 or theme.TopbarButtonForeground,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
			--TextScaled = true,
			
			BackgroundColor3 = theme.TopbarButtonBackground,
			
			[Roact.Event.MouseButton1Click] = props.Callback
		})
	end)
end

return TopbarButton