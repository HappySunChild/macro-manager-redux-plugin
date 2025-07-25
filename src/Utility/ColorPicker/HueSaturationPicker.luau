local Assets = require "@plugin/Assets"
local ConFusion = require "@packages/ConFusion"
local Theme = require "@utility/Theme"

local OnEvent, Out = ConFusion.OnEvent, ConFusion.Out
local Children = ConFusion.Children

local peek = ConFusion.peek

local function HueSaturationPicker(
	scope: ConFusion.Scope,
	props: {
		position: UDim2?,
		size: UDim2?,

		output: ConFusion.Value<Color3>,
	}
)
	local inner = scope:innerScope()
	local absolutePosition = scope:Value(Vector2.zero)
	local absoluteSize = scope:Value(Vector2.zero)

	local output = props.output

	local mouseDown = false

	return inner:New "ImageLabel" {
		Position = props.position,
		Size = props.size,

		ClipsDescendants = true,

		BorderSizePixel = 1,
		BorderColor3 = Theme.Color.InputField.Border,

		Image = Assets.Images.ColorPicker.HueSat,

		[Out "AbsoluteSize"] = absoluteSize,
		[Out "AbsolutePosition"] = absolutePosition,
		[OnEvent "InputBegan"] = function(input: InputObject)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			mouseDown = true
		end,
		[OnEvent "InputEnded"] = function(input: InputObject)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			mouseDown = false
		end,
		[OnEvent "InputChanged"] = function(input: InputObject)
			if not mouseDown then
				return
			end

			if input.UserInputType ~= Enum.UserInputType.MouseMovement then
				return
			end

			local mousePosition = input.Position :: Vector3
			local framePosition = peek(absolutePosition) :: Vector2
			local frameSize = peek(absoluteSize) :: Vector2

			local hue = 1 - (mousePosition.X - framePosition.X) / frameSize.X
			local sat = 1 - (mousePosition.Y - framePosition.Y) / frameSize.Y
			local _, _, val = peek(output):ToHSV()

			output:set(Color3.fromHSV(hue, sat, val))
		end,
		[Children] = {
			crosshair = inner:New "ImageLabel" {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = inner:Computed(function(use: ConFusion.Use)
					local hue, sat, _ = use(output):ToHSV()

					return UDim2.fromScale(1 - hue, 1 - sat)
				end),
				Size = UDim2.fromOffset(20, 20),

				BackgroundTransparency = 1,

				Image = Assets.Images.ColorPicker.Crosshair,
				ResampleMode = Enum.ResamplerMode.Pixelated,
			},
		},
	}
end

return HueSaturationPicker
