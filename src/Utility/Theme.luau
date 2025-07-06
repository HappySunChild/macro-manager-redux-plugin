--!nocheck
local Studio = settings():GetService "Studio"

local ConFusion = require "@packages/ConFusion"
local PluginShared = require "@plugin/Shared"

local map = ConFusion.map
local scope = PluginShared.Scope

local currentTheme = scope:Value(Studio.Theme)

local MISSING_COLOR = Color3.new(1, 0, 1)

local function StudioColor(
	styleGuideColor: Enum.StudioStyleGuideColor,
	modifier: Enum.StudioStyleGuideModifier?
): ConFusion.Computed<Color3>
	return map(currentTheme, function(theme: StudioTheme)
		if not theme then
			return MISSING_COLOR
		end

		return theme:GetColor(styleGuideColor, modifier)
	end)
end

local function ColorSet(set: { [string]: Color3 }): ConFusion.Computed<Color3>
	return map(currentTheme, function(theme: StudioTheme)
		if not theme then
			return MISSING_COLOR
		end

		return set[theme.Name]
	end)
end

return table.freeze {
	setTheme = function(newTheme: StudioTheme)
		currentTheme:set(newTheme)
	end,

	Font = {
		Regular = Font.fromName "SourceSansPro",
		Bold = Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
	},
	Color = {
		Text = StudioColor(Enum.StudioStyleGuideColor.MainText),
		BrightText = StudioColor(Enum.StudioStyleGuideColor.BrightText),
		SubText = StudioColor(Enum.StudioStyleGuideColor.SubText),
		DimmedText = StudioColor(Enum.StudioStyleGuideColor.DimmedText),

		Border = StudioColor(Enum.StudioStyleGuideColor.Border),
		AccentBorder = ColorSet {
			Light = Color3.fromRGB(146, 163, 255),
			Dark = Color3.fromRGB(247, 152, 58),
		},

		MainBackground = StudioColor(Enum.StudioStyleGuideColor.MainBackground),

		Macro = {
			Title = {
				Text = StudioColor(Enum.StudioStyleGuideColor.InfoText),
				Background = ColorSet {
					Light = Color3.fromRGB(195, 195, 195),
					Dark = Color3.fromRGB(17, 17, 17),
				},
			},
			Background = StudioColor(Enum.StudioStyleGuideColor.Mid),
		},
		Item = {
			Background = ColorSet {
				Light = Color3.fromRGB(255, 255, 255),
				Dark = Color3.fromRGB(46, 46, 46),
			},
		},
		Section = {
			Background = ColorSet {
				Light = Color3.fromRGB(239, 239, 239),
				Dark = Color3.fromRGB(55, 55, 55),
			},
			BackgroundAlt = ColorSet {
				Light = Color3.fromRGB(255, 255, 255),
				Dark = Color3.fromRGB(50, 50, 50),
			},
			Border = ColorSet {
				Light = Color3.fromRGB(216, 216, 216),
				Dark = Color3.fromRGB(34, 34, 34),
			},
		},

		Button = {
			Text = StudioColor(Enum.StudioStyleGuideColor.ButtonText),
			Background = ColorSet {
				Light = Color3.fromRGB(252, 252, 252),
				Dark = Color3.fromRGB(56, 56, 56),
			},
			HoverBackground = StudioColor(
				Enum.StudioStyleGuideColor.Button,
				Enum.StudioStyleGuideModifier.Hover
			),
			PressedBackground = StudioColor(
				Enum.StudioStyleGuideColor.Button,
				Enum.StudioStyleGuideModifier.Pressed
			),
			Border = ColorSet {
				Light = Color3.fromRGB(162, 162, 162),
				Dark = Color3.fromRGB(26, 26, 26),
			},
		},

		InputField = {
			Background = StudioColor(
				Enum.StudioStyleGuideColor.InputFieldBackground
			),
			Border = StudioColor(Enum.StudioStyleGuideColor.InputFieldBorder),
		},

		Slider = {
			Background = ColorSet {
				Light = Color3.fromRGB(208, 208, 208),
				Dark = Color3.fromRGB(74, 74, 74),
			},
			Handle = ColorSet {
				Light = Color3.fromRGB(232, 232, 232),
				Dark = Color3.fromRGB(200, 200, 200),
			},
			Border = ColorSet {
				Light = Color3.fromRGB(143, 143, 143),
				Dark = Color3.fromRGB(28, 28, 28),
			},
		},

		DropdownItem = {
			Background = ColorSet {
				Light = Color3.fromRGB(242, 242, 242),
				Dark = Color3.fromRGB(50, 50, 50),
			},
			BackgroundAlt = ColorSet {
				Light = Color3.fromRGB(227, 227, 227),
				Dark = Color3.fromRGB(45, 45, 45),
			},
		},
	},
	TweenInfo = {
		Highlight = TweenInfo.new(0.1),
		Hover = TweenInfo.new(0.05),

		Page = TweenInfo.new(
			0.2,
			Enum.EasingStyle.Cubic,
			Enum.EasingDirection.Out
		),

		DropdownRotation = TweenInfo.new(0.2),
	},

	Roundness = scope:Value(UDim.new(0, 4)),
}
