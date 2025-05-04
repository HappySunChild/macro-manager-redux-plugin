local pluginContainer = script.Parent.Parent

local Theme = require(pluginContainer.Utility.Theme)
local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local Children = Fusion.Children

local function DividerMacroItem(scope: Fusion.Scope, macroItem: Types.MacroItem)
	local inner = scope:innerScope()
	local displayText =
		inner:Value(macroItem.Text or macroItem.Name or "")

	function macroItem:UpdateText(newText: string)
		assert(t.strict(newText))

		displayText:set(newText)
	end

	macroItem.InSection = nil
	macroItem.SectionDepth = nil

	return inner:New "Frame" {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 26),

		[Children] = {
			Label = inner:Computed(
				function(use: Fusion.Use, scope: typeof(inner))
					if use(displayText) == "" then
						return
					end

					return scope:New "TextLabel" {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(0, 16),
						AutomaticSize = Enum.AutomaticSize.X,

						BackgroundColor3 = Theme.Colors.ItemBackground,

						Text = displayText,
						TextColor3 = Theme.Colors.SubText,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center,
						FontFace = Theme.Font,

						[Children] = {
							Padding = inner:New "UIPadding" {
								PaddingLeft = UDim.new(0, 2),
								PaddingRight = UDim.new(0, 2),
							},
						},
					}
				end
			),
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
