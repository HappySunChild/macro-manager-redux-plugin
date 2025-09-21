local Assets = require "@plugin/Assets"
local ConFusion = require "@packages/ConFusion"
local Theme = require "@utility/Theme"

local OnEvent, Out = ConFusion.OnEvent, ConFusion.Out
local Children = ConFusion.Children

local peek = ConFusion.peek

local function ValuePicker(
	scope: ConFusion.Scope,
	props: {
		position: UDim2?,
		size: UDim2?,

		output: ConFusion.UsedAs<Color3>,
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

		BorderSizePixel = 1,
		BorderColor3 = Theme.Color.Border,

		Image = Assets.Images.ColorPicker.Val,

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

			local val = 1 - (mousePosition.Y - framePosition.Y) / frameSize.Y
			local hue, sat, _ = peek(output):ToHSV()

			output:set(Color3.fromHSV(hue, sat, val))
		end,

		[Children] = {
			arrow = inner:New "ImageLabel" {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = inner:Computed(function(use: ConFusion.Use)
					local _, _, val = use(output):ToHSV()

					return UDim2.new(1, 5, 1 - val, 0)
				end),
				Size = UDim2.fromOffset(16, 16),

				BackgroundTransparency = 1,

				Image = Assets.Images.ColorPicker.Arrow,
				ResampleMode = Enum.ResamplerMode.Pixelated,
			},
		},
	}
end

return ValuePicker
