local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local Theme = require(Components.Theme)

local Button = Roact.Component:extend('Button')

function Button:render()
	return Theme.with(function(theme)
		local props = self.props
		
		return Roact.createElement('TextButton', {
			Text = props.Text,
			TextColor3 = theme.SubText,
			TextSize = props.TextSize or 18,
			TextXAlignment = props.TextXAlignment,
			TextYAlignment = props.TextYAlignment,
			TextTruncate = props.TextTruncate,
			FontFace = theme.Font,
			
			SizeConstraint = props.SizeConstraint,
			Size = props.Size,
			Position = props.Position,
			AnchorPoint = props.AnchorPoint,
			
			BackgroundColor3 = theme.ButtonBackground,
			BorderColor3 = theme.ButtonBorder,
			
			[Roact.Event.Activated] = props.Callback
		}, props[Roact.Children])
	end)
end

return Button