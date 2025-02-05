local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Components = pluginFolder.Components

local Roact = require(Libraries.Roact)
local Theme = require(Components.Theme)

local NameLabel = Roact.Component:extend('NameLabel')

function NameLabel:render()
	return Theme.with(function(theme)
		local props = self.props
		
		return Roact.createElement('TextLabel', {
			AnchorPoint = props.AnchorPoint,
			Position = props.Position,
			Size = props.Size or UDim2.fromOffset(0, 16),
			AutomaticSize = props.AutomaticSize or Enum.AutomaticSize.X,
			
			BackgroundTransparency = 1,
			
			Text = props.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 16,
			TextColor3 = theme.MainText,
			FontFace = theme.Font
		})
	end)
end

return NameLabel