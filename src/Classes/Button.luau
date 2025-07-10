local Types = require "@plugin/Types"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local TextButton = require "@components/TextButton"

local Children = ConFusion.Children

local styleType = t.union(t.string, t.table)
local default = t.default("Button", t.string)
local defaultStyle = t.default(nil, styleType)

type ButtonMacroItem = Types.MacroItem & {
	Style: string,
	Activate: (ButtonMacroItem) -> (),
	Activated: (ButtonMacroItem) -> (),
}

local function ButtonMacroItem(
	scope: ConFusion.Scope,
	macroItem: ButtonMacroItem
)
	macroItem.Text = default(macroItem.Text)
	macroItem.Style = defaultStyle(macroItem.Style)

	local inner = scope:innerScope { TextButton = TextButton }
	local displayText = inner:Value(macroItem.Text)
	local displayStyle = inner:Value(macroItem.Style)

	-- for backwards compatibility
	macroItem.Activate = macroItem.Activate or macroItem.Activated

	function macroItem:UpdateText(newText: string)
		assert(t.string(newText))

		macroItem.Text = newText

		displayText:set(newText)
	end

	function macroItem:UpdateStyle(newStyle: string)
		assert(styleType(newStyle))

		macroItem.Style = newStyle

		displayStyle:set(newStyle)
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

			button = inner:TextButton {
				size = UDim2.fromScale(1, 1),

				text = displayText,
				textSize = 18,

				style = displayStyle,

				callback = function()
					if not macroItem.Activate then
						return
					end

					macroItem:Activate()
				end,
			},
		},
	}
end

return ButtonMacroItem
