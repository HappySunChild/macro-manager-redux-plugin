local ConFusion = require "@packages/ConFusion"
local Theme = require "@utility/Theme"

local Button = require "@components/Button"

local function TextButton(
	scope: ConFusion.Scope,
	props: Button._buttonProps & {
		Text: ConFusion.UsedAs<string>?,
		TextXAlignment: ConFusion.UsedAs<Enum.TextXAlignment>?,
		TextYAlignment: ConFusion.UsedAs<Enum.TextYAlignment>?,
		TextSize: ConFusion.UsedAs<number>?,
		TextColor: ConFusion.UsedAs<Color3>?,
	}
)
	local inner = scope:innerScope {
		Button = Button,
	}

	return inner:Button {
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		SizeConstraint = props.SizeConstraint,
		Position = props.Position,
		LayoutOrder = props.LayoutOrder,

		BorderColor = props.BorderColor,
		HoverBorderColor = props.HoverBorderColor,

		IdleColor = props.IdleColor,
		PressColor = props.PressColor,
		HoverColor = props.HoverColor,

		Callback = props.Callback,

		Contents = inner:New "TextLabel" {
			Size = UDim2.fromScale(1, 1),

			BackgroundTransparency = 1,

			Text = props.Text,
			TextXAlignment = props.TextXAlignment,
			TextYAlignment = props.TextYAlignment,
			TextSize = props.TextSize,
			TextColor3 = props.TextColor or Theme.Color.Button.Text,
			FontFace = Theme.Font.Regular,
			TextTruncate = Enum.TextTruncate.AtEnd,
		},
	}
end

return TextButton
