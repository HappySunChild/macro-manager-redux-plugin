local Studio = settings():GetService "Studio"

local ContainerManager = require "@utility/ContainerManager"
local MacroManager = require "@utility/MacroManager"
local Theme = require "@utility/Theme"

local ColorPicker = require "@packages/ColorPicker"

local Assets = require "@plugin/Assets"
local PluginShared = require "@plugin/Shared"

local App = require "./App"

local PLUGIN_VERSION = require "@plugin/Version"

local isActive = false

local buttonWidget = nil :: PluginToolbarButton
local buttonRefresh = nil :: PluginToolbarButton
local widget = nil :: DockWidgetPluginGui

local function activate()
	if isActive then
		return
	end

	if buttonWidget == nil or widget == nil then
		return
	end

	isActive = true
	buttonWidget:SetActive(true)
	widget.Enabled = true

	MacroManager.refreshMacros()
end

local function deactivate()
	if not isActive then
		return
	end

	if buttonWidget == nil or widget == nil then
		return
	end

	isActive = false
	buttonWidget:SetActive(false)
	widget.Enabled = false
end

local function setupToolbar(plugin: Plugin)
	local toolbar = plugin:CreateToolbar(`Macro Manager {PLUGIN_VERSION}`)

	buttonWidget = toolbar:CreateButton(
		"MacroWidget",
		"Show/hide the macros widget",
		Assets.Images.WidgetButton,
		"Macros Widget"
	)
	buttonWidget:SetActive(false)
	buttonWidget.ClickableWhenViewportHidden = true
	buttonWidget.Click:Connect(function()
		if isActive then
			deactivate()
		else
			activate()
		end
	end)

	buttonRefresh = toolbar:CreateButton(
		"RefreshMacros",
		`Refresh macros in '{ContainerManager.ContainerName}.Macros' folder`,
		Assets.Images.RefreshButtonDark,
		"Refresh Macros"
	)
	buttonRefresh:SetActive(false)
	buttonRefresh.Enabled = true
	buttonRefresh.ClickableWhenViewportHidden = true
	buttonRefresh.Click:Connect(function()
		buttonRefresh:SetActive(true)
		buttonRefresh:SetActive(false)

		MacroManager.refreshMacros()
	end)
end

local function setupWidget(plugin: Plugin)
	local scope = PluginShared.Scope:innerScope { PluginWidget = App }
	local newWidget = scope:PluginWidget {
		Plugin = plugin,
		Title = `Macros {PLUGIN_VERSION}`,
	}

	newWidget:BindToClose(deactivate)

	widget = newWidget
end

local function _onClose()
	deactivate()

	PluginShared.Scope:doCleanup()
end

local function _onThemeChange(newTheme: StudioTheme)
	if buttonRefresh ~= nil then
		local isDark = newTheme.Name == "Dark"

		buttonRefresh.Icon = if isDark
			then Assets.Images.RefreshButtonDark
			else Assets.Images.RefreshButtonLight
	end

	Theme.setTheme(newTheme)
end

return function(plugin: Plugin)
	PluginShared.Plugin = plugin

	setupWidget(plugin)
	setupToolbar(plugin)

	plugin.Unloading:Connect(_onClose)

	Studio.ThemeChanged:Connect(function()
		_onThemeChange(Studio.Theme)
	end)

	_onThemeChange(Studio.Theme)

	ColorPicker.initialize(plugin)
end
