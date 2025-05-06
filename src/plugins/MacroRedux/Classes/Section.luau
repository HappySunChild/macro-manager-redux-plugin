local pluginContainer = script.Parent.Parent

local Theme = require(pluginContainer.Utility.Theme)
local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local ItemsContainer = require(pluginContainer.Components.ItemsContainer)
local RoundBorder = require(pluginContainer.Components.RoundBorder)

local Children = Fusion.Children

local default = t.default(1, t.number)

type SectionMacroItem = Types.MacroItem & {
	Name: string?,
	Text: string?,
	Items: { Types.MacroItem },
}

local function TitleLabel(
	scope: Fusion.Scope,
	props: {
		Text: Fusion.UsedAs<string>,
		BackgroundColor: Fusion.UsedAs<Color3>,
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

		BackgroundColor3 = props.BackgroundColor,

		[Children] = {
			Border = inner:RoundBorder {
				Color = Theme.Colors.MacroBackground,
				Thickness = 2,
			},
			Padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6),
			},

			Unborder = inner:New "Frame" {
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.new(0, -6, 0.5, 0),
				Size = UDim2.new(1, 18, 0.5, 2),

				BackgroundColor3 = props.BackgroundColor,
			},
			Text = inner:New "TextLabel" {
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,

				BackgroundTransparency = 1,
				ZIndex = 10,

				Text = props.Text,
				TextSize = 16,
				TextColor3 = Theme.Colors.BrightText,
				FontFace = Font.new(Theme.Font.Family, Enum.FontWeight.Bold),
			},
		},
	}
end

local function SectionMacroItem(
	scope: Fusion.Scope,
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
	local hasTitle = inner:Computed(function(use: Fusion.Use)
		if use(displayText) == "" then
			return false
		end

		return true
	end)

	function macroItem:UpdateText(newText: string)
		assert(t.string(newText))

		displayText:set(newText)
	end

	macroItem.InSection = nil -- this may seem a little unintuitive, but it's just so they don't get indented
	macroItem.SectionDepth = currentDepth

	local background = if currentDepth % 2 == 0
		then Theme.Colors.SectionBackgroundAlt
		else Theme.Colors.SectionBackground

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundTransparency = 1,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingTop = inner:Computed(function(use: Fusion.Use)
					if use(hasTitle) then
						return UDim.new(0, 10)
					end

					return UDim.new(0, 0)
				end),
				PaddingBottom = UDim.new(0, 6),
			},

			Container = inner:New "Frame" {
				-- AnchorPoint = Vector2.new(0.5, 0),
				-- Position = UDim2.fromScale(0.5, 0),
				Position = UDim2.fromOffset(0, 4),
				Size = UDim2.new(1, 0, 0, 16),
				AutomaticSize = Enum.AutomaticSize.Y,

				BackgroundColor3 = background,

				[Children] = {
					Border = inner:RoundBorder {
						Color = Theme.Colors.MacroBackground,
						Thickness = 2,
					},
					TitleLabel = inner:Computed(
						function(use: Fusion.Use, scope: typeof(inner))
							if use(hasTitle) then
								return scope:TitleLabel {
									Text = displayText,
									BackgroundColor = background,
								}
							end

							return nil
						end
					),

					Items = inner:ItemsContainer {
						Items = macroItem.Items,
						ItemProperties = {
							InSection = true,
							SectionDepth = currentDepth + 1,
						},

						Position = inner:Computed(function(use: Fusion.Use)
							if use(hasTitle) then
								return UDim2.fromOffset(0, 6)
							end

							return UDim2.fromOffset(0, 0)
						end),
						BackgroundTransparency = 1,
					},
				},
			},
		},
	}
end

return SectionMacroItem
