local pluginContainer = script.Parent.Parent

local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local Children = Fusion.Children

local Theme = require(pluginContainer.Components.Theme)

local function Title(scope: Fusion.Scope, macroItem: Types.MacroItem)
	local inner = scope:innerScope()
	local text = inner:Value(macroItem.Text)

	function macroItem:SetText(newText: string)
		text:set(newText)
	end

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 26),

		BackgroundColor3 = Theme.Colors.MacroBackground,

		[Children] = {
			Label = inner:New "TextLabel" {
				Size = UDim2.fromScale(1, 1),

				BackgroundTransparency = 1,

				Text = text,
				TextSize = 18,
				TextColor3 = Theme.Colors.Text,
				FontFace = Font.new(Theme.Font.Family, Enum.FontWeight.Bold),
			},
		},
	}
end

return Title
