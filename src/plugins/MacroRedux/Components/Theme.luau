local Studio = settings():GetService "Studio"

local PluginContainer = script.Parent.Parent
local PluginScope = require(PluginContainer.Plugin.Scope)

local Fusion = require(PluginContainer.Packages.Fusion)
local map, peek = Fusion.map, Fusion.peek

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

	Colors = {
		Background = StudioColor(Enum.StudioStyleGuideColor.MainBackground),
		MacroBackground = StudioColor(Enum.StudioStyleGuideColor.Border),
		MacroTitleBackground = ColorSet {
			Light = Color3.fromRGB(138, 138, 138),
			Dark = Color3.fromRGB(17, 17, 17),
		},
		ItemContainerBackground = StudioColor(Enum.StudioStyleGuideColor.Light),

		Text = StudioColor(Enum.StudioStyleGuideColor.MainText),
		TitleText = StudioColor(Enum.StudioStyleGuideColor.InfoText),
	},
}

function Theme:SetTheme(newTheme: StudioTheme)
	currentTheme:set(newTheme)
end

function Theme:GetTheme(): StudioTheme
	return peek(currentTheme)
end

return Theme
