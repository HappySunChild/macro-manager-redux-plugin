local ConFusion = require "@packages/ConFusion"

local Theme = require "@utility/Theme"

local function Label(
	scope: ConFusion.Scope,
	props: {
		position: UDim2,
		size: UDim2,

		text: ConFusion.UsedAs<string>,
	}
)
	return scope:New "TextLabel" {
		Position = props.position,
		Size = props.size,

		BackgroundTransparency = 1,

		Text = props.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextSize = 16,
		TextColor3 = Theme.Color.BrightText,
		FontFace = Theme.Font.Regular,
	}
end

return Label
