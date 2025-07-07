local ConFusion = require "@packages/ConFusion"
local Theme = require "@utility/Theme"

local RoundBorder = require "@components/RoundBorder"

local Children = ConFusion.Children
local OnEvent, Out = ConFusion.OnEvent, ConFusion.Out

export type _buttonProps = {
	anchorPoint: ConFusion.UsedAs<Vector2>?,
	size: ConFusion.UsedAs<UDim2>?,
	sizeConstraint: ConFusion.UsedAs<Enum.SizeConstraint>?,
	position: ConFusion.UsedAs<UDim2>?,
	layoutOrder: ConFusion.UsedAs<number>?,

	borderColor: ConFusion.UsedAs<Color3>?,
	hoverBorderColor: ConFusion.UsedAs<Color3>?,

	idleColor: ConFusion.UsedAs<Color3>?,
	pressColor: ConFusion.UsedAs<Color3>?,
	hoverColor: ConFusion.UsedAs<Color3>?,

	callback: () -> (),
}

local function Button(
	scope: ConFusion.Scope,
	props: _buttonProps & {
		contents: ConFusion.Child,
	}
)
	local inner = scope:innerScope {
		RoundBorder = RoundBorder,
	}
	local state = inner:Value(Enum.GuiState.Idle)
	local color = inner:Computed(function(use)
		local current = use(state) :: Enum.GuiState

		if current == Enum.GuiState.Hover then
			return use(props.hoverColor or Theme.Color.Button.HoverBackground)
		elseif current == Enum.GuiState.Press then
			return use(props.pressColor or Theme.Color.Button.PressedBackground)
		end

		return use(props.idleColor or Theme.Color.Button.Background)
	end)

	local borderColor = inner:Computed(function(use)
		local current = use(state)

		if current == Enum.GuiState.Hover then
			return use(props.borderColor or Theme.Color.AccentBorder)
		end

		return use(props.borderColor or Theme.Color.Button.Border)
	end)

	-- I wanted to just use a Frame, but there's not a good way to reimplement MouseButton1Click
	-- without having to connect a bunch of events
	return inner:New "ImageButton" {
		AnchorPoint = props.anchorPoint,
		Size = props.size,
		SizeConstraint = props.sizeConstraint,
		Position = props.position,
		LayoutOrder = props.layoutOrder,

		BackgroundColor3 = color,

		[Out "GuiState"] = state,
		[OnEvent "MouseButton1Click"] = props.callback,

		[Children] = {
			border = inner:RoundBorder {
				color = inner:Tween(borderColor, Theme.TweenInfo.Hover),
			},
			padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},

			contents = props.contents,
		},
	}
end

return Button
