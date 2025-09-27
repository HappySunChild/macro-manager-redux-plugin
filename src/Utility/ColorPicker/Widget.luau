local types = require "@plugin/types"

local ConFusion = require "@packages/ConFusion"

local Theme = require "@utility/Theme"

local Button = require "./Button"
local ElementGroup = require "@components/ElementGroup"
local Entry = require "./Entry"
local HueSaturationPicker = require "./HueSaturationPicker"
local ValuePicker = require "./ValuePicker"

local Children = ConFusion.Children

local peek = ConFusion.peek

local function getHSVComponent(color: Color3, index: number): number
	local hue, sat, val = color:ToHSV()

	return math.floor(select(index, hue * 360, sat * 255, val * 255))
end

local function getRGBComponent(color: Color3, index: number): number
	return math.floor(select(index, color.R, color.G, color.B) * 255)
end

local function RGBEntries(
	scope: ConFusion.Scope,
	props: {
		position: UDim2,
		output: ConFusion.Value<Color3>,
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
		position = props.position,
		size = UDim2.fromOffset(40, 0),
		automaticSize = Enum.AutomaticSize.Y,

		fillDirection = Enum.FillDirection.Vertical,
		padding = UDim.new(0, 8),

		labels = { "Red", "Green", "Blue" },
		render = function(scope: typeof(inner), index: number, label: string)
			return scope:Entry {
				size = UDim2.new(1, 0, 0, 20),

				textboxRef = refs[index],

				label = label,
				range = NumberRange.new(0, 255),
				value = scope:Computed(function(use: ConFusion.Use, _)
					return getRGBComponent(use(props.output), index)
				end),
				callback = function()
					props.output:set(getInputValue())
				end,
			}
		end,
	}
end

local function HSVEntries(
	scope: ConFusion.Scope,
	props: {
		position: UDim2,
		output: ConFusion.Value<Color3>,
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
		position = props.position,
		size = UDim2.fromOffset(40, 0),
		automaticSize = Enum.AutomaticSize.Y,

		fillDirection = Enum.FillDirection.Vertical,
		padding = UDim.new(0, 8),

		labels = { "Hue", "Sat", "Val" },
		render = function(scope: typeof(inner), index: number, label: string)
			return scope:Entry {
				size = UDim2.new(1, 0, 0, 20),

				textboxRef = refs[index],

				label = label,
				range = NumberRange.new(0, index == 1 and 360 or 255),
				value = scope:Computed(function(use: ConFusion.Use)
					return getHSVComponent(use(props.output), index)
				end),
				callback = function()
					props.output:set(getInputValue())
				end,
			}
		end,
	}
end

local function HexEntry(
	scope: ConFusion.Scope,
	props: {
		position: UDim2,
		output: ConFusion.Value<Color3>,
	}
)
	local inner = scope:innerScope { Entry = Entry }

	local hexFieldRef = inner:Value()

	local function getInputValue()
		local hexField = peek(hexFieldRef) :: TextBox
		local hex = hexField.Text

		-- i don't understand why Roblox made this error when it receives an invalid hex input
		-- return Color3.fromHex(hex)
		local success, color = pcall(Color3.fromHex, hex)

		if not success then
			return Color3.new()
		end

		return color
	end

	return inner:Entry {
		position = props.position,
		size = UDim2.fromOffset(120, 20),

		textboxRef = hexFieldRef,

		label = "Hex",
		value = inner:Computed(function(use: ConFusion.Use, _)
			return "#" .. use(props.output):ToHex()
		end),
		callback = function()
			props.output:set(getInputValue())
		end,
	}
end

local function ColorPickerWidget(
	scope: ConFusion.Scope,
	props: {
		plugin: Plugin,
		output: ConFusion.Value<Color3>,

		status: ConFusion.UsedAs<string>,
		enabled: ConFusion.UsedAs<boolean>,

		confirm: () -> (),
		cancel: () -> (),
	}
)
	local plugin = props.plugin

	assert(plugin, "Missing Plugin!")

	local output = props.output
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

	widget:BindToClose(props.cancel)

	local _hue, _sat, _val = peek(props.output):ToHSV()
	local sharedPickerColor = inner:Value { hue = _hue, sat = _sat, val = _val }

	inner:observe(sharedPickerColor, function()
		local mut = peek(sharedPickerColor)

		output:set(Color3.fromHSV(mut.hue, mut.sat, mut.val))
	end)
	inner:observe(output, function()
		local color = peek(output) :: Color3

		local mut = peek(sharedPickerColor) :: types.SharedPickerColor
		mut.hue, mut.sat, mut.val = color:ToHSV()

		sharedPickerColor:set(mut)
	end)

	return inner:Hydrate(widget) {
		Enabled = props.enabled,
		Title = inner:Computed(function(use: ConFusion.Use)
			local status = use(props.status)

			if not status then
				return "Select Color"
			end

			return `Select Color - {status}`
		end),

		[Children] = {
			padding = inner:New "UIPadding" {
				PaddingTop = UDim.new(0, 11),
				PaddingBottom = UDim.new(0, 11),
				PaddingLeft = UDim.new(0, 11),
				PaddingRight = UDim.new(0, 11),
			},

			pickers = inner:New "Frame" {
				Size = UDim2.new(1, 0, 0, 200),
				BackgroundTransparency = 1,

				[Children] = {
					huesaturation = inner:HueSaturationPicker {
						position = UDim2.fromOffset(1, 1),
						size = UDim2.fromOffset(220, 200),

						target = sharedPickerColor,
					},
					value = inner:ValuePicker {
						position = UDim2.fromOffset(237, 1),
						size = UDim2.fromOffset(13, 200),

						target = sharedPickerColor,
					},
				},
			},
			panel = inner:New "Frame" {
				Position = UDim2.fromOffset(0, 220),
				Size = UDim2.new(1, 0, 0, 110),

				BackgroundTransparency = 1,
				BackgroundColor3 = Color3.new(1, 0, 1),

				[Children] = {
					display = inner:New "Frame" {
						Position = UDim2.fromOffset(1, 0),
						Size = UDim2.new(0, 60, 1, 0),

						BackgroundColor3 = output,
						BorderColor3 = Theme.Color.Border,
						BorderSizePixel = 1,
					},

					rgb = inner:RGBEntries {
						position = UDim2.fromOffset(220, 0),
						output = output,
					},
					hsv = inner:HSVEntries {
						position = UDim2.fromOffset(120, 0),
						output = output,
					},
					hex = inner:HexEntry {
						position = UDim2.fromOffset(120, 88),
						output = output,
					},
				},
			},
			buttons = inner:ElementGroup {
				position = UDim2.fromOffset(0, 340),
				size = UDim2.new(1, 0, 0, 24),

				flexAlignment = Enum.UIFlexAlignment.None,
				horizontalAlignment = Enum.HorizontalAlignment.Right,
				padding = UDim.new(0, 8),

				labels = { "OK", "Cancel" },
				render = function(scope: typeof(inner), _, label: string)
					return scope:Button {
						size = UDim2.fromOffset(74, 24),
						text = label,

						callback = if label == "OK"
							then props.confirm
							else props.cancel,
					}
				end,
			},
		},
	}
end

return ColorPickerWidget
