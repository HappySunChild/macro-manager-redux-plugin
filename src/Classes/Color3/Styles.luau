local Theme = require "@utility/Theme"

local ColorPicker = require "@packages/ColorPicker"
local ConFusion = require "@packages/ConFusion"

local ElementGroup = require "@components/ElementGroup"
local RoundBorder = require "@components/RoundBorder"
local TextEntry = require "@components/TextEntry"

local Children, Ref, OnEvent =
	ConFusion.Children, ConFusion.Ref, ConFusion.OnEvent
local peek = ConFusion.peek

local function ColorDisplay(
	scope: ConFusion.Scope,
	props: {
		color: ConFusion.UsedAs<Color3>,
		setColor: (Color3) -> (),
	}
)
	local inner = scope:innerScope { RoundBorder = RoundBorder }

	return inner:New "Frame" {
		Size = UDim2.fromOffset(20, 20),

		BackgroundColor3 = props.color,

		[OnEvent "InputBegan"] = function(input: InputObject)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			local newColor = ColorPicker.prompt(peek(props.color))

			if not newColor then
				return
			end

			props.setColor(newColor)
		end,
		[Children] = {
			Flex = inner:New "UIFlexItem" {},
			Border = inner:RoundBorder {
				Color = Theme.Color.InputField.Border,
			},
		},
	}
end

type StyleProperties = {
	color: ConFusion.Value<Color3>,
	setColor: (Color3) -> (),
}

return table.freeze {
	Hex = function(scope: ConFusion.Scope, props: StyleProperties)
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
					Text = inner:Computed(function(use: ConFusion.Use)
						return `#{use(props.color):ToHex()}`
					end),
					PlaceholderText = "Hex",
					Size = UDim2.fromScale(1, 1),

					Callback = function()
						props.setColor(getInputValue())
					end,

					[Ref] = hexFieldRef,
				},
				Display = inner:ColorDisplay {
					color = props.color,
					setColor = props.setColor,
				},
			},
		}
	end,
	HSV = function(scope: ConFusion.Scope, props: StyleProperties)
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

					Text = scope:Computed(function(use: ConFusion.Use)
						local components = { use(props.color):ToHSV() }
						local value = components[index]

						if index == 1 then
							return math.floor(value * 360) % 360
						end

						return math.floor(value * 100)
					end),
					PlaceholderText = label,

					Callback = function()
						props.setColor(getInputValue())
					end,
				}
			end,
			Labels = { "H", "S", "V" },
			Refs = { hueFieldRef, saturationFieldRef, valueFieldRef },

			[Children] = {
				Display = inner:ColorDisplay {
					color = props.color,
					setColor = props.setColor,
				},
			},
		}
	end,
	RGB = function(scope: ConFusion.Scope, props: StyleProperties)
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

			Render = function(scope: typeof(inner), _: number, label: string)
				return scope:TextEntry {
					Size = UDim2.fromScale(1, 1),

					Text = inner:Computed(function(use: ConFusion.Use)
						local component = use(props.color)[label] :: number
						return math.floor(component * 255)
					end),
					PlaceholderText = label,

					Callback = function()
						props.setColor(getInputValue())
					end,
				}
			end,
			Labels = { "R", "G", "B" },
			Refs = { redFieldRef, greenFieldRef, blueFieldRef },

			[Children] = {
				Display = inner:ColorDisplay {
					color = props.color,
					setColor = props.setColor,
				},
			},
		}
	end,
} :: { [string]: (scope: ConFusion.Scope, props: StyleProperties) -> () }
