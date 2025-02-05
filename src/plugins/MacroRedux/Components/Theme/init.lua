export type Theme = {
	Font: Font,
	Name: string,
	
	[string]: Color3
}

local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Roact = require(Libraries.Roact)

local ThemesFolder = script.Themes
local Themes = {
	Dark = require(ThemesFolder.Dark),
	Light = require(ThemesFolder.Light)
}

local ThemeContext = Roact.createContext(nil)
local ThemeController = Roact.Component:extend('ThemeController')

local Studio = settings():GetService('Studio')

function ThemeController:updateTheme()
	local currentTheme = Studio.Theme
	
	self:setState({
		Theme = Themes[currentTheme.Name] or Themes.Light
	})
end

function ThemeController:init()
	self:updateTheme()
end

function ThemeController:render()
	return Roact.createElement(ThemeContext.Provider, {
		value = self.state.Theme
	}, self.props[Roact.Children])
end

function ThemeController:didMount()
	self.Connection = Studio.ThemeChanged:Connect(function()
		self:updateTheme()
	end)
end

function ThemeController:willUnmount()
	self.Connection:Disconnect()
end

return {
	Controller = ThemeController,
	Consumer = ThemeContext.Consumer,
	
	-- interesting...
	Changed = Studio.ThemeChanged,
	
	getCurrentTheme = function()
		return Themes[Studio.Theme.Name] or Themes.Light
	end,
	
	
	with = function(renderCallback: (Theme) -> Roact.Element)
		return Roact.createElement(ThemeContext.Consumer, {render = renderCallback})
	end,
}