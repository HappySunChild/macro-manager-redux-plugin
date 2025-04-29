local pluginContainer = script.Parent.Parent

local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local Children = Fusion.Children

local Entry = require(pluginContainer.Components.Entry)
local Theme = require(pluginContainer.Components.Theme)

local class = {}
local METATABLE = table.freeze { __index = class }

local function NumberMacroItem(scope: Fusion.Scope, macroItem: Types.MacroItem)
	setmetatable(macroItem, METATABLE)

	local name = macroItem.Name or macroItem.Text

	local inner = scope:innerScope { Entry = Entry }

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 24),

		BackgroundColor3 = Theme.Colors.ItemBackground,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
			},

			Label = inner:New "TextLabel" {
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,

				BackgroundTransparency = 1,

				Text = name,
				TextColor3 = Theme.Colors.BrightText,
				TextSize = 16,
				FontFace = Theme.Font,
			},

			Entry = inner:Entry {
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.5, 1),

				PlaceholderText = name,

				Callback = function(text: string)
					macroItem.Value = tonumber(text) or 0
				end,
			},
		},
	}
end

return NumberMacroItem
