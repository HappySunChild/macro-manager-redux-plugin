local pluginContainer = script.Parent.Parent

local Theme = require(pluginContainer.Utility.Theme)
local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local Children = Fusion.Children

local default = t.default(Color3.new(0, 0, 0), t.Color3)

local RenderStyles = require(script.Styles)

local function Color3MacroItem(
	scope: Fusion.Scope,
	macroItem: Types.ValueMacroItem<Color3>
)
	macroItem.Value = default(macroItem.Value)

	local inner = scope:innerScope()
	local displayText =
		inner:Value(macroItem.Text or macroItem.Name or "Color3")
	local value = inner:Value(macroItem.Value)

	local function setInternalValue(newValue: Color3)
		local oldValue = macroItem.Value
		macroItem.Value = newValue

		value:set(newValue)

		if type(macroItem.Changed) == "function" then
			macroItem:Changed(newValue, oldValue)
		end
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

			Label = inner:New "TextLabel" {
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,

				BackgroundTransparency = 1,

				Text = displayText,
				TextSize = 16,
				TextColor3 = Theme.Colors.BrightText,
				FontFace = Theme.Font,
			},
			InputElements = renderStyle(inner, {
				Value = value,
				Callback = setInternalValue,
			}),
		},
	}
end

return Color3MacroItem
