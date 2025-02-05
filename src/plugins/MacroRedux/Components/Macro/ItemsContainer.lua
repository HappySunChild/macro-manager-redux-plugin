local pluginFolder = script.Parent.Parent.Parent

local Roact = require(pluginFolder.Libraries.Roact)
local Theme = require(pluginFolder.Components.Theme)

local MacroItemsContainer = Roact.Component:extend('MacroItemsContainer')

function MacroItemsContainer:render()
	local props = self.props
	
	local isVisible = props.Visible
	
	if not next(props.Items) then
		--isVisible = false
		props.Items.NoItems = Theme.with(function(theme)
			return Roact.createElement('TextLabel', {
				Size = UDim2.new(1, 0, 0, 26),
				
				BorderSizePixel = 0,
				BackgroundColor3 = theme.NoticeBackground,
				
				FontFace = theme.Font,
				RichText = true,
				Text = '<i>No items</i>',
				TextSize = 18,
				TextColor3 = theme.DimmedText,
			})
		end)
	end
	
	return Roact.createElement('Frame', {
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		
		BackgroundTransparency = 1,
		Visible = isVisible
	}, {
		Layout = Roact.createElement('UIListLayout', {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			
			Padding = UDim.new(0, 0),
		}),
		
		Items = Roact.createFragment(props.Items)
	})
end

return MacroItemsContainer