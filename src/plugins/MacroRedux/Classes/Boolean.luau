local pluginContainer = script.Parent.Parent

local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local map, peek = Fusion.map, Fusion.peek
local Children = Fusion.Children

local Button = require(pluginContainer.Components.Button)
local Theme = require(pluginContainer.Components.Theme)

local function BooleanMacroItem(
	scope: Fusion.Scope,
	macroItem: Types.ValueMacroItem<boolean>
)
	local inner = scope:innerScope { Button = Button }
	local value = inner:Value(macroItem.Value)

	local function setValueInternal(newValue: boolean)
		local oldValue = macroItem.Value
		macroItem.Value = newValue

		value:set(newValue)

		if type(macroItem.Changed) == "function" then
			macroItem:Changed(newValue, oldValue)
		end
	end

	function macroItem:SetValue(newValue: boolean)
		setValueInternal(newValue)
	end

	return inner:New "Frame" {
		BackgroundColor3 = Theme.Colors.ItemBackground,

		Size = UDim2.new(1, 0, 0, 24),

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

				Text = macroItem.Name or macroItem.Text or "Boolean",
				TextColor3 = Theme.Colors.BrightText,
				TextSize = 16,
				FontFace = Theme.Font,
			},

			Button = inner:Button {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,

				IdleColor = Theme.Colors.InputFieldBackground,
				BorderColor = Theme.Colors.InputFieldBorder,

				Text = map(value, function(v: boolean)
					return if v then "✓" else ""
				end),
				TextSize = 24,
				TextColor = Theme.Colors.BrightText,

				Callback = function()
					local newValue = not peek(value)

					setValueInternal(newValue)
				end,
			},
		},
	}
end

return BooleanMacroItem
