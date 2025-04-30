local pluginContainer = script.Parent.Parent

local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local Children = Fusion.Children

local Button = require(pluginContainer.Components.Button)
local Theme = require(pluginContainer.Components.Theme)

type ButtonMacroItem = Types.MacroItem & {
	Activate: () -> (),
	Activated: () -> (),
}

local function ButtonMacroItem(scope: Fusion.Scope, macroItem: ButtonMacroItem)
	local inner = scope:innerScope { Button = Button }

	-- for backwards compatibility
	macroItem.Activate = macroItem.Activate or macroItem.Activated

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 24),

		BackgroundColor3 = Theme.Colors.ItemBackground,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
			},

			Button = inner:Button {
				Size = UDim2.fromScale(1, 1),

				Text = macroItem.Text,
				TextSize = 18,

				Callback = if macroItem.Activate
					then function()
						macroItem.Activate()
					end
					else nil,
			},
		},
	}
end

return ButtonMacroItem
