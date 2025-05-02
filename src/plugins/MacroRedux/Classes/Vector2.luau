local pluginContainer = script.Parent.Parent

local Theme = require(pluginContainer.Utility.Theme)
local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local ElementGroup = require(pluginContainer.Components.ElementGroup)
local TextEntry = require(pluginContainer.Components.TextEntry)

local Children = Fusion.Children
local peek = Fusion.peek

local function Vector2ItemClass(
	scope: Fusion.Scope,
	macroItem: Types.ValueMacroItem<Vector2>
)
	macroItem.Value = t.default(Vector2.zero, t.Vector2)(macroItem.Value)

	local inner =
		scope:innerScope { TextEntry = TextEntry, ElementGroup = ElementGroup }
	local value = inner:Value(macroItem.Value or Vector2.zero)
	local displayText =
		inner:Value(macroItem.Name or macroItem.Text or "Vector2")

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
		local oldValue = macroItem.Value
		macroItem.Value = newValue

		value:set(newValue)

		if type(macroItem.Changed) == "function" then
			macroItem:Changed(newValue, oldValue)
		end
	end

	function macroItem:SetValue(newValue: Vector2)
		assert(t.Vector2(newValue))

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
				TextSize = 16,
				TextColor3 = Theme.Colors.BrightText,
				FontFace = Theme.Font,
			},

			Input = inner:ElementGroup {
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.5, 1),

				Padding = UDim.new(0, 4),

				Render = function(
					scope: typeof(inner),
					index: number,
					label: string
				)
					return scope:TextEntry {
						PlaceholderText = label,
						Size = UDim2.fromScale(1, 1),

						Text = scope:Computed(function(use)
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
