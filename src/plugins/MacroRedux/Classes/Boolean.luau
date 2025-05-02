local pluginContainer = script.Parent.Parent

local Theme = require(pluginContainer.Utility.Theme)
local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local TextButton = require(pluginContainer.Components.TextButton)

local map, peek = Fusion.map, Fusion.peek
local Children = Fusion.Children

local function BooleanMacroItem(
	scope: Fusion.Scope,
	macroItem: Types.ValueMacroItem<boolean>
)
	macroItem.Value = t.default(false, t.boolean)(macroItem.Value)

	local inner = scope:innerScope { TextButton = TextButton }
	local value = inner:Value(macroItem.Value)
	local displayText =
		inner:Value(macroItem.Name or macroItem.Text or "Boolean")

	local function setValueInternal(newValue: boolean)
		local oldValue = macroItem.Value
		macroItem.Value = newValue

		value:set(newValue)

		if type(macroItem.Changed) == "function" then
			macroItem:Changed(newValue, oldValue)
		end
	end

	function macroItem:SetValue(newValue: boolean)
		assert(t.boolean(newValue))

		setValueInternal(newValue)
	end

	function macroItem:UpdateText(newText: string)
		assert(t.string(newText))

		displayText:set(newText)
	end

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

			Label = inner:New "TextLabel" {
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,

				BackgroundTransparency = 1,

				Text = displayText,
				TextColor3 = Theme.Colors.BrightText,
				TextSize = 16,
				FontFace = Theme.Font,
			},

			Button = inner:TextButton {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,

				IdleColor = Theme.Colors.InputFieldBackground,
				BorderColor = Theme.Colors.InputFieldBorder,

				Text = map(value, function(v: boolean)
					return if v then "✓" else ""
				end),
				TextSize = 24,
				TextColor = Theme.Colors.BrightText,

				Callback = function()
					local newValue = not peek(value)

					setValueInternal(newValue)
				end,
			},
		},
	}
end

return BooleanMacroItem
