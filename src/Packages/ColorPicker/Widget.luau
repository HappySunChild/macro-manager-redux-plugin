local pluginContainer = script.Parent.Parent.Parent

local Fusion = require(pluginContainer.Packages.Fusion)

local Button = require(script.Parent.Button)
local ElementGroup = require(pluginContainer.Components.ElementGroup)
local Entry = require(script.Parent.Entry)
local HueSaturationPicker = require(script.Parent.HueSaturationPicker)
local ValuePicker = require(script.Parent.ValuePicker)

local Children = Fusion.Children

local peek = Fusion.peek

local function getHSVComponent(color: Color3, index: number)
	local hue, sat, val = color:ToHSV()

	return math.floor(select(index, hue * 360, sat * 255, val * 255))
end

local function getRGBComponent(color: Color3, index: number)
	return math.floor(select(index, color.R, color.G, color.B) * 255)
end

local function RGBEntries(
	scope: Fusion.Scope,
	props: {
		Position: UDim2,
		OutputColor: Fusion.Value<Color3>,
	}
)
	local inner = scope:innerScope {
		Entry = Entry,
		ElementGroup = ElementGroup,
	}

	local redFieldRef = inner:Value()
	local greenFieldRef = inner:Value()
	local blueFieldRef = inner:Value()

	local function getInputValue()
		local redField = peek(redFieldRef) :: TextBox
		local greenField = peek(greenFieldRef) :: TextBox
		local blueField = peek(blueFieldRef) :: TextBox

		local red = math.clamp((tonumber(redField.Text) or 0), 0, 255)
		local green = math.clamp((tonumber(greenField.Text) or 0), 0, 255)
		local blue = math.clamp((tonumber(blueField.Text) or 0), 0, 255)

		return Color3.fromRGB(red, green, blue)
	end

	local refs = { redFieldRef, greenFieldRef, blueFieldRef }

	return inner:ElementGroup {
		Position = props.Position,
		Size = UDim2.fromOffset(40, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 8),

		Render = function(scope: typeof(inner), index: number, label: string)
			return scope:Entry {
				Size = UDim2.new(1, 0, 0, 20),

				TextboxRef = refs[index],

				Label = label,
				Range = NumberRange.new(0, 255),
				Value = scope:Computed(function(use: Fusion.Use)
					return getRGBComponent(use(props.OutputColor), index)
				end),
				Callback = function()
					props.OutputColor:set(getInputValue())
				end,
			}
		end,
		Labels = { "Red", "Green", "Blue" },
	}
end

local function HSVEntries(
	scope: Fusion.Scope,
	props: {
		Position: UDim2,
		OutputColor: Fusion.Value<Color3>,
	}
)
	local inner = scope:innerScope {
		Entry = Entry,
		ElementGroup = ElementGroup,
	}

	local hueFieldRef = inner:Value()
	local satFieldRef = inner:Value()
	local valFieldRef = inner:Value()

	local function getInputValue()
		local hueField = peek(hueFieldRef) :: TextBox
		local satField = peek(satFieldRef) :: TextBox
		local valField = peek(valFieldRef) :: TextBox

		local hue = math.clamp((tonumber(hueField.Text) or 0), 0, 360)
		local sat = math.clamp((tonumber(satField.Text) or 0), 0, 255)
		local val = math.clamp((tonumber(valField.Text) or 0), 0, 255)

		return Color3.fromHSV(hue / 360, sat / 255, val / 255)
	end

	local refs = { hueFieldRef, satFieldRef, valFieldRef }

	return inner:ElementGroup {
		Position = props.Position,
		Size = UDim2.fromOffset(40, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 8),

		Render = function(scope: typeof(inner), index: number, label: string)
			return scope:Entry {
				Size = UDim2.new(1, 0, 0, 20),

				TextboxRef = refs[index],

				Label = label,
				Range = NumberRange.new(0, index == 1 and 360 or 255),
				Value = scope:Computed(function(use: Fusion.Use)
					return getHSVComponent(use(props.OutputColor), index)
				end),
				Callback = function()
					props.OutputColor:set(getInputValue())
				end,
			}
		end,
		Labels = { "Hue", "Sat", "Val" },
	}
end

local function HexEntry(
	scope: Fusion.Scope,
	props: {
		Position: UDim2,
		OutputColor: Fusion.Value<Color3>,
	}
)
	local inner = scope:innerScope { Entry = Entry }

	local hexFieldRef = inner:Value()

	local function getInputValue()
		local hexField = peek(hexFieldRef) :: TextBox
		local hex = hexField.Text

		return Color3.fromHex(hex)
	end

	return inner:Entry {
		Position = props.Position,
		Size = UDim2.fromOffset(120, 20),

		TextboxRef = hexFieldRef,

		Label = "Hex",
		Value = inner:Computed(function(use: Fusion.Use)
			return "#" .. use(props.OutputColor):ToHex()
		end),
		Callback = function()
			props.OutputColor:set(getInputValue())
		end,
	}
end

local function ColorPickerWidget(
	scope: Fusion.Scope,
	props: {
		Plugin: Plugin,
		Enabled: Fusion.UsedAs<boolean>,
		OutputColor: Fusion.Value<Color3>,

		ConfirmCallback: () -> (),
		CancelCallback: () -> (),
	}
)
	local plugin = props.Plugin

	assert(plugin, "Missing Plugin!")

	local output = props.OutputColor

	local inner = scope:innerScope {
		ElementGroup = ElementGroup,
		Button = Button,
		HueSaturationPicker = HueSaturationPicker,
		ValuePicker = ValuePicker,

		RGBEntries = RGBEntries,
		HSVEntries = HSVEntries,
		HexEntry = HexEntry,
	}

	local widget = plugin:CreateDockWidgetPluginGui(
		"MacroColorPicker",
		DockWidgetPluginGuiInfo.new(
			Enum.InitialDockState.Float,
			false,
			true,
			300,
			410,
			300,
			410
		)
	)
	widget.Title = "Select Color"
	widget.Name = "MacroColorPicker"

	return inner:Hydrate(widget) {
		Enabled = props.Enabled,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingTop = UDim.new(0, 11),
				PaddingBottom = UDim.new(0, 11),
				PaddingLeft = UDim.new(0, 11),
				PaddingRight = UDim.new(0, 11),
			},

			Pickers = inner:New "Frame" {
				Size = UDim2.new(1, 0, 0, 200),
				BackgroundTransparency = 1,

				[Children] = {
					HueSaturation = inner:HueSaturationPicker {
						OutputColor = output,

						Position = UDim2.fromOffset(0, 0),
						Size = UDim2.fromOffset(220, 200),
					},
					Value = inner:ValuePicker {
						OutputColor = output,

						Position = UDim2.fromOffset(236, 0),
						Size = UDim2.fromOffset(13, 200),
					},
				},
			},
			Panel = inner:New "Frame" {
				Position = UDim2.fromOffset(0, 220),
				Size = UDim2.new(1, 0, 0, 110),

				BackgroundTransparency = 1,
				BackgroundColor3 = Color3.new(1, 0, 1),

				[Children] = {
					Display = inner:New "Frame" {
						Position = UDim2.fromOffset(1, 0),
						Size = UDim2.new(0, 60, 1, 0),

						BackgroundColor3 = output,
						BorderColor3 = Color3.new(0, 0, 0),
						BorderSizePixel = 1,
					},

					RGB = inner:RGBEntries {
						Position = UDim2.fromOffset(220, 0),
						OutputColor = output,
					},
					HSV = inner:HSVEntries {
						Position = UDim2.fromOffset(120, 0),
						OutputColor = output,
					},
					Hex = inner:HexEntry {
						Position = UDim2.fromOffset(120, 88),
						OutputColor = output,
					},
				},
			},
			Buttons = inner:ElementGroup {
				Position = UDim2.fromOffset(0, 340),
				Size = UDim2.new(1, 0, 0, 24),

				FlexAlignment = Enum.UIFlexAlignment.None,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = UDim.new(0, 8),

				Render = function(scope: typeof(inner), _, label: string)
					return scope:Button {
						Size = UDim2.fromOffset(74, 24),
						Text = label,

						Callback = if label == "OK"
							then props.ConfirmCallback
							else props.CancelCallback,
					}
				end,
				Labels = { "OK", "Cancel" },
			},
		},
	}
end

return ColorPickerWidget
