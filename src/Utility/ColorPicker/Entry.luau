local ConFusion = require "@packages/ConFusion"
local Theme = require "@utility/Theme"

local Children, Ref = ConFusion.Children, ConFusion.Ref
local OnEvent, Out = ConFusion.OnEvent, ConFusion.Out

local peek = ConFusion.peek

local function Entry(
	scope: ConFusion.Scope,
	props: {
		anchorPoint: Vector2?,
		position: UDim2?,
		size: UDim2?,

		label: string,

		value: ConFusion.UsedAs<string>?,
		range: NumberRange?, -- unused

		callback: (string) -> (),

		textboxRef: ConFusion.Value<TextBox>?,
	}
)
	local inner = scope:innerScope()
	local focused = inner:Value(false)
	local borderColor = inner:Computed(function(use: ConFusion.Use)
		if use(focused) then
			return use(Theme.Color.AccentBorder)
		end

		return use(Theme.Color.Border)
	end)

	local text = inner:Value(peek(props.value) or "")

	return inner:New "Frame" {
		Position = props.position,
		Size = props.size,

		BackgroundColor3 = Theme.Color.InputField.Background,
		BorderColor3 = borderColor,
		BorderSizePixel = 1,

		[Children] = {
			padding = inner:New "UIPadding" {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
			},

			label = inner:New "TextLabel" {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromOffset(-4, 0),
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,

				BackgroundTransparency = 1,

				Text = props.label .. ": ",
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextSize = 14,
				TextColor3 = Theme.Color.SubText,
			},
			entry = inner:New "TextBox" {
				Size = UDim2.fromScale(1, 1),

				BackgroundTransparency = 1,

				Text = props.value,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextSize = 14,
				TextColor3 = Theme.Color.Text,

				[Ref] = props.textboxRef,
				[Out "Text"] = text,
				[OnEvent "Focused"] = function()
					focused:set(true)
				end,
				[OnEvent "FocusLost"] = function()
					focused:set(false)

					props.callback(peek(text))
				end,
				[Children] = {
					padding = inner:New "UIPadding" {
						PaddingLeft = UDim.new(0, 2),
						PaddingRight = UDim.new(0, 2),
					},
				},
			},
		},
	}
end

return Entry
