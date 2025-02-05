local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local Theme = require(Components.Theme)

local Entry = Roact.Component:extend('Entry')

function Entry:render()
	return Theme.with(function(theme)
		local props = self.props
		
		return Roact.createElement('TextBox', {
			LayoutOrder = props.LayoutOrder,
			
			Text = props.Text,
			TextColor3 = theme.SubText,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = props.TextXAlignment,
			TextSize = props.TextSize or 18,
			FontFace = theme.Font,
			
			PlaceholderText = props.PlaceholderText,
			PlaceholderColor3 = theme.DimmedText,
			
			Size = props.Size,
			Position = props.Position,
			AnchorPoint = props.AnchorPoint,
			
			BackgroundColor3 = theme.InputFieldBackground,
			BorderColor3 = theme.InputFieldBorder,
			BorderSizePixel = props.BorderSizePixel,
			
			[Roact.Ref] = props[Roact.Ref],
			[Roact.Event.FocusLost] = props.Callback
		})
	end)
end

return Entry