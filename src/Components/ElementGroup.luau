local ConFusion = require "@packages/ConFusion"

local Children = ConFusion.Children

type UsedAs<V> = ConFusion.UsedAs<V>

local function ElementGroup(
	scope: ConFusion.Scope,
	props: {
		anchorPoint: UsedAs<Vector2>,
		position: UsedAs<UDim2>?,
		size: UsedAs<UDim2>?,
		automaticSize: UsedAs<Enum.AutomaticSize>?,

		padding: UsedAs<UDim>?,
		fillDirection: UsedAs<Enum.FillDirection>?,

		horizontalAlignment: UsedAs<Enum.HorizontalAlignment>?,
		verticalAlignment: UsedAs<Enum.VerticalAlignment>?,
		flexAlignment: UsedAs<Enum.UIFlexAlignment>?,

		render: ((
			scope: ConFusion.Scope,
			index: number,
			label: string
		) -> ConFusion.Child)?,
		labels: UsedAs<{ string }>?,
		refs: { ConFusion.Value<Instance> }?,

		[ConFusion.SpecialKey<"Children">]: { ConFusion.Child }?,
	}
)
	local labels = props.labels
	local refs = props.refs or {}

	local inner = scope:innerScope()
	local elements = if labels
		then inner:ForPairs(
			labels,
			function(_, forScope: typeof(inner), index: number, label: string)
				local element = props.render(forScope, index, label)

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
		AnchorPoint = props.anchorPoint,
		Position = props.position,
		Size = props.size,
		AutomaticSize = props.automaticSize,

		BackgroundTransparency = 1,

		[Children] = {
			layout = inner:New "UIListLayout" {
				FillDirection = props.fillDirection
					or Enum.FillDirection.Horizontal,

				HorizontalAlignment = props.horizontalAlignment
					or Enum.HorizontalAlignment.Center,
				HorizontalFlex = props.flexAlignment
					or Enum.UIFlexAlignment.Fill,

				VerticalAlignment = props.verticalAlignment
					or Enum.VerticalAlignment.Center,
				VerticalFlex = props.flexAlignment or Enum.UIFlexAlignment.Fill,

				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = props.padding,
			},

			elements = elements,
			children = props[Children],
		},
	}
end

return ElementGroup
