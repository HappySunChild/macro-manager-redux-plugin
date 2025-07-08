local Types = require "@plugin/Types"

local Theme = require "@utility/Theme"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local ItemsContainer = require "@components/ItemsContainer"
local RoundBorder = require "@components/RoundBorder"

local Children = ConFusion.Children

local default = t.default(1, t.number)

type SectionMacroItem = Types.MacroItem & {
	Name: string?,
	Text: string?,
	Items: { Types.MacroItem },
}

local function TitleLabel(
	scope: ConFusion.Scope,
	props: {
		text: ConFusion.UsedAs<string>,
		backgroundColor: ConFusion.UsedAs<Color3>,
	}
)
	local inner = scope:innerScope {
		RounderBorder = RoundBorder,
	}

	return inner:New "Frame" {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,

		BackgroundColor3 = props.backgroundColor,

		[Children] = {
			border = inner:RoundBorder {
				color = Theme.Color.Section.Border,
				thickness = 2,
			},
			padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6),
			},

			unborder = inner:New "Frame" {
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.new(0, -6, 0.5, 0),
				Size = UDim2.new(1, 18, 0.5, 2),

				BackgroundColor3 = props.backgroundColor,
			},
			label = inner:New "TextLabel" {
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,

				BackgroundTransparency = 1,
				ZIndex = 10,

				Text = props.text,
				TextSize = 16,
				TextColor3 = Theme.Color.BrightText,
				FontFace = Theme.Font.Bold,
			},
		},
	}
end

local function SectionMacroItem(
	scope: ConFusion.Scope,
	macroItem: SectionMacroItem
)
	local currentDepth = default(macroItem.SectionDepth)

	local inner = scope:innerScope {
		ItemsContainer = ItemsContainer,
		RoundBorder = RoundBorder,
		TitleLabel = TitleLabel,
	}
	local displayText =
		inner:Value(macroItem.Name or macroItem.Text or "Section")
	local hasTitle = inner:Computed(function(use: ConFusion.Use)
		if use(displayText) == "" then
			return false
		end

		return true
	end)

	function macroItem:UpdateText(newText: string)
		assert(t.string(newText))

		macroItem.Text = newText

		displayText:set(newText)
	end

	macroItem.InSection = nil -- this may seem a little unintuitive, but it's just so they don't get indented
	macroItem.SectionDepth = currentDepth

	local background = if currentDepth % 2 == 0
		then Theme.Color.Section.BackgroundAlt
		else Theme.Color.Section.Background

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundTransparency = 1,

		[Children] = {
			padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingTop = inner:Computed(function(use: ConFusion.Use)
					if use(hasTitle) then
						return UDim.new(0, 10)
					end

					return UDim.new(0, 0)
				end),
				PaddingBottom = UDim.new(0, 6),
			},

			container = inner:New "Frame" {
				-- AnchorPoint = Vector2.new(0.5, 0),
				-- Position = UDim2.fromScale(0.5, 0),
				Position = UDim2.fromOffset(0, 4),
				Size = UDim2.new(1, 0, 0, 16),
				AutomaticSize = Enum.AutomaticSize.Y,

				BackgroundColor3 = background,

				[Children] = {
					border = inner:RoundBorder {
						color = Theme.Color.Section.Border,
						thickness = 2,
					},

					title = inner:Computed(
						function(use: ConFusion.Use, scope: typeof(inner))
							if use(hasTitle) then
								return scope:TitleLabel {
									text = displayText,
									backgroundColor = background,
								}
							end

							return nil
						end
					),
					items = inner:ItemsContainer {
						items = macroItem.Items,
						itemProperties = {
							InSection = true,
							SectionDepth = currentDepth + 1,
						},

						position = inner:Computed(function(use: ConFusion.Use)
							if use(hasTitle) then
								return UDim2.fromOffset(0, 8)
							end

							return UDim2.fromOffset(0, 0)
						end),
						backgroundTransparency = 1,
					},
				},
			},
		},
	}
end

return SectionMacroItem
