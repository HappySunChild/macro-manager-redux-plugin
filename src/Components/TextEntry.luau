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
		anchorPoint: ConFusion.UsedAs<Vector2>?,
		position: ConFusion.UsedAs<UDim2>?,
		size: ConFusion.UsedAs<UDim2>?,
		sizeConstraint: ConFusion.UsedAs<Enum.SizeConstraint>?,

		placeholderText: string?,
		text: string?,
		textSize: number?,
		textXAlignment: Enum.TextXAlignment,
		textYAlignment: Enum.TextYAlignment,

		layoutOrder: number,

		callback: (string) -> (),
		typingCallback: (string) -> (),

		ref: ConFusion.Value<TextBox>?,
	}
)
	local inner = scope:innerScope { RoundBorder = RoundBorder }
	local text = inner:Value(peek(props.text) or "")

	local isFocused = inner:Value(false)
	local borderColor = inner:Computed(function(use: ConFusion.Use)
		if use(isFocused) then
			return use(Theme.Color.AccentBorder)
		end

		return use(Theme.Color.Border)
	end)

	return inner:New "TextBox" {
		AnchorPoint = props.anchorPoint,
		Size = props.size,
		Position = props.position,

		LayoutOrder = props.layoutOrder,

		BackgroundColor3 = Theme.Color.InputField.Background,

		PlaceholderText = props.placeholderText,
		PlaceholderColor3 = Theme.Color.DimmedText,

		Text = props.text,
		TextSize = props.textSize or 18,
		TextColor3 = Theme.Color.Text,
		TextTruncate = Enum.TextTruncate.AtEnd,
		FontFace = Theme.Font.Regular,

		TextXAlignment = props.textXAlignment,
		TextYAlignment = props.textYAlignment,

		[Out "Text"] = text,
		[OnChange "Text"] = props.typingCallback,
		[OnEvent "Focused"] = function()
			isFocused:set(true)
		end,
		[OnEvent "FocusLost"] = function()
			isFocused:set(false)

			if props.callback then
				props.callback(peek(text))
			end
		end,

		[Ref] = props.ref,
		[Children] = {
			padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
			},
			border = inner:RoundBorder {
				color = inner:Tween(borderColor, Theme.TweenInfo.Highlight),
			},
		},
	}
end

return TextEntry
