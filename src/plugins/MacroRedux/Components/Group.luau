local pluginContainer = script.Parent.Parent

local Fusion = require(pluginContainer.Packages.Fusion)
local Children = Fusion.Children

local function Group(
	scope: Fusion.Scope,
	props: {
		AnchorPoint: Fusion.UsedAs<Vector2>,
		Position: Fusion.UsedAs<UDim2>?,
		Size: Fusion.UsedAs<UDim2>?,

		Padding: Fusion.UsedAs<UDim>?,

		Render: (index: number, label: string) -> Fusion.Child,
		Labels: { string },

		[Fusion.SpecialKey<"Children">]: { Fusion.Child }?,
	}
)
	local inner = scope:innerScope()
	local elements = {}

	for index, label in props.Labels do
		local element = props.Render(index, label)

		if not element then
			continue
		end

		table.insert(elements, element)
	end

	return inner:New "Frame" {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,

		BackgroundTransparency = 1,

		[Children] = {
			Layout = inner:New "UIListLayout" {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				Padding = props.Padding,
			},

			Elements = elements,
			Children = props[Children],
		},
	}
end

return Group
