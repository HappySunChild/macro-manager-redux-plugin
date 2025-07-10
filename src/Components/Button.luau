local ConFusion = require "@packages/ConFusion"

local Theme = require "@utility/Theme"
local getButtonStyle = require "@utility/getButtonStyle"

local RoundBorder = require "@components/RoundBorder"

local Children = ConFusion.Children
local OnEvent, Out = ConFusion.OnEvent, ConFusion.Out

export type _buttonProps = {
	anchorPoint: ConFusion.UsedAs<Vector2>?,
	size: ConFusion.UsedAs<UDim2>?,
	sizeConstraint: ConFusion.UsedAs<Enum.SizeConstraint>?,
	position: ConFusion.UsedAs<UDim2>?,
	layoutOrder: ConFusion.UsedAs<number>?,

	style: Theme.ButtonStyle | string?,

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

	local backgroundColor = inner:Computed(function(use)
		local style = use(props.style)
		local current = use(state) :: Enum.GuiState

		if current == Enum.GuiState.Hover then
			return use(getButtonStyle(style, "HoverBackground"))
		elseif current == Enum.GuiState.Press then
			return use(getButtonStyle(style, "PressedBackground"))
		end

		return use(getButtonStyle(style, "Background"))
	end)

	local borderColor = inner:Computed(function(use)
		local style = use(props.style)

		if getButtonStyle(style, "HasBorder") == false then
			return use(backgroundColor)
		end

		local current = use(state)

		if current == Enum.GuiState.Hover then
			return use(
				getButtonStyle(style, "HoverBorder") or Theme.Color.AccentBorder
			)
		end

		return use(getButtonStyle(style, "Border"))
	end)

	-- I wanted to just use a Frame, but there's not a good way to reimplement MouseButton1Click
	-- without having to connect a bunch of events
	return inner:New "ImageButton" {
		AnchorPoint = props.anchorPoint,
		Size = props.size,
		SizeConstraint = props.sizeConstraint,
		Position = props.position,
		LayoutOrder = props.layoutOrder,

		BackgroundColor3 = backgroundColor,

		[Out "GuiState"] = state,
		[OnEvent "MouseButton1Click"] = props.callback,

		[Children] = {
			border = inner:RoundBorder {
				color = borderColor,
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
