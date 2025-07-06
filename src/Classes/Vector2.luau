local Types = require "@plugin/Types"

local updateItemValue = require "@utility/updateItemValue"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local ElementGroup = require "@components/ElementGroup"
local Label = require "@components/Label"
local TextEntry = require "@components/TextEntry"

local Children = ConFusion.Children
local peek = ConFusion.peek

local default = t.default(Vector2.zero, t.Vector2)

local function Vector2ItemClass(
	scope: ConFusion.Scope,
	macroItem: Types.ValueMacroItem<Vector2>
)
	macroItem.Value = default(macroItem.Value)

	local inner = scope:innerScope {
		TextEntry = TextEntry,
		ElementGroup = ElementGroup,
		Label = Label,
	}
	local value = inner:Value(macroItem.Value or Vector2.zero)
	local displayText = inner:Value(macroItem.Text or "Vector2")

	local xFieldRef = inner:Value()
	local yFieldRef = inner:Value()

	local function getInputValue()
		local xField = peek(xFieldRef) :: TextBox
		local yField = peek(yFieldRef) :: TextBox

		return Vector2.new(
			tonumber(xField.Text) or 0,
			tonumber(yField.Text) or 0
		)
	end

	local function setValueInternal(newValue: Vector2)
		value:set(newValue)

		updateItemValue(macroItem, newValue)
	end

	function macroItem:SetValue(newValue: Vector2)
		assert(t.Vector2(newValue))

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
			InputElements = inner:ElementGroup {
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.5, 1),

				Padding = UDim.new(0, 4),

				Render = function(
					scope: typeof(inner),
					_: number,
					label: string
				)
					return scope:TextEntry {
						PlaceholderText = label,
						Size = UDim2.fromScale(1, 1),

						Text = scope:Computed(function(use: ConFusion.Use)
							return string.format("%.2f", use(value)[label])
						end),

						Callback = function()
							setValueInternal(getInputValue())
						end,
					}
				end,

				Labels = { "X", "Y" },
				Refs = { xFieldRef, yFieldRef },
			},
		},
	}
end

return Vector2ItemClass
