local Types = require "@plugin/Types"

local Theme = require "@utility/Theme"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local Children = ConFusion.Children

local default = t.default("", t.string)

local function DividerMacroItem(
	scope: ConFusion.Scope,
	macroItem: Types.MacroItem
)
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
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 26),

		[Children] = {
			Label = inner:Computed(
				function(use: ConFusion.Use, scope: typeof(inner))
					if use(displayText) == "" then
						return
					end

					return scope:New "TextLabel" {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(0, 16),
						AutomaticSize = Enum.AutomaticSize.X,

						BackgroundColor3 = Theme.Color.Item.Background,

						Text = displayText,
						TextColor3 = Theme.Color.SubText,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center,
						FontFace = Theme.Font.Regular,

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

				BackgroundColor3 = Theme.Color.DimmedText,
			},
		},
	}
end

return DividerMacroItem
