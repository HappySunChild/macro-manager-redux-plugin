local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Roact = require(Libraries.Roact)

local Padding = Roact.Component:extend('Padding')

function Padding:render()
	local props = self.props
	
	return Roact.createElement('UIPadding', {
		PaddingLeft = UDim.new(0, props.Left or props.All or 2),
		PaddingRight = UDim.new(0, props.Right or props.All or 2),
		PaddingTop = UDim.new(0, props.Top or props.All or 2),
		PaddingBottom = UDim.new(0, props.Bottom or props.All or 2),
	})
end

return Padding