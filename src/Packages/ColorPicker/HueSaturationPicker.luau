local pluginContainer = script.Parent.Parent.Parent

local Assets = require(pluginContainer.Assets)

local Fusion = require(pluginContainer.Packages.Fusion)

local OnEvent, Out = Fusion.OnEvent, Fusion.Out
local Children = Fusion.Children

local peek = Fusion.peek

local function HueSaturationPicker(
	scope: Fusion.Scope,
	props: {
		AnchorPoint: Vector2?,
		Position: UDim2?,
		Size: UDim2?,

		OutputColor: Fusion.Value<Color3>,
		Callback: (Color3) -> (),
	}
)
	local inner = scope:innerScope()
	local absolutePosition = scope:Value(Vector2.zero)
	local absoluteSize = scope:Value(Vector2.zero)

	local output = props.OutputColor

	local mouseDown = false

	return inner:New "ImageLabel" {
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = props.Size,

		ClipsDescendants = true,

		Image = Assets.Images.ColorPickerHueSat,

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
			Crosshair = inner:New "ImageLabel" {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = inner:Computed(function(use: Fusion.Use)
					local hue, sat, _ = use(output):ToHSV()

					return UDim2.fromScale(1 - hue, 1 - sat)
				end),
				Size = UDim2.fromOffset(20, 20),

				BackgroundTransparency = 1,

				Image = Assets.Images.ColorPickerCrosshair,
				ResampleMode = Enum.ResamplerMode.Pixelated,
			},
		},
	}
end

return HueSaturationPicker
