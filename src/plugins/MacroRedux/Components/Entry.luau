local pluginContainer = script.Parent.Parent

local Fusion = require(pluginContainer.Packages.Fusion)
local OnEvent, Out = Fusion.OnEvent, Fusion.Out
local Children = Fusion.Children
local peek = Fusion.peek

local Corners = require(pluginContainer.Components.Corners)
local Theme = require(pluginContainer.Components.Theme)

local function Entry(
	scope: Fusion.Scope,
	props: {
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		Position: Fusion.UsedAs<UDim2>?,
		Size: Fusion.UsedAs<UDim2>?,
		SizeConstraint: Fusion.UsedAs<Enum.SizeConstraint>?,

		PlaceholderText: string?,
		Text: string?,
		TextSize: number?,

		Callback: (string) -> (),
	}
)
	local inner = scope:innerScope { Corners = Corners }
	local text = inner:Value(peek(props.Text) or "")

	local isFocused = inner:Value(false)
	local borderColor = inner:Computed(function(use)
		if use(isFocused) then
			return use(Theme.Colors.AccentBorder)
		end

		return use(Theme.Colors.InputFieldBorder)
	end)

	return inner:New "TextBox" {
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		Position = props.Position,

		BackgroundColor3 = Theme.Colors.InputFieldBackground,

		PlaceholderText = props.PlaceholderText,
		PlaceholderColor3 = Theme.Colors.DimmedText,

		Text = props.Text,
		TextSize = props.TextSize or 18,
		TextColor3 = Theme.Colors.Text,
		TextTruncate = Enum.TextTruncate.AtEnd,
		FontFace = Theme.Font,

		[Out "Text"] = text,
		[OnEvent "Focused"] = function()
			isFocused:set(true)
		end,
		[OnEvent "FocusLost"] = function()
			isFocused:set(false)

			props.Callback(peek(text))
		end,

		[Children] = inner:Corners {
			Color = inner:Tween(borderColor, Theme.TweenInfo.ActiveHighlight),
		},
	}
end

return Entry
