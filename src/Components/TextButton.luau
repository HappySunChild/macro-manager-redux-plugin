local Fusion = require "@packages/Fusion"
local Theme = require "@utility/Theme"

local RoundBorder = require "@components/RoundBorder"

local Children = Fusion.Children
local OnEvent, Out = Fusion.OnEvent, Fusion.Out

local function TextButton(
	scope: Fusion.Scope,
	props: {
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		Size: Fusion.UsedAs<UDim2>?,
		SizeConstraint: Fusion.UsedAs<Enum.SizeConstraint>?,
		Position: Fusion.UsedAs<UDim2>?,
		LayoutOrder: Fusion.UsedAs<number>?,

		BorderColor: Fusion.UsedAs<Color3>?,
		HoverBorderColor: Fusion.UsedAs<Color3>?,

		IdleColor: Fusion.UsedAs<Color3>?,
		PressColor: Fusion.UsedAs<Color3>?,
		HoverColor: Fusion.UsedAs<Color3>?,

		Text: Fusion.UsedAs<string>?,
		TextXAlignment: Fusion.UsedAs<Enum.TextXAlignment>?,
		TextYAlignment: Fusion.UsedAs<Enum.TextYAlignment>?,
		TextSize: Fusion.UsedAs<number>?,
		TextColor: Fusion.UsedAs<Color3>?,

		Callback: () -> (),
	}
)
	local inner = scope:innerScope {
		RoundBorder = RoundBorder,
	}
	local state = inner:Value(Enum.GuiState.Idle)
	local color = inner:Computed(function(use)
		local current = use(state) :: Enum.GuiState

		if current == Enum.GuiState.Hover then
			return use(props.HoverColor or Theme.Color.Button.HoverBackground)
		elseif current == Enum.GuiState.Press then
			return use(props.PressColor or Theme.Color.Button.PressedBackground)
		end

		return use(props.IdleColor or Theme.Color.Button.Background)
	end)

	local borderColor = inner:Computed(function(use)
		local current = use(state)

		if current == Enum.GuiState.Hover then
			return use(props.BorderColor or Theme.Color.AccentBorder)
		end

		return use(props.BorderColor or Theme.Color.Button.Border)
	end)

	return inner:New "TextButton" {
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		SizeConstraint = props.SizeConstraint,
		Position = props.Position,
		LayoutOrder = props.LayoutOrder,

		Text = props.Text,
		TextXAlignment = props.TextXAlignment,
		TextYAlignment = props.TextYAlignment,
		TextSize = props.TextSize,
		TextColor3 = props.TextColor or Theme.Color.Button.Text,
		FontFace = Theme.Font.Regular,
		TextTruncate = Enum.TextTruncate.AtEnd,

		BackgroundColor3 = inner:Tween(color, Theme.TweenInfo.Hover),

		[Out "GuiState"] = state,
		[OnEvent "MouseButton1Click"] = props.Callback,

		[Children] = {
			Border = inner:RoundBorder {
				Color = inner:Tween(borderColor, Theme.TweenInfo.Hover),
			},
			Padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},
		},
	}
end

return TextButton
