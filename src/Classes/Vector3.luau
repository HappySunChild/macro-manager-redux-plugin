local Types = require "@plugin/Types"

local updateItemValue = require "@utility/updateItemValue"

local Fusion = require "@packages/Fusion"
local t = require "@packages/t"

local ElementGroup = require "@components/ElementGroup"
local Label = require "@components/Label"
local TextEntry = require "@components/TextEntry"

local Children = Fusion.Children
local peek = Fusion.peek

local default = t.default(Vector3.zero, t.Vector3)

local function Vector3ItemClass(
	scope: Fusion.Scope,
	macroItem: Types.ValueMacroItem<Vector3>
)
	macroItem.Value = default(macroItem.Value)

	local inner = scope:innerScope {
		TextEntry = TextEntry,
		ElementGroup = ElementGroup,
		Label = Label,
	}
	local value = inner:Value(macroItem.Value or Vector3.zero)
	local displayText = inner:Value(macroItem.Text or "Vector3")

	local xFieldRef = inner:Value()
	local yFieldRef = inner:Value()
	local zFieldRef = inner:Value()

	local function getInputValue()
		local xField = peek(xFieldRef) :: TextBox
		local yField = peek(yFieldRef) :: TextBox
		local zField = peek(zFieldRef) :: TextBox

		return Vector3.new(
			tonumber(xField.Text) or 0,
			tonumber(yField.Text) or 0,
			tonumber(zField.Text) or 0
		)
	end

	local function setValueInternal(newValue: Vector3)
		value:set(newValue)

		updateItemValue(macroItem, newValue)
	end

	function macroItem:SetValue(newValue: Vector3)
		assert(t.Vector3(newValue))

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

				Render = function(scope: typeof(inner), _, label: string)
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

				Labels = { "X", "Y", "Z" },
				Refs = { xFieldRef, yFieldRef, zFieldRef },
			},
		},
	}
end

return Vector3ItemClass
