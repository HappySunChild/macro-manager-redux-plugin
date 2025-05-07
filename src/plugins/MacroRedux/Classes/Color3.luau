local pluginContainer = script.Parent.Parent

local Theme = require(pluginContainer.Utility.Theme)
local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local ElementGroup = require(pluginContainer.Components.ElementGroup)
local RoundBorder = require(pluginContainer.Components.RoundBorder)
local TextEntry = require(pluginContainer.Components.TextEntry)

local Children, Ref = Fusion.Children, Fusion.Ref
local peek = Fusion.peek

local default = t.default(Color3.new(0, 0, 0), t.Color3)

local function ColorDisplay(
	scope: Fusion.Scope,
	props: { Color: Fusion.UsedAs<Color3> }
)
	local inner = scope:innerScope { RoundBorder = RoundBorder }

	return inner:New "Frame" {
		Size = UDim2.fromOffset(20, 20),

		BackgroundColor3 = props.Color,

		[Children] = {
			Border = inner:RoundBorder {
				Color = Theme.Colors.InputFieldBorder,
			},
			Flex = inner:New "UIFlexItem" {},
		},
	}
end

local RenderStyles = {
	Hex = function(
		scope: Fusion.Scope,
		props: {
			Value: Fusion.Value<Color3>,
			Callback: (Color3) -> (),
		}
	)
		local inner = scope:innerScope {
			ColorDisplay = ColorDisplay,
			ElementGroup = ElementGroup,
			TextEntry = TextEntry,
		}

		local hexFieldRef = inner:Value()

		local function getInputValue()
			local hexField = peek(hexFieldRef) :: TextBox

			local value = Color3.new(0, 0, 0)

			pcall(function()
				value = Color3.fromHex(hexField.Text)
			end)

			return value
		end

		return inner:ElementGroup {
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.5, 1),

			Padding = UDim.new(0, 4),

			Labels = {},
			Refs = {},

			[Children] = {
				Entry = inner:TextEntry {
					Text = inner:Computed(function(use: Fusion.Use)
						return `#{use(props.Value):ToHex()}`
					end),
					PlaceholderText = "Hex",
					Size = UDim2.fromScale(1, 1),

					Callback = function()
						props.Callback(getInputValue())
					end,

					[Ref] = hexFieldRef,
				},
				Display = inner:ColorDisplay { Color = props.Value },
			},
		}
	end,
	HSV = function(
		scope: Fusion.Scope,
		props: {
			Value: Fusion.Value<Color3>,
			Callback: (Color3) -> (),
		}
	)
		local inner = scope:innerScope {
			ColorDisplay = ColorDisplay,
			ElementGroup = ElementGroup,
			TextEntry = TextEntry,
		}

		local hueFieldRef = inner:Value()
		local saturationFieldRef = inner:Value()
		local valueFieldRef = inner:Value()

		local function getInputValue()
			local hueField = peek(hueFieldRef) :: TextBox
			local saturationField = peek(saturationFieldRef) :: TextBox
			local valueField = peek(valueFieldRef) :: TextBox

			local hue = tonumber(hueField.Text) or 0
			local saturation = tonumber(saturationField.Text) or 0
			local value = tonumber(valueField.Text) or 0

			return Color3.fromHSV(
				math.clamp(hue / 360, 0, 1),
				math.clamp(saturation / 100, 0, 1),
				math.clamp(value / 100, 0, 1)
			)
		end

		return inner:ElementGroup {
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.5, 1),

			Padding = UDim.new(0, 4),

			Render = function(
				scope: typeof(inner),
				index: number,
				label: string
			)
				return scope:TextEntry {
					Size = UDim2.fromScale(1, 1),

					Text = scope:Computed(function(use: Fusion.Use)
						local components = { use(props.Value):ToHSV() }
						local value = components[index]

						if index == 1 then
							return math.floor(value * 360) % 360
						end

						return math.floor(value * 100)
					end),
					PlaceholderText = label,

					Callback = function()
						props.Callback(getInputValue())
					end,
				}
			end,
			Labels = { "H", "S", "V" },
			Refs = { hueFieldRef, saturationFieldRef, valueFieldRef },

			[Children] = {
				Display = inner:ColorDisplay { Color = props.Value },
			},
		}
	end,
	RGB = function(
		scope: Fusion.Scope,
		props: {
			Value: Fusion.Value<Color3>,
			Callback: (Color3) -> (),
		}
	)
		local inner = scope:innerScope {
			ColorDisplay = ColorDisplay,
			ElementGroup = ElementGroup,
			TextEntry = TextEntry,
		}

		local redFieldRef = inner:Value()
		local greenFieldRef = inner:Value()
		local blueFieldRef = inner:Value()

		local function getInputValue()
			local redField = peek(redFieldRef) :: TextBox
			local greenField = peek(greenFieldRef) :: TextBox
			local blueField = peek(blueFieldRef) :: TextBox

			return Color3.fromRGB(
				tonumber(redField.Text) or 0,
				tonumber(greenField.Text) or 0,
				tonumber(blueField.Text) or 0
			)
		end

		return inner:ElementGroup {
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.5, 1),

			Padding = UDim.new(0, 4),

			Render = function(
				scope: typeof(inner),
				index: number,
				label: string
			)
				return scope:TextEntry {
					Size = UDim2.fromScale(1, 1),

					Text = inner:Computed(function(use: Fusion.Use)
						return math.floor(use(props.Value)[label] * 255)
					end),
					PlaceholderText = label,

					Callback = function()
						props.Callback(getInputValue())
					end,
				}
			end,
			Labels = { "R", "G", "B" },
			Refs = { redFieldRef, greenFieldRef, blueFieldRef },

			[Children] = {
				Display = inner:ColorDisplay { Color = props.Value },
			},
		}
	end,
}

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
