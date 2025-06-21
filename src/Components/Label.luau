local Fusion = require "@packages/Fusion"
local Theme = require "@utility/Theme"

local function Label(
	scope: Fusion.Scope,
	props: {
		Position: UDim2,
		Size: UDim2,

		Text: Fusion.UsedAs<string>,
	}
)
	return scope:New "TextLabel" {
		Position = props.Position,
		Size = props.Size,

		BackgroundTransparency = 1,

		Text = props.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextSize = 16,
		TextColor3 = Theme.Color.BrightText,
		FontFace = Theme.Font.Regular,
	}
end

return Label
