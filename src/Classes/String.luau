local Types = require "@plugin/Types"

local updateItemValue = require "@utility/updateItemValue"

local Fusion = require "@packages/Fusion"
local t = require "@packages/t"

local Label = require "@components/Label"
local TextEntry = require "@components/TextEntry"

local Children = Fusion.Children

local default = t.default("", t.string)

local function StringItemClass(
	scope: Fusion.Scope,
	macroItem: Types.ValueMacroItem<string>
)
	macroItem.Value = default(macroItem.Value)

	local inner = scope:innerScope { TextEntry = TextEntry, Label = Label }
	local value = scope:Value(macroItem.Value)
	local displayText = scope:Value(macroItem.Text or "String")

	local function setValueInternal(newValue: string)
		value:set(newValue)

		updateItemValue(macroItem, newValue)
	end

	function macroItem:SetValue(newValue: string)
		assert(t.string(newValue))

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
					setValueInternal(text)
				end,
			},
		},
	}
end

return StringItemClass
