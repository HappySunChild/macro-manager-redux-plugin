local Studio = settings():GetService "Studio"

local pluginContainer = script.Parent.Parent
local PluginScope = require(pluginContainer.Plugin.Scope)

local Fusion = require(pluginContainer.Packages.Fusion)
local map = Fusion.map

local currentTheme = PluginScope:Value(Studio.Theme)

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
		Background = StudioColor(Enum.StudioStyleGuideColor.MainBackground),

		MacroBackground = StudioColor(Enum.StudioStyleGuideColor.Border),
		MacroTitleBackground = ColorSet {
			Light = Color3.fromRGB(138, 138, 138),
			Dark = Color3.fromRGB(17, 17, 17),
		},

		ItemContainerBackground = StudioColor(Enum.StudioStyleGuideColor.Light),
		ItemBackground = StudioColor(Enum.StudioStyleGuideColor.Notification),

		ButtonBackground = StudioColor(Enum.StudioStyleGuideColor.Button),
		ButtonHover = StudioColor(
			Enum.StudioStyleGuideColor.Button,
			Enum.StudioStyleGuideModifier.Hover
		),
		ButtonPress = StudioColor(
			Enum.StudioStyleGuideColor.Button,
			Enum.StudioStyleGuideModifier.Pressed
		),
		ButtonBorder = StudioColor(Enum.StudioStyleGuideColor.ButtonBorder),

		InputFieldBackground = StudioColor(
			Enum.StudioStyleGuideColor.InputFieldBackground
		),
		InputFieldBorder = StudioColor(
			Enum.StudioStyleGuideColor.InputFieldBorder
		),

		Text = StudioColor(Enum.StudioStyleGuideColor.MainText),
		BrightText = StudioColor(Enum.StudioStyleGuideColor.BrightText),
		SubText = StudioColor(Enum.StudioStyleGuideColor.SubText),
		TitleText = StudioColor(Enum.StudioStyleGuideColor.InfoText),
		DimmedText = StudioColor(Enum.StudioStyleGuideColor.DimmedText),
		ButtonText = StudioColor(Enum.StudioStyleGuideColor.ButtonText),

		ActiveBorder = StudioColor(
			Enum.StudioStyleGuideColor.OnboardingHighlight
		),
	},
	TweenInfo = {
		ActiveHighlight = TweenInfo.new(0.1),
	},
}

function Theme:SetTheme(newTheme: StudioTheme)
	currentTheme:set(newTheme)
end

return Theme
