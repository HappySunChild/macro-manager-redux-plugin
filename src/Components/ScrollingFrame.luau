local Fusion = require "@packages/Fusion"

local Theme = require "@utility/Theme"

local Assets = require "@plugin/Assets"

local Children, Out = Fusion.Children, Fusion.Out

local DEFAULT_SCROLLBAR_WIDTH = 9

local function ScrollingFrame(
	scope: Fusion.Scope,
	props: {
		Position: Fusion.UsedAs<UDim2>?,
		Size: Fusion.UsedAs<UDim2>?,
		CanvasSize: Fusion.UsedAs<UDim2>?,
		AutomaticSize: Fusion.UsedAs<Enum.AutomaticSize>?,
		AutomaticCanvasSize: Fusion.UsedAs<Enum.AutomaticSize>?,

		ScrollBarThickness: number,

		Visible: Fusion.UsedAs<boolean>?,
		BackgroundColor3: Fusion.UsedAs<Color3>?,
		ZIndex: Fusion.UsedAs<number>?,

		[Fusion.SpecialKey<"Children">]: Fusion.Child?,
	}
)
	local inner = scope:innerScope()
	local windowSize = inner:Value(Vector2.zero)
	local canvasSize = inner:Value(Vector2.zero)
	local scrollBarVisible = inner:Computed(function(use: Fusion.Use)
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
				function(use: Fusion.Use, scope: Fusion.Scope)
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
