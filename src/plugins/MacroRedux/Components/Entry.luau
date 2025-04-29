local pluginContainer = script.Parent.Parent

local Fusion = require(pluginContainer.Packages.Fusion)

local Theme = require(pluginContainer.Components.Theme)
local OnEvent, Out = Fusion.OnEvent, Fusion.Out
local peek = Fusion.peek

local function Entry(
	scope: Fusion.Scope,
	props: {
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		Position: Fusion.UsedAs<UDim2>?,
		Size: Fusion.UsedAs<UDim2>?,
		SizeConstraint: Fusion.UsedAs<Enum.SizeConstraint>?,

		PlaceholderText: string?,
		Text: string?,
		TextSize: number?,

		Callback: (string) -> (),
	}
)
	local text = scope:Value(props.Text or "")

	return scope:New "TextBox" {
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		Position = props.Position,

		BackgroundColor3 = Theme.Colors.InputFieldBackground,

		BorderColor3 = Theme.Colors.InputFieldBorder,
		BorderSizePixel = 1,

		PlaceholderText = props.PlaceholderText,
		PlaceholderColor3 = Theme.Colors.DimmedText,

		Text = props.Text,
		TextSize = props.TextSize or 18,
		TextColor3 = Theme.Colors.SubText,
		TextTruncate = Enum.TextTruncate.AtEnd,
		FontFace = Theme.Font,

		[Out "Text"] = text,
		[OnEvent "FocusLost"] = function()
			props.Callback(peek(text))
		end,
	}
end

return Entry
