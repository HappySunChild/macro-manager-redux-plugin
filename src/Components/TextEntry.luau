local ConFusion = require "@packages/ConFusion"
local Theme = require "@utility/Theme"

local RoundBorder = require "@components/RoundBorder"

local peek = ConFusion.peek
local Children, Ref, OnEvent, Out =
	ConFusion.Children, ConFusion.Ref, ConFusion.OnEvent, ConFusion.Out

local function TextEntry(
	scope: ConFusion.Scope,
	props: {
		AnchorPoint: ConFusion.UsedAs<Vector2>?,
		Position: ConFusion.UsedAs<UDim2>?,
		Size: ConFusion.UsedAs<UDim2>?,
		SizeConstraint: ConFusion.UsedAs<Enum.SizeConstraint>?,

		PlaceholderText: string?,
		Text: string?,
		TextSize: number?,

		Callback: (string) -> (),

		[ConFusion.SpecialKey<"Ref">]: ConFusion.Value<unknown>?,
	}
)
	local inner = scope:innerScope { RoundBorder = RoundBorder }
	local text = inner:Value(peek(props.Text) or "")

	local isFocused = inner:Value(false)
	local borderColor = inner:Computed(function(use)
		if use(isFocused) then
			return use(Theme.Color.AccentBorder)
		end

		return use(Theme.Color.InputField.Border)
	end)

	return inner:New "TextBox" {
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		Position = props.Position,

		BackgroundColor3 = Theme.Color.InputField.Background,

		PlaceholderText = props.PlaceholderText,
		PlaceholderColor3 = Theme.Color.DimmedText,

		Text = props.Text,
		TextSize = props.TextSize or 18,
		TextColor3 = Theme.Color.Text,
		TextTruncate = Enum.TextTruncate.AtEnd,
		FontFace = Theme.Font.Regular,

		[Out "Text"] = text,
		[OnEvent "Focused"] = function()
			isFocused:set(true)
		end,
		[OnEvent "FocusLost"] = function()
			isFocused:set(false)

			props.Callback(peek(text))
		end,

		[Children] = inner:RoundBorder {
			Color = inner:Tween(borderColor, Theme.TweenInfo.Highlight),
		},
		[Ref] = props[Ref],
	}
end

return TextEntry
