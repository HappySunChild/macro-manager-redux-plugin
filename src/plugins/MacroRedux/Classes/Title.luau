local pluginContainer = script.Parent.Parent

local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local Theme = require(pluginContainer.Components.Theme)

local Children = Fusion.Children

local function Title(scope: Fusion.Scope, macroItem: Types.MacroItem)
	local inner = scope:innerScope()
	local displayText = inner:Value(macroItem.Text or "Title")

	function macroItem:UpdateText(newText: string)
		assert(t.string(newText))

		displayText:set(newText)
	end

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 26),

		BackgroundColor3 = Theme.Colors.MacroBackground,
		BackgroundTransparency = 1,

		[Children] = {
			Label = inner:New "TextLabel" {
				Size = UDim2.fromScale(1, 1),

				BackgroundTransparency = 1,

				Text = displayText,
				TextSize = 18,
				TextColor3 = Theme.Colors.Text,
				FontFace = Font.new(Theme.Font.Family, Enum.FontWeight.Bold),
			},
		},
	}
end

return Title
