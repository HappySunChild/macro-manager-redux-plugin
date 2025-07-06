local ConFusion = require "@packages/ConFusion"
local Theme = require "@utility/Theme"

local RoundBorder = require "@components/RoundBorder"

local peek = ConFusion.peek

local Children, Ref = ConFusion.Children, ConFusion.Ref
local OnEvent, OnChange, Out =
	ConFusion.OnEvent, ConFusion.OnChange, ConFusion.Out

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
		TextXAlignment: Enum.TextXAlignment,
		TextYAlignment: Enum.TextYAlignment,

		Callback: (string) -> (),
		TypingCallback: (string) -> (),

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

		TextXAlignment = props.TextXAlignment,
		TextYAlignment = props.TextYAlignment,

		[Out "Text"] = text,
		[OnChange "Text"] = props.TypingCallback,
		[OnEvent "Focused"] = function()
			isFocused:set(true)
		end,
		[OnEvent "FocusLost"] = function()
			isFocused:set(false)

			if props.Callback then
				props.Callback(peek(text))
			end
		end,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
			},
			Border = inner:RoundBorder {
				Color = inner:Tween(borderColor, Theme.TweenInfo.Highlight),
			},
		},
		[Ref] = props[Ref],
	}
end

return TextEntry
