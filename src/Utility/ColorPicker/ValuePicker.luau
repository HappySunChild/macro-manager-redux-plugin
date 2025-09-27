local Assets = require "@plugin/Assets"
local types = require "@plugin/types"

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

		target: ConFusion.Value<types.SharedPickerColor>,
	}
)
	local inner = scope:innerScope()
	local absolutePosition = scope:Value(Vector2.zero)
	local absoluteSize = scope:Value(Vector2.zero)

	local target = props.target

	local mouseDown = false

	return inner:New "Frame" {
		Position = props.position,
		Size = props.size,

		BorderSizePixel = 1,
		BorderColor3 = Theme.Color.Border,

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

			local mut = peek(target) :: types.SharedPickerColor

			local mousePosition = input.Position :: Vector3
			local framePosition = peek(absolutePosition) :: Vector2
			local frameSize = peek(absoluteSize) :: Vector2

			mut.val = 1 - (mousePosition.Y - framePosition.Y) / frameSize.Y

			target:set(mut)
		end,

		[Children] = {
			gradient = inner:New "UIGradient" {
				Rotation = 90,
				Color = ColorSequence.new(
					Color3.new(1, 1, 1),
					Color3.new(0, 0, 0)
				),
			},
			arrow = inner:New "ImageLabel" {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = inner:Computed(function(use: ConFusion.Use)
					local mut = use(target) :: types.SharedPickerColor

					return UDim2.new(1, 5, 1 - mut.val, 0)
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
