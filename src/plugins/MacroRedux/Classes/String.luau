local pluginContainer = script.Parent.Parent

local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local Children = Fusion.Children

local Entry = require(pluginContainer.Components.Entry)
local Theme = require(pluginContainer.Components.Theme)

local function StringItemClass(
	scope: Fusion.Scope,
	macroItem: Types.ValueMacroItem<string>
)
	local inner = scope:innerScope { Entry = Entry }
	local value = scope:Value(macroItem.Value)
	local displayText = scope:Value(macroItem.Name or macroItem.Text)

	local function setValueInternal(newValue: string)
		local oldValue = macroItem.Value
		macroItem.Value = newValue

		value:set(newValue)

		if type(macroItem.Changed) == "function" then
			macroItem:Changed(newValue, oldValue)
		end
	end

	function macroItem:SetValue(newValue: string)
		setValueInternal(newValue)
	end

	function macroItem:UpdateText(newText: string)
		displayText:set(newText)
	end

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

				Text = displayText,
				TextSize = 16,
				TextColor3 = Theme.Colors.BrightText,
				FontFace = Theme.Font,
			},

			Entry = inner:Entry {
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.5, 1),

				Text = value,
				PlaceholderText = displayText,

				Callback = function(text: string)
					setValueInternal(text)
				end,
			},
		},
	}
end

return StringItemClass
