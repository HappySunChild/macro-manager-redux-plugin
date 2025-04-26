local Studio = settings():GetService "Studio"

local PluginFolder = script.Parent.Parent
local Fusion = require(PluginFolder.Packages.Fusion)
local PluginScope = require(PluginFolder.Packages.PluginScope)
local map, peek = Fusion.map, Fusion.peek

local currentTheme = PluginScope:Value(Studio.Theme)

local function DynamicColor(
	styleGuideColor: Enum.StudioStyleGuideColor,
	modifier: Enum.StudioStyleGuideModifier?
)
	return map(currentTheme, function(theme: StudioTheme)
		if not theme then
			return Color3.new(1, 0, 1)
		end

		return theme:GetColor(styleGuideColor, modifier)
	end)
end

local Theme = {
	current = currentTheme,

	colors = {
		Background = DynamicColor(Enum.StudioStyleGuideColor.MainBackground),
		Text = DynamicColor(Enum.StudioStyleGuideColor.MainText),
	},
}

function Theme:SetTheme(newTheme: StudioTheme)
	currentTheme:set(newTheme)
end

function Theme:GetTheme(): StudioTheme
	return peek(currentTheme)
end

return Theme
