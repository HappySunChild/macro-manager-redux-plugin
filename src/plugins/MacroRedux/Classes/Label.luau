local pluginContainer = script.Parent.Parent

local Theme = require(pluginContainer.Utility.Theme)
local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local Children = Fusion.Children

local default = t.default("Label", t.string)

local function LabelMacroItem(scope: Fusion.Scope, macroItem: Types.MacroItem)
	macroItem.Text = default(macroItem.Text)

	local inner = scope:innerScope()
	local displayText = inner:Value(macroItem.Text)

	function macroItem:UpdateText(newText: string)
		assert(t.string(newText))

		macroItem.Text = newText

		displayText:set(newText)
	end

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundTransparency = 1,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},

			Label = inner:New "TextLabel" {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,

				BackgroundTransparency = 1,

				RichText = macroItem.RichText == true,

				Text = displayText,
				TextXAlignment = macroItem.TextXAlignment,
				TextYAlignment = macroItem.TextYAlignment,
				TextSize = 16,
				TextWrapped = true,
				TextColor3 = Theme.Colors.Text,
				FontFace = Theme.Font,
			},
		},
	}
end

return LabelMacroItem
