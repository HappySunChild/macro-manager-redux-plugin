local Types = require "@plugin/Types"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local ElementGroup = require "@components/ElementGroup"
local TextButton = require "@components/TextButton"

local Children = ConFusion.Children

local default = t.default({ "Button" }, t.table)

type ButtonGroupMacroItem = Types.MacroItem & {
	Buttons: { string },

	Activate: (ButtonGroupMacroItem, index: number) -> (),
	Activated: (ButtonGroupMacroItem, index: number) -> (),
}

local function ButtonGroupMacroItem(
	scope: ConFusion.Scope,
	macroItem: ButtonGroupMacroItem
)
	macroItem.Buttons = default(macroItem.Buttons)

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
			padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
			},

			buttons = inner:ElementGroup {
				size = UDim2.fromScale(1, 1),
				padding = UDim.new(0, 4),

				labels = buttons,

				render = function(
					scope: typeof(inner),
					index: number,
					label: string
				)
					return scope:TextButton {
						size = UDim2.fromScale(0, 1),
						layoutOrder = index,

						text = label,
						textSize = 18,
						callback = function()
							if not macroItem.Activate then
								return
							end

							macroItem:Activate(index)
						end,
					}
				end,
			},
		},
	}
end

return ButtonGroupMacroItem
