local Types = require "@plugin/Types"

local Theme = require "@utility/Theme"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local Children = ConFusion.Children

local default = t.default("Title", t.string)

local function Title(scope: ConFusion.Scope, macroItem: Types.MacroItem)
	macroItem.Text = default(macroItem.Text)

	local inner = scope:innerScope()
	local displayText = inner:Value(macroItem.Text)

	function macroItem:UpdateText(newText: string)
		assert(t.string(newText))

		macroItem.Text = newText

		displayText:set(newText)
	end

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 26),

		BackgroundTransparency = 1,

		[Children] = {
			label = inner:New "TextLabel" {
				Size = UDim2.fromScale(1, 1),

				BackgroundTransparency = 1,

				Text = displayText,
				TextSize = 18,
				TextColor3 = Theme.Color.Text,
				FontFace = Theme.Font.Bold,
			},
		},
	}
end

return Title
