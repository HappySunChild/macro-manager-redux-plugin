local Types = require "@plugin/Types"

local Theme = require "@utility/Theme"
local updateItemValue = require "@utility/updateItemValue"

local Fusion = require "@packages/Fusion"
local t = require "@packages/t"

local Label = require "@components/Label"
local TextButton = require "@components/TextButton"

local map, peek = Fusion.map, Fusion.peek
local Children = Fusion.Children

local default = t.default(false, t.boolean)

local function BooleanMacroItem(
	scope: Fusion.Scope,
	macroItem: Types.ValueMacroItem<boolean>
)
	macroItem.Value = default(macroItem.Value)

	local inner = scope:innerScope { TextButton = TextButton, Label = Label }
	local value = inner:Value(macroItem.Value)
	local displayText = inner:Value(macroItem.Text or "Boolean")

	local function setValueInternal(newValue: boolean)
		value:set(newValue)

		updateItemValue(macroItem, newValue)
	end

	function macroItem:SetValue(newValue: boolean)
		assert(t.boolean(newValue))

		setValueInternal(newValue)
	end

	function macroItem:UpdateText(newText: string)
		assert(t.string(newText))

		macroItem.Text = newText

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

			Label = inner:Label {
				Size = UDim2.fromScale(0.5, 1),
				Text = displayText,
			},
			Checkbox = inner:TextButton {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,

				IdleColor = Theme.Color.InputField.Background,
				BorderColor = Theme.Color.InputField.Border,

				Text = map(value, function(v: boolean)
					return if v then "✓" else ""
				end),
				TextSize = 24,
				TextColor = Theme.Color.BrightText,

				Callback = function()
					local newValue = not peek(value)

					setValueInternal(newValue)
				end,
			},
		},
	}
end

return BooleanMacroItem
