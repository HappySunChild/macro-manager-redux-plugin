local pluginContainer = script.Parent.Parent

local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local Entry = require(pluginContainer.Components.Entry)
local Group = require(pluginContainer.Components.Group)
local Theme = require(pluginContainer.Components.Theme)

local Children = Fusion.Children
local peek = Fusion.peek

local function Vector3ItemClass(
	scope: Fusion.Scope,
	macroItem: Types.ValueMacroItem<Vector3>
)
	macroItem.Value = t.default(Vector3.zero, t.Vector3)(macroItem.Value)

	local inner = scope:innerScope { Entry = Entry, Group = Group }
	local value = inner:Value(macroItem.Value or Vector3.zero)
	local displayText =
		inner:Value(macroItem.Name or macroItem.Text or "Vector3")

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
		local oldValue = macroItem.Value
		macroItem.Value = newValue

		value:set(newValue)

		if type(macroItem.Changed) == "function" then
			macroItem:Changed(newValue, oldValue)
		end
	end

	function macroItem:SetValue(newValue: Vector3)
		assert(t.Vector3(newValue))

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

			Input = inner:Group {
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.5, 1),

				Padding = UDim.new(0, 4),

				Render = function(
					scope: typeof(inner),
					index: number,
					label: string
				)
					return scope:Entry {
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
