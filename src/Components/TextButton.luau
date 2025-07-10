local ConFusion = require "@packages/ConFusion"

local Theme = require "@utility/Theme"
local getButtonStyle = require "@utility/getButtonStyle"

local Button = require "@components/Button"

local function TextButton(
	scope: ConFusion.Scope,
	props: Button._buttonProps & {
		text: ConFusion.UsedAs<string>?,
		textXAlignment: ConFusion.UsedAs<Enum.TextXAlignment>?,
		textYAlignment: ConFusion.UsedAs<Enum.TextYAlignment>?,
		textSize: ConFusion.UsedAs<number>?,
		textColor: ConFusion.UsedAs<Color3>?,
	}
)
	local inner = scope:innerScope {
		Button = Button,
	}

	return inner:Button {
		anchorPoint = props.anchorPoint,
		size = props.size,
		sizeConstraint = props.sizeConstraint,
		position = props.position,
		layoutOrder = props.layoutOrder,

		style = props.style,

		callback = props.callback,

		contents = inner:New "TextLabel" {
			Size = UDim2.fromScale(1, 1),

			BackgroundTransparency = 1,

			Text = props.text,
			TextXAlignment = props.textXAlignment,
			TextYAlignment = props.textYAlignment,
			TextSize = props.textSize,
			TextColor3 = props.textColor
				or inner:Computed(function(use: ConFusion.Use)
					return use(getButtonStyle(use(props.style), "Text"))
				end),
			FontFace = Theme.Font.Regular,
			TextTruncate = Enum.TextTruncate.AtEnd,
		},
	}
end

return TextButton
