local pluginContainer = script.Parent.Parent

local Types = require(pluginContainer.Types)

local updateItemValue = require(pluginContainer.Utility.updateItemValue)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local Label = require(pluginContainer.Components.Label)

local Children = Fusion.Children

local default = t.default(Color3.new(0, 0, 0), t.Color3)

local RenderStyles = require(script.Styles)

local function Color3MacroItem(
	scope: Fusion.Scope,
	macroItem: Types.ValueMacroItem<Color3>
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
				Value = value,
				Callback = setInternalValue,
			}),
		},
	}
end

return Color3MacroItem
