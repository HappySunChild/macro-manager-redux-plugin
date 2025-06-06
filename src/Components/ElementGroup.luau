local Fusion = require "@packages/Fusion"

local Children = Fusion.Children

local function ElementGroup(
	scope: Fusion.Scope,
	props: {
		AnchorPoint: Fusion.UsedAs<Vector2>,
		Position: Fusion.UsedAs<UDim2>?,
		Size: Fusion.UsedAs<UDim2>?,
		AutomaticSize: Fusion.UsedAs<Enum.AutomaticSize>?,

		Padding: Fusion.UsedAs<UDim>?,
		FillDirection: Fusion.UsedAs<Enum.FillDirection>?,

		HorizontalAlignment: Fusion.UsedAs<Enum.HorizontalAlignment>?,
		VerticalAlignment: Fusion.UsedAs<Enum.VerticalAlignment>?,
		FlexAlignment: Fusion.UsedAs<Enum.UIFlexAlignment>?,

		Render: ((
			scope: Fusion.Scope,
			index: number,
			label: string
		) -> Fusion.Child)?,
		Labels: Fusion.UsedAs<{ string }>?,
		Refs: { Fusion.Value<Fusion.Child> }?,

		[Fusion.SpecialKey<"Children">]: { Fusion.Child }?,
	}
)
	local labels = props.Labels
	local refs = props.Refs or {}

	local inner = scope:innerScope()
	local elements = if labels
		then inner:ForPairs(
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
		else nil

	return inner:New "Frame" {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,
		AutomaticSize = props.AutomaticSize,

		BackgroundTransparency = 1,

		[Children] = {
			Layout = inner:New "UIListLayout" {
				FillDirection = props.FillDirection
					or Enum.FillDirection.Horizontal,

				HorizontalAlignment = props.HorizontalAlignment
					or Enum.HorizontalAlignment.Center,
				HorizontalFlex = props.FlexAlignment
					or Enum.UIFlexAlignment.Fill,

				VerticalAlignment = props.VerticalAlignment
					or Enum.VerticalAlignment.Center,
				VerticalFlex = props.FlexAlignment or Enum.UIFlexAlignment.Fill,

				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = props.Padding,
			},

			Elements = elements,
			Children = props[Children],
		},
	}
end

return ElementGroup
