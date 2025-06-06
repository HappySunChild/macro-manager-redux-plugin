local Theme = require "@utility/Theme"
local Types = require "@plugin/Types"

local Fusion = require "@packages/Fusion"

local Macro = require "@self/Macro"
local RoundBorder = require "@components/RoundBorder"

local Children = Fusion.Children

local function MacroContainer(
	scope: Fusion.Scope,
	props: {
		Macros: Fusion.UsedAs<{ Types.Macro }>,
	}
)
	local inner = scope:innerScope { Macro = Macro, RoundBorder = RoundBorder }

	return inner:New "ScrollingFrame" {
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,

		BackgroundColor3 = Theme.Color.MainBackground,
		ScrollBarThickness = 0,

		[Children] = {
			Layout = inner:New "UIListLayout" {
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
			},

			Macros = inner:Computed(
				function(use: Fusion.Use, scope: typeof(inner))
					local macros = use(props.Macros)

					if #macros == 0 then
						return scope:New "TextLabel" {
							Size = UDim2.new(1, 0, 0, 30),

							BackgroundColor3 = Theme.Color.Macro.Background,

							Text = "No macros detected :(",
							TextSize = 18,
							TextColor3 = Theme.Color.Text,

							[Children] = inner:RoundBorder {
								Thickness = 0,
							},
						}
					end

					local list = {}

					for _, macro in macros do
						table.insert(list, scope:Macro(macro))
					end

					return list
				end
			),
		},
	}
end

return MacroContainer
