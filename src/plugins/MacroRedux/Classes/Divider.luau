local pluginContainer = script.Parent.Parent

local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local Theme = require(pluginContainer.Components.Theme)

local Children = Fusion.Children

local function DividerMacroItem(scope: Fusion.Scope, macroItem: Types.MacroItem)
	local inner = scope:innerScope()
	local displayText =
		inner:Value(macroItem.Text or macroItem.Name or "Divider")

	function macroItem:UpdateText(newText: string)
		assert(t.strict(newText))

		displayText:set(newText)
	end

	return inner:New "Frame" {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 26),

		[Children] = {
			Label = inner:New "TextLabel" {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(0, 16),
				AutomaticSize = Enum.AutomaticSize.X,

				BackgroundColor3 = Theme.Colors.ItemBackground,

				Text = displayText,
				TextColor3 = Theme.Colors.SubText,
				FontFace = Theme.Font,

				[Children] = {
					Padding = inner:New "UIPadding" {
						PaddingLeft = UDim.new(0, 2),
						PaddingRight = UDim.new(0, 2),
					},
				},
			},
			Line = inner:New "Frame" {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(0.95, 0, 0, 1),

				BackgroundColor3 = Theme.Colors.DimmedText,
			},
		},
	}
end

return DividerMacroItem
