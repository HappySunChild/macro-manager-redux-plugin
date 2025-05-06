local pluginContainer = script.Parent.Parent

local Fusion = require(pluginContainer.Packages.Fusion)
local Children = Fusion.Children

local function ElementGroup(
	scope: Fusion.Scope,
	props: {
		AnchorPoint: Fusion.UsedAs<Vector2>,
		Position: Fusion.UsedAs<UDim2>?,
		Size: Fusion.UsedAs<UDim2>?,

		Padding: Fusion.UsedAs<UDim>?,

		Render: (
			scope: Fusion.Scope,
			index: number,
			label: string
		) -> Fusion.Child,
		Labels: Fusion.UsedAs<{ string }>,
		Refs: { Fusion.Value<Fusion.Child> }?,

		[Fusion.SpecialKey<"Children">]: { Fusion.Child }?,
	}
)
	local labels = props.Labels
	local refs = props.Refs or {}

	local inner = scope:innerScope()
	local elements = inner:ForPairs(
		labels,
		function(_, forScope: typeof(inner), index: number, label: string)
			local element = props.Render(forScope, index, label)

			if not element then
				return index
			end

			local ref = refs[index]

			if ref ~= nil then
				ref:set(element)
			end

			return index, element
		end
	)

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
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = props.Padding,
			},

			Elements = elements,
			Children = props[Children],
		},
	}
end

return ElementGroup
