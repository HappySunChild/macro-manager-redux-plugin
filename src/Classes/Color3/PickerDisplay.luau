local Assets = require "@plugin/Assets"

local ConFusion = require "@packages/ConFusion"

local ColorPicker = require "@utility/ColorPicker"
local Theme = require "@utility/Theme"
local getLuminance = require "@utility/getLuminance"

local RoundBorder = require "@components/RoundBorder"

local peek = ConFusion.peek
local Children, OnEvent = ConFusion.Children, ConFusion.OnEvent

local BRIGHTNESS_THRESHOLD = 0.5

local function PickerDisplay(
	scope: ConFusion.Scope,
	props: {
		color: ConFusion.UsedAs<Color3>,
		setColor: (Color3) -> (),
	}
)
	local inner = scope:innerScope { RoundBorder = RoundBorder }
	local iconColor = inner:Computed(function(use: ConFusion.Use)
		if getLuminance(use(props.color)) >= BRIGHTNESS_THRESHOLD then
			return use(Theme.Color.ColorPickerIcon.AboveThreshold)
		end

		return use(Theme.Color.ColorPickerIcon.BelowThreshold)
	end)

	return inner:New "Frame" {
		Size = UDim2.fromOffset(20, 20),

		BackgroundColor3 = props.color,

		[OnEvent "InputBegan"] = function(input: InputObject)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			local new_color = ColorPicker.prompt(peek(props.color))

			if not new_color then
				return
			end

			props.setColor(new_color)
		end,
		[Children] = {
			flex = inner:New "UIFlexItem" {},
			icon = inner:New "ImageLabel" {
				Size = UDim2.fromScale(1, 1),

				BackgroundTransparency = 1,

				Image = Assets.Images.ColorizeIcon,
				ImageColor3 = iconColor,
			},
			border = inner:RoundBorder {
				color = Theme.Color.Border,
			},
		},
	}
end

return PickerDisplay
