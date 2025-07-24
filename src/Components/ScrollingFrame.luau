local ConFusion = require "@packages/ConFusion"

local Theme = require "@utility/Theme"

local Assets = require "@plugin/Assets"

local Children, Out = ConFusion.Children, ConFusion.Out

local DEFAULT_SCROLLBAR_WIDTH = 9

local function ScrollingFrame(
	scope: ConFusion.Scope,
	props: {
		position: ConFusion.UsedAs<UDim2>?,
		size: ConFusion.UsedAs<UDim2>?,
		canvasSize: ConFusion.UsedAs<UDim2>?,
		automaticSize: ConFusion.UsedAs<Enum.AutomaticSize>?,
		automaticCanvasSize: ConFusion.UsedAs<Enum.AutomaticSize>?,

		scrollBarThickness: number,

		visible: ConFusion.UsedAs<boolean>?,
		backgroundColor3: ConFusion.UsedAs<Color3>?,
		zIndex: ConFusion.UsedAs<number>?,

		[ConFusion.SpecialKey<"Children">]: ConFusion.Child?,
	}
)
	local inner = scope:innerScope()
	local windowSize = inner:Value(Vector2.zero)
	local canvasSize = inner:Value(Vector2.zero)
	local scrollBarVisible = inner:Computed(function(use: ConFusion.Use)
		return use(canvasSize).Y > use(windowSize).Y
	end)

	local _guiState = inner:Value(Enum.GuiState.Idle)
	local scrollbarColor = inner:Computed(function(use: ConFusion.Use)
		if use(_guiState) == Enum.GuiState.Idle then
			return use(Theme.Color.ScrollBar.Idle)
		end

		return use(Theme.Color.ScrollBar.Hover)
	end)

	return inner:New "ScrollingFrame" {
		Position = props.position,
		Size = props.size,
		CanvasSize = props.canvasSize,
		AutomaticSize = props.automaticSize,
		AutomaticCanvasSize = props.automaticCanvasSize,

		ScrollBarThickness = props.scrollBarThickness
			or DEFAULT_SCROLLBAR_WIDTH,
		ScrollBarImageColor3 = inner:Tween(
			scrollbarColor,
			Theme.TweenInfo.Highlight
		),
		TopImage = Assets.Images.ScrollBar.Top,
		MidImage = Assets.Images.ScrollBar.Middle,
		BottomImage = Assets.Images.ScrollBar.Bottom,

		Visible = props.visible,
		BackgroundColor3 = props.backgroundColor3,
		ZIndex = props.zIndex,

		[Out "AbsoluteWindowSize"] = windowSize,
		[Out "AbsoluteCanvasSize"] = canvasSize,
		[Out "GuiState"] = _guiState,

		[Children] = {
			padding = inner:Computed(
				function(use: ConFusion.Use, scope: ConFusion.Scope)
					if not use(scrollBarVisible) then
						return nil
					end

					return scope:New "UIPadding" {
						PaddingRight = UDim.new(
							0,
							props.scrollBarThickness or DEFAULT_SCROLLBAR_WIDTH
						),
					}
				end
			),
			children = props[Children],
		},
	}
end

return ScrollingFrame
