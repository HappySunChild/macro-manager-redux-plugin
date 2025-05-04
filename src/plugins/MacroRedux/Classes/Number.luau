local pluginContainer = script.Parent.Parent

local Theme = require(pluginContainer.Utility.Theme)
local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)
local Children = Fusion.Children

local TextEntry = require(pluginContainer.Components.TextEntry)

local function NumberMacroItem(
	scope: Fusion.Scope,
	macroItem: Types.ValueMacroItem<number>
)
	macroItem.Value = tonumber(macroItem.Value) or 0

	local inner = scope:innerScope { TextEntry = TextEntry }
	local value = inner:Value(macroItem.Value)
	local displayText =
		inner:Value(macroItem.Name or macroItem.Text or "Number")

	local function setValueInternal(newValue: number)
		local oldValue = macroItem.Value
		macroItem.Value = newValue

		value:set(newValue)

		if type(macroItem.Changed) == "function" then
			macroItem:Changed(newValue, oldValue)
		end
	end

	function macroItem:SetValue(newValue: number)
		assert(t.number(newValue))

		setValueInternal(newValue)
	end

	function macroItem:UpdateText(newText: string)
		assert(t.string(newText))

		displayText:set(newText)
	end

	macroItem.Set = macroItem.SetValue

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 24),

		BackgroundTransparency = 1,

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

				Text = displayText,
				TextSize = 16,
				TextColor3 = Theme.Colors.BrightText,
				FontFace = Theme.Font,
			},

			Input = inner:TextEntry {
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.5, 1),

				Text = value,
				PlaceholderText = displayText,

				Callback = function(text: string)
					setValueInternal(tonumber(text) or 0)
				end,
			},
		},
	}
end

return NumberMacroItem
