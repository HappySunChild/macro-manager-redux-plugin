local Fusion = require "@packages/Fusion"

local Children = Fusion.Children

type UsedAs<V> = Fusion.UsedAs<V>

local function ElementGroup(
	scope: Fusion.Scope,
	props: {
		AnchorPoint: UsedAs<Vector2>,
		Position: UsedAs<UDim2>?,
		Size: UsedAs<UDim2>?,
		AutomaticSize: UsedAs<Enum.AutomaticSize>?,

		Padding: UsedAs<UDim>?,
		FillDirection: UsedAs<Enum.FillDirection>?,

		HorizontalAlignment: UsedAs<Enum.HorizontalAlignment>?,
		VerticalAlignment: UsedAs<Enum.VerticalAlignment>?,
		FlexAlignment: UsedAs<Enum.UIFlexAlignment>?,

		Render: ((
			scope: Fusion.Scope,
			index: number,
			label: string
		) -> Fusion.Child)?,
		Labels: UsedAs<{ string }>?,
		Refs: { Fusion.Value<Instance> }?,

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
