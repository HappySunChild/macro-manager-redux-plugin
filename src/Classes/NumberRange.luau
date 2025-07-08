local Types = require "@plugin/Types"

local updateItemValue = require "@utility/updateItemValue"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local ElementGroup = require "@components/ElementGroup"
local Label = require "@components/Label"
local TextEntry = require "@components/TextEntry"

local Children = ConFusion.Children
local peek = ConFusion.peek

local default = t.default(NumberRange.new(0, 1), t.NumberRange)

local function NumberRangeMacroItem(
	scope: ConFusion.Scope,
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

		task.spawn(updateItemValue, macroItem, newValue)
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
			padding = inner:New "UIPadding" {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},

			label = inner:Label {
				size = UDim2.fromScale(0.5, 1),
				text = displayText,
			},
			input = inner:ElementGroup {
				position = UDim2.fromScale(0.5, 0),
				size = UDim2.fromScale(0.5, 1),
				padding = UDim.new(0, 4),

				labels = { "Min", "Max" },
				refs = { minFieldRef, maxFieldRef },
				render = function(scope: typeof(inner), _, label: string)
					return scope:TextEntry {
						size = UDim2.fromScale(1, 1),

						text = scope:Computed(function(use: ConFusion.Use)
							return use(value)[label]
						end),
						placeholderText = label,

						callback = function()
							setValueInternal(getInputValue())
						end,
					}
				end,
			},
		},
	}
end

return NumberRangeMacroItem
