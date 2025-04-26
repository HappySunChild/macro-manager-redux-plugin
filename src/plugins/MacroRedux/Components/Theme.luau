local Studio = settings():GetService "Studio"

local PluginFolder = script.Parent.Parent

local Fusion = require(PluginFolder.Packages.Fusion)
local map, peek = Fusion.map, Fusion.peek

local scope = Fusion:scoped()

local currentTheme = scope:Value(Studio.Theme)

local function DynamicColor(
	styleGuideColor: Enum.StudioStyleGuideColor,
	modifier: Enum.StudioStyleGuideModifier?
)
	return map(currentTheme, function(theme: StudioTheme)
		return theme:GetColor(styleGuideColor, modifier)
	end)
end

local Theme = {
	Background = DynamicColor(Enum.StudioStyleGuideColor.MainBackground),
	Text = DynamicColor(Enum.StudioStyleGuideColor.MainText),
}

function Theme:SetTheme(newTheme: StudioTheme)
	currentTheme:set(newTheme)
end

function Theme:GetTheme(): StudioTheme
	return peek(currentTheme)
end

Studio.ThemeChanged:Connect(function(newTheme: StudioTheme)
	Theme:SetTheme(newTheme)
end)

return Theme
