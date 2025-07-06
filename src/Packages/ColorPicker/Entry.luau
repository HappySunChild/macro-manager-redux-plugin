local ConFusion = require "@packages/ConFusion"
local Theme = require "@utility/Theme"

local Children, Ref = ConFusion.Children, ConFusion.Ref
local OnEvent, Out = ConFusion.OnEvent, ConFusion.Out

local peek = ConFusion.peek

local function Entry(
	scope: ConFusion.Scope,
	props: {
		AnchorPoint: Vector2?,
		Position: UDim2?,
		Size: UDim2?,

		Label: string,

		Value: ConFusion.UsedAs<string>?,
		Range: NumberRange?,

		Callback: (string) -> (),

		TextboxRef: ConFusion.Value<unknown>?,
	}
)
	local inner = scope:innerScope()
	local focused = inner:Value(false)
	local borderColor = inner:Computed(function(use: ConFusion.Use)
		if use(focused) then
			return use(Theme.Color.AccentBorder)
		end

		return use(Theme.Color.InputField.Border)
	end)

	local text = inner:Value(peek(props.Value) or "")

	return inner:New "Frame" {
		Position = props.Position,
		Size = props.Size,

		BackgroundColor3 = Theme.Color.InputField.Background,
		BorderColor3 = borderColor,
		BorderSizePixel = 1,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
			},

			Label = inner:New "TextLabel" {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromOffset(-4, 0),
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,

				BackgroundTransparency = 1,

				Text = props.Label .. ": ",
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextSize = 14,
				TextColor3 = Theme.Color.SubText,
			},
			Entry = inner:New "TextBox" {
				Size = UDim2.fromScale(1, 1),

				BackgroundTransparency = 1,

				Text = props.Value,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextSize = 14,
				TextColor3 = Theme.Color.Text,

				[Ref] = props.TextboxRef,
				[Out "Text"] = text,
				[OnEvent "Focused"] = function()
					focused:set(true)
				end,
				[OnEvent "FocusLost"] = function()
					focused:set(false)

					props.Callback(peek(text))
				end,
				[Children] = {
					Padding = inner:New "UIPadding" {
						PaddingLeft = UDim.new(0, 2),
						PaddingRight = UDim.new(0, 2),
					},
				},
			},
		},
	}
end

return Entry
