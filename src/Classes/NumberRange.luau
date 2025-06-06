local Types = require "@plugin/Types"

local updateItemValue = require "@utility/updateItemValue"

local Fusion = require "@packages/Fusion"
local t = require "@packages/t"

local ElementGroup = require "@components/ElementGroup"
local Label = require "@components/Label"
local TextEntry = require "@components/TextEntry"

local Children = Fusion.Children
local peek = Fusion.peek

local default = t.default(NumberRange.new(0, 1), t.NumberRange)

local function NumberRangeMacroItem(
	scope: Fusion.Scope,
	macroItem: Types.ValueMacroItem<NumberRange>
)
	macroItem.Value = default(macroItem.Value)

	local inner = scope:innerScope {
		TextEntry = TextEntry,
		ElementGroup = ElementGroup,
		Label = Label,
	}
	local value = inner:Value(macroItem.Value)
	local displayText = inner:Value(macroItem.Text or "NumberRange")

	local maxFieldRef = inner:Value()
	local minFieldRef = inner:Value()

	local function getInputValue()
		local maxField = peek(maxFieldRef) :: TextBox
		local minField = peek(minFieldRef) :: TextBox

		local max = tonumber(maxField.Text) or 0
		local min = tonumber(minField.Text) or 0

		return NumberRange.new(math.min(min, max), math.max(min, max))
	end

	local function setValueInternal(newValue: NumberRange)
		value:set(newValue)

		updateItemValue(newValue)
	end

	function macroItem:UpdateText(newText: string)
		assert(t.string(newText))

		macroItem.Text = newText

		displayText:set(newText)
	end

	function macroItem:SetValue(newValue: NumberRange)
		assert(t.NumberRange(newValue))

		setValueInternal(newValue)
	end

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 24),

		BackgroundTransparency = 1,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},

			Label = inner:Label {
				Size = UDim2.fromScale(0.5, 1),
				Text = displayText,
			},
			InputElements = inner:ElementGroup {
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.5, 1),

				Padding = UDim.new(0, 4),

				Render = function(scope: typeof(inner), _, label: string)
					return scope:TextEntry {
						Size = UDim2.fromScale(1, 1),

						Text = scope:Computed(function(use: Fusion.Use)
							return use(value)[label]
						end),
						PlaceholderText = label,

						Callback = function()
							setValueInternal(getInputValue())
						end,
					}
				end,
				Labels = { "Min", "Max" },
				Refs = { minFieldRef, maxFieldRef },
			},
		},
	}
end

return NumberRangeMacroItem
