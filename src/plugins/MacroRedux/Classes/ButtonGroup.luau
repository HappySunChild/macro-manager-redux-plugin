local pluginContainer = script.Parent.Parent

local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local ElementGroup = require(pluginContainer.Components.ElementGroup)
local TextButton = require(pluginContainer.Components.TextButton)

local Children = Fusion.Children

type ButtonGroupMacroItem = Types.MacroItem & {
	Buttons: { string },

	Activate: (ButtonGroupMacroItem, index: number) -> (),
	Activated: (ButtonGroupMacroItem, index: number) -> (),
}

local function ButtonGroupMacroItem(
	scope: Fusion.Scope,
	macroItem: ButtonGroupMacroItem
)
	macroItem.Buttons = t.default({ "Default" }, t.table)(macroItem.Buttons)

	local inner = scope:innerScope {
		TextButton = TextButton,
		ElementGroup = ElementGroup,
	}
	local buttons = scope:Value(macroItem.Buttons)

	macroItem.Activate = macroItem.Activate or macroItem.Activated

	function macroItem:UpdateText(index: number, newText: string)
		assert(t.number(index))
		assert(t.string(newText))

		local currentButtons = macroItem.Buttons
		currentButtons[index] = newText

		buttons:set(currentButtons)
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

			Buttons = inner:ElementGroup {
				Size = UDim2.fromScale(1, 1),

				Padding = UDim.new(0, 4),

				Render = function(
					scope: typeof(inner),
					index: number,
					label: string
				)
					return scope:TextButton {
						Size = UDim2.fromScale(0, 1),
						LayoutOrder = index,

						Text = label,
						TextSize = 18,
						Callback = if macroItem.Activate
							then function()
								macroItem:Activate(index)
							end
							else nil,
					}
				end,

				Labels = buttons,
				Refs = {},
			},
		},
	}
end

return ButtonGroupMacroItem
