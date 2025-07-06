local Types = require "@plugin/Types"

local ConFusion = require "@packages/ConFusion"
local RenderStyles = require "@self/Styles"
local t = require "@packages/t"

local Label = require "@components/Label"

local logging = require "@utility/Logging"
local updateItemValue = require "@utility/updateItemValue"

local Children = ConFusion.Children

local default = t.default(Color3.new(0, 0, 0), t.Color3)

type Color3MacroItem = Types.ValueMacroItem<Color3> & {
	Style: string,
}

local function Color3MacroItem(
	scope: ConFusion.Scope,
	macroItem: Color3MacroItem
)
	macroItem.Value = default(macroItem.Value)

	local inner = scope:innerScope { Label = Label }
	local displayText = inner:Value(macroItem.Text or "Color3")
	local value = inner:Value(macroItem.Value)

	local function setInternalValue(newValue: Color3)
		value:set(newValue)

		updateItemValue(macroItem, newValue)
	end

	function macroItem:SetValue(newValue: Color3)
		assert(t.Color3(newValue))

		setInternalValue(newValue)
	end

	function macroItem:UpdateText(newText: string)
		assert(t.string(newText))

		macroItem.Text = newText

		displayText:set(newText)
	end

	macroItem.Set = macroItem.SetValue

	local renderStyle = RenderStyles[macroItem.Style or "RGB"]

	if not renderStyle then
		renderStyle = RenderStyles.RGB

		warn(`Color3 render style '{macroItem.Style}' does not exist.`)
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
			InputElements = renderStyle(inner, {
				color = value,
				setColor = setInternalValue,
			}),
		},
	}
end

return Color3MacroItem
