local pluginContainer = script.Parent.Parent

local Theme = require(pluginContainer.Utility.Theme)
local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local Children = Fusion.Children

local Macro = require(script.Macro)

local function MacroContainer(
	scope: Fusion.Scope,
	props: {
		Macros: Fusion.UsedAs<{ Types.Macro }>,
	}
)
	local inner =
		scope:innerScope { Macro = Macro, ScrollingFrame = ScrollingFrame }

	return inner:New "ScrollingFrame" {
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,

		BackgroundColor3 = Theme.Colors.MainBackground,
		ScrollBarThickness = 0,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
			},
			Layout = inner:New "UIListLayout" {
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
			},

			Macros = inner:ForPairs(
				props.Macros,
				function(_, forInner: typeof(inner), key: number, value: Macro)
					return key, forInner:Macro(value)
				end
			),
		},
	}
end

return MacroContainer
