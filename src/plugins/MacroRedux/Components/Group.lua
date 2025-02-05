local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Roact = require(Libraries.Roact)

local Group = Roact.Component:extend('Group')

function Group:render()
	local props = self.props
	
	return Roact.createElement('Frame', {
		BackgroundTransparency = 1,
		
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,
	}, {
		Children = Roact.createFragment(props[Roact.Children]),
		Layout = Roact.createElement('UIListLayout', {
			FillDirection = props.FillDirection or Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			SortOrder = Enum.SortOrder.LayoutOrder,
			
			Padding = UDim.new(0, 3),
		})
	})
end

return Group