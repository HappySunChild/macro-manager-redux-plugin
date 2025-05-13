local Studio = settings():GetService "Studio"

local pluginContainer = script.Parent.Parent

local PluginShared = require(pluginContainer.Plugin.Shared)

local Fusion = require(pluginContainer.Packages.Fusion)
local map = Fusion.map

local scope = PluginShared.Scope

local currentTheme = scope:Value(Studio.Theme)

local MISSING_COLOR = Color3.new(1, 0, 1)

local function StudioColor(
	styleGuideColor: Enum.StudioStyleGuideColor,
	modifier: Enum.StudioStyleGuideModifier?
): Fusion.Computed<Color3>
	return map(currentTheme, function(theme: StudioTheme)
		if not theme then
			return MISSING_COLOR
		end

		return theme:GetColor(styleGuideColor, modifier)
	end)
end

local function ColorSet(set: { [string]: Color3 })
	return map(currentTheme, function(theme: StudioTheme)
		if not theme then
			return MISSING_COLOR
		end

		return set[theme.Name]
	end)
end

local Theme = {
	Current = currentTheme,

	Font = Font.fromName "SourceSansPro",
	Colors = {
		Text = StudioColor(Enum.StudioStyleGuideColor.MainText),
		BrightText = StudioColor(Enum.StudioStyleGuideColor.BrightText),
		SubText = StudioColor(Enum.StudioStyleGuideColor.SubText),
		InfoText = StudioColor(Enum.StudioStyleGuideColor.InfoText),
		DimmedText = StudioColor(Enum.StudioStyleGuideColor.DimmedText),
		ButtonText = StudioColor(Enum.StudioStyleGuideColor.ButtonText),

		Border = StudioColor(Enum.StudioStyleGuideColor.Border),

		MainBackground = StudioColor(Enum.StudioStyleGuideColor.MainBackground),

		MacroBackground = StudioColor(Enum.StudioStyleGuideColor.Mid),
		MacroTitleBackground = ColorSet {
			Light = Color3.fromRGB(138, 138, 138),
			Dark = Color3.fromRGB(17, 17, 17),
		},

		ItemBackground = ColorSet {
			Light = Color3.fromRGB(255, 255, 255),
			Dark = Color3.fromRGB(46, 46, 46),
		},

		SectionBackground = ColorSet {
			Light = Color3.fromRGB(239, 239, 239),
			Dark = Color3.fromRGB(55, 55, 55),
		},
		SectionBackgroundAlt = ColorSet {
			Light = Color3.fromRGB(255, 255, 255),
			Dark = Color3.fromRGB(50, 50, 50),
		},

		ButtonBackground = ColorSet {
			Light = Color3.fromRGB(252, 252, 252),
			Dark = Color3.fromRGB(56, 56, 56),
		},
		ButtonHover = StudioColor(
			Enum.StudioStyleGuideColor.Button,
			Enum.StudioStyleGuideModifier.Hover
		),
		ButtonPressed = StudioColor(
			Enum.StudioStyleGuideColor.Button,
			Enum.StudioStyleGuideModifier.Pressed
		),
		ButtonBorder = ColorSet {
			Light = Color3.fromRGB(162, 162, 162),
			Dark = Color3.fromRGB(26, 26, 26),
		},

		InputFieldBackground = StudioColor(
			Enum.StudioStyleGuideColor.InputFieldBackground
		),
		InputFieldBorder = StudioColor(
			Enum.StudioStyleGuideColor.InputFieldBorder
		),

		SliderBarBackground = ColorSet {
			Light = Color3.fromRGB(208, 208, 208),
			Dark = Color3.fromRGB(74, 74, 74),
		},
		SliderHandleBackground = ColorSet {
			Light = Color3.fromRGB(232, 232, 232),
			Dark = Color3.fromRGB(200, 200, 200),
		},
		SliderBorder = ColorSet {
			Light = Color3.fromRGB(143, 143, 143),
			Dark = Color3.fromRGB(28, 28, 28),
		},

		DropdownItemBackground = ColorSet {
			Light = Color3.fromRGB(242, 242, 242),
			Dark = Color3.fromRGB(50, 50, 50),
		},
		DropdownItemBackgroundAlt = ColorSet {
			Light = Color3.fromRGB(227, 227, 227),
			Dark = Color3.fromRGB(45, 45, 45),
		},

		AccentBorder = ColorSet {
			Light = Color3.fromRGB(146, 163, 255),
			Dark = Color3.fromRGB(247, 152, 58),
		},
	},
	TweenInfo = {
		Highlight = TweenInfo.new(0.1),
		Hover = TweenInfo.new(0.05),

		DropdownRotation = TweenInfo.new(0.2),
	},

	Roundness = scope:Value(UDim.new(0, 4)),
}

function Theme:SetTheme(newTheme: StudioTheme)
	currentTheme:set(newTheme)
end

return Theme
