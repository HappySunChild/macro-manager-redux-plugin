local pluginContainer = script.Parent.Parent

local Theme = require(pluginContainer.Utility.Theme)
local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local Children = Fusion.Children

local default = t.default("Title", t.string)

local function Title(scope: Fusion.Scope, macroItem: Types.MacroItem)
	macroItem.Text = default(macroItem.Text)

	local inner = scope:innerScope()
	local displayText = inner:Value(macroItem.Text)

	function macroItem:UpdateText(newText: string)
		assert(t.string(newText))

		macroItem.Text = newText

		displayText:set(newText)
	end

	macroItem.InSection = nil
	macroItem.SectionDepth = nil

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 26),

		BackgroundTransparency = 1,

		[Children] = {
			Label = inner:New "TextLabel" {
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
