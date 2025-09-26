local types = require "@plugin/types"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local Theme = require "@utility/Theme"
local updateItemValue = require "@utility/updateItemValue"

local Label = require "@components/Label"
local TextButton = require "@components/TextButton"

local peek = ConFusion.peek
local Children = ConFusion.Children

local default = t.default(false, t.boolean)

local function BooleanMacroItem(
	scope: ConFusion.Scope,
	macroItem: types.ValueMacroItem<boolean>
)
	macroItem.Value = default(macroItem.Value)

	local inner = scope:innerScope { TextButton = TextButton, Label = Label }
	local value = inner:Value(macroItem.Value)
	local displayText = inner:Value(macroItem.Text or "Boolean")

	local function setValueInternal(newValue: boolean)
		value:set(newValue)

		task.spawn(updateItemValue, macroItem, newValue)
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
			padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
			},

			label = inner:Label {
				size = UDim2.fromScale(0.5, 1),
				text = displayText,
			},
			checkbox = inner:TextButton {
				anchorPoint = Vector2.new(1, 0),
				position = UDim2.fromScale(1, 0),
				size = UDim2.fromScale(1, 1),
				sizeConstraint = Enum.SizeConstraint.RelativeYY,

				style = Theme.ButtonStyle.Input,

				text = inner:Computed(function(use: ConFusion.Use)
					return if use(value) then "✓" else ""
				end),
				textSize = 24,
				textColor = Theme.Color.BrightText,

				callback = function()
					local newValue = not peek(value)

					setValueInternal(newValue)
				end,
			},
		},
	}
end

return BooleanMacroItem
