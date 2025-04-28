local pluginContainer = script.Parent.Parent

local Fusion = require(pluginContainer.Packages.Fusion)
local Children = Fusion.Children

local Macro = require(pluginContainer.Components.Macro)
local Theme = require(pluginContainer.Components.Theme)

type Macro = {
	Module: ModuleScript,
	Reference: LuaSourceContainer?,
}

local function MacroContainer(
	scope: Fusion.Scope,
	props: {
		Macros: Fusion.UsedAs<{ Macro }>,
	}
)
	local inner = scope:innerScope { Macro = Macro }

	return inner:New "ScrollingFrame" {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Colors.Background,

		ScrollBarThickness = 0,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
			},
			Layout = inner:New "UIListLayout" {
				Padding = UDim.new(0, 2),
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
