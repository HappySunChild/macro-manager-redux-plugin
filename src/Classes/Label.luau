local Theme = require "@utility/Theme"
local Types = require "@plugin/Types"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local Children = ConFusion.Children

local defaultText = t.default("Label", t.string)
local defaultSelectable = t.default(nil, t.literal(true)) -- either true or nil

type LabelMacroItem = Types.MacroItem & {
	Selectable: boolean?,
	RichText: boolean?,
	TextXAlignment: Enum.TextXAlignment?,
	TextYAlignment: Enum.TextYAlignment?,
}

local function LabelMacroItem(scope: ConFusion.Scope, macroItem: LabelMacroItem)
	macroItem.Text = defaultText(macroItem.Text)
	macroItem.Selectable = defaultSelectable(macroItem.Selectable)

	local inner = scope:innerScope()
	local displayText = inner:Value(macroItem.Text)

	function macroItem:UpdateText(newText: string)
		assert(t.string(newText))

		macroItem.Text = newText

		displayText:set(newText)
	end

	local labelType = macroItem.Selectable and "TextBox" or "TextLabel"

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundTransparency = 1,

		[Children] = {
			padding = inner:New "UIPadding" {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},

			label = inner:New(labelType) {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,

				BackgroundTransparency = 1,

				RichText = macroItem.RichText == true,

				Text = displayText,
				TextXAlignment = macroItem.TextXAlignment,
				TextYAlignment = macroItem.TextYAlignment,
				TextSize = 16,
				TextWrapped = true,
				TextColor3 = Theme.Color.Text,
				FontFace = Theme.Font.Regular,

				TextEditable = macroItem.Selectable and false,
				ClearTextOnFocus = macroItem.Selectable and false,
			},
		},
	}
end

return LabelMacroItem
