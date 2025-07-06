local Theme = require "@utility/Theme"
local Types = require "@plugin/Types"

local ConFusion = require "@packages/ConFusion"

local ContainerManager = require "@utility/ContainerManager"

local Macro = require "@self/Macro"
local RoundBorder = require "@components/RoundBorder"
local ScrollingFrame = require "@components/ScrollingFrame"

local Children = ConFusion.Children

local function NoMacrosLabel(scope: ConFusion.Scope)
	return scope:New "TextLabel" {
		Size = UDim2.new(1, 0, 0, 80),

		BackgroundColor3 = Theme.Color.Macro.Background,

		RichText = true,
		Text = `No macros detected :(<br/><br/>Add ModuleScripts into {ContainerManager.ContainerName}.Macros<br/>for them to appear here!`,
		TextSize = 18,
		TextColor3 = Theme.Color.DimmedText,

		[Children] = RoundBorder(scope, {
			Thickness = 0,
		}),
	}
end

local function MacroContainer(
	scope: ConFusion.Scope,
	props: {
		filter: ConFusion.UsedAs<string>,
		macros: ConFusion.UsedAs<{ Types.MacroReference }>,
	}
)
	local inner = scope:innerScope {
		NoMacrosLabel = NoMacrosLabel,
		Macro = Macro,
		ScrollingFrame = ScrollingFrame,
	}

	local function shouldShowMacro(macro: Types.Macro, use: ConFusion.Use)
		local filter = use(props.filter)

		return macro.Name:lower():match(filter) ~= nil
	end

	return inner:ScrollingFrame {
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,

		BackgroundColor3 = Theme.Color.MainBackground,
		ScrollBarThickness = 0,

		[Children] = {
			Layout = inner:New "UIListLayout" {
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder,
			},

			Macros = inner:Computed(
				function(use: ConFusion.Use, scope: typeof(inner))
					local macros = use(props.macros)

					if #macros == 0 then
						return scope:NoMacrosLabel()
					end

					local list = {}

					for _, macroReference in macros do
						table.insert(
							list,
							scope:Macro {
								reference = macroReference,
								shouldShow = shouldShowMacro,
							}
						)
					end

					return list
				end
			),
		},
	}
end

return MacroContainer
