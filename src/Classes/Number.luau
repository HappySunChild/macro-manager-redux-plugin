local Types = require "@plugin/Types"

local updateItemValue = require "@utility/updateItemValue"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local Label = require "@components/Label"
local TextEntry = require "@components/TextEntry"

local Children = ConFusion.Children

local default = t.default(0, t.number)

local function NumberMacroItem(
	scope: ConFusion.Scope,
	macroItem: Types.ValueMacroItem<number>
)
	macroItem.Value = default(macroItem.Value)

	local inner = scope:innerScope { TextEntry = TextEntry, Label = Label }
	local value = inner:Value(macroItem.Value)
	local displayText = inner:Value(macroItem.Text or "Number")

	local function setValueInternal(newValue: number)
		value:set(newValue)

		updateItemValue(macroItem, newValue)
	end

	function macroItem:SetValue(newValue: number)
		assert(t.number(newValue))

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
