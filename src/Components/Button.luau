local ConFusion = require "@packages/ConFusion"
local Theme = require "@utility/Theme"

local RoundBorder = require "@components/RoundBorder"

local Children = ConFusion.Children
local OnEvent, Out = ConFusion.OnEvent, ConFusion.Out

export type _buttonProps = {
	AnchorPoint: ConFusion.UsedAs<Vector2>?,
	Size: ConFusion.UsedAs<UDim2>?,
	SizeConstraint: ConFusion.UsedAs<Enum.SizeConstraint>?,
	Position: ConFusion.UsedAs<UDim2>?,
	LayoutOrder: ConFusion.UsedAs<number>?,

	BorderColor: ConFusion.UsedAs<Color3>?,
	HoverBorderColor: ConFusion.UsedAs<Color3>?,

	IdleColor: ConFusion.UsedAs<Color3>?,
	PressColor: ConFusion.UsedAs<Color3>?,
	HoverColor: ConFusion.UsedAs<Color3>?,

	Callback: () -> (),
}

local function Button(
	scope: ConFusion.Scope,
	props: _buttonProps & {
		Contents: ConFusion.Child,
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

	-- I wanted to just use a Frame, but there's not a good way to reimplement MouseButton1Click
	-- without having to connect a bunch of events
	return inner:New "ImageButton" {
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		SizeConstraint = props.SizeConstraint,
		Position = props.Position,
		LayoutOrder = props.LayoutOrder,

		BackgroundColor3 = color,

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

			Contents = props.Contents,
		},
	}
end

return Button
