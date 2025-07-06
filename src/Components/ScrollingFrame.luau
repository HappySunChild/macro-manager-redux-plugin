local ConFusion = require "@packages/ConFusion"

local Theme = require "@utility/Theme"

local Assets = require "@plugin/Assets"

local Children, Out = ConFusion.Children, ConFusion.Out

local DEFAULT_SCROLLBAR_WIDTH = 9

local function ScrollingFrame(
	scope: ConFusion.Scope,
	props: {
		Position: ConFusion.UsedAs<UDim2>?,
		Size: ConFusion.UsedAs<UDim2>?,
		CanvasSize: ConFusion.UsedAs<UDim2>?,
		AutomaticSize: ConFusion.UsedAs<Enum.AutomaticSize>?,
		AutomaticCanvasSize: ConFusion.UsedAs<Enum.AutomaticSize>?,

		ScrollBarThickness: number,

		Visible: ConFusion.UsedAs<boolean>?,
		BackgroundColor3: ConFusion.UsedAs<Color3>?,
		ZIndex: ConFusion.UsedAs<number>?,

		[ConFusion.SpecialKey<"Children">]: ConFusion.Child?,
	}
)
	local inner = scope:innerScope()
	local windowSize = inner:Value(Vector2.zero)
	local canvasSize = inner:Value(Vector2.zero)
	local scrollBarVisible = inner:Computed(function(use: ConFusion.Use)
		return use(canvasSize).Y > use(windowSize).Y
	end)

	return inner:New "ScrollingFrame" {
		Position = props.Position,
		Size = props.Size,
		CanvasSize = props.CanvasSize,
		AutomaticSize = props.AutomaticSize,
		AutomaticCanvasSize = props.AutomaticCanvasSize,

		ScrollBarThickness = props.ScrollBarThickness
			or DEFAULT_SCROLLBAR_WIDTH,
		ScrollBarImageColor3 = Theme.Color.DimmedText,
		TopImage = Assets.Images.ScrollBar.Top,
		MidImage = Assets.Images.ScrollBar.Middle,
		BottomImage = Assets.Images.ScrollBar.Bottom,

		Visible = props.Visible,
		BackgroundColor3 = props.BackgroundColor3,
		ZIndex = props.ZIndex,

		[Out "AbsoluteWindowSize"] = windowSize,
		[Out "AbsoluteCanvasSize"] = canvasSize,
		[Children] = {
			ScrollbarPadding = inner:Computed(
				function(use: ConFusion.Use, scope: ConFusion.Scope)
					if not use(scrollBarVisible) then
						return nil
					end

					return scope:New "UIPadding" {
						PaddingRight = UDim.new(
							0,
							props.ScrollBarThickness or DEFAULT_SCROLLBAR_WIDTH
						),
					}
				end
			),
			Children = props[Children],
		},
	}
end

return ScrollingFrame
