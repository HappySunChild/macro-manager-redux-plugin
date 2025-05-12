local pluginContainer = script.Parent.Parent

local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local TextButton = require(pluginContainer.Components.TextButton)

local Children = Fusion.Children

local default = t.default("Button", t.string)

type ButtonMacroItem = Types.MacroItem & {
	Activate: (ButtonMacroItem) -> (),
	Activated: (ButtonMacroItem) -> (),
}

local function ButtonMacroItem(scope: Fusion.Scope, macroItem: ButtonMacroItem)
	macroItem.Text = default(macroItem.Text)

	local inner = scope:innerScope { TextButton = TextButton }
	local displayText = inner:Value(macroItem.Text)

	-- for backwards compatibility
	macroItem.Activate = macroItem.Activate or macroItem.Activated

	function macroItem:UpdateText(newText: string)
		assert(t.strict(newText))

		macroItem.Text = newText

		displayText:set(newText)
	end

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 24),

		BackgroundTransparency = 1,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
			},

			Button = inner:TextButton {
				Size = UDim2.fromScale(1, 1),

				Text = displayText,
				TextSize = 18,

				Callback = if macroItem.Activate
					then function()
						macroItem:Activate()
					end
					else nil,
			},
		},
	}
end

return ButtonMacroItem
