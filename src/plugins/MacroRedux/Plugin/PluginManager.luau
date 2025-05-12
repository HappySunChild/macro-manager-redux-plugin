local Studio = settings():GetService "Studio"

local pluginContainer = script.Parent.Parent

local ContainerManager = require(pluginContainer.Utility.ContainerManager)
local MacroManager = require(pluginContainer.Utility.MacroManager)
local Theme = require(pluginContainer.Utility.Theme)

local ColorPicker = require(pluginContainer.Packages.ColorPicker)

local Assets = require(pluginContainer.Plugin.Assets)
local PluginShared = require(pluginContainer.Plugin.Shared)

local PluginWidget = require(pluginContainer.Components.PluginWidget)

local PLUGIN_VERSION = pluginContainer.Version.Value

local Manager = {}
Manager.Active = false
Manager.Plugin = nil :: Plugin?
Manager.Widget = nil :: DockWidgetPluginGui?

Manager.ButtonWidget = nil :: PluginToolbarButton?
Manager.ButtonRefresh = nil :: PluginToolbarButton?

function Manager:Initialize(plugin: Plugin)
	PluginShared.Plugin = plugin

	Manager:SetupWidget(plugin)
	Manager:SetupToolbar(plugin)

	plugin.Unloading:Connect(function()
		Manager:OnClose()
	end)

	Studio.ThemeChanged:Connect(function()
		Manager:OnThemeChange(Studio.Theme)
	end)

	Manager:OnThemeChange(Studio.Theme)

	ContainerManager:SetupContainer()
	MacroManager:LoadCurrentContainer()

	ColorPicker:Initialize(plugin)
end

function Manager:SetupWidget(plugin: Plugin)
	local scope = PluginShared.Scope:innerScope { PluginWidget = PluginWidget }
	local widget = scope:PluginWidget {
		Plugin = plugin,
		Title = `Macros {PLUGIN_VERSION}`,
	}

	widget:BindToClose(function()
		Manager:Deactivate()
	end)

	Manager.Widget = widget
end

function Manager:SetupToolbar(plugin: Plugin)
	local toolbar = plugin:CreateToolbar(`Macro Manager {PLUGIN_VERSION}`)

	local buttonWidget = toolbar:CreateButton(
		"MacroWidget",
		"Show/hide the macros widget",
		Assets.Images.WidgetButton,
		"Macros Widget"
	)
	buttonWidget:SetActive(false)
	buttonWidget.ClickableWhenViewportHidden = true
	buttonWidget.Click:Connect(function()
		if Manager.Active then
			Manager:Deactivate()
		else
			Manager:Activate()
		end
	end)

	local buttonRefresh = toolbar:CreateButton(
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

		MacroManager:RefreshMacros()
	end)

	Manager.ButtonWidget = buttonWidget
	Manager.ButtonRefresh = buttonRefresh
end

function Manager:Activate()
	if Manager.Active then
		return
	end

	Manager.Active = true
	Manager.ButtonWidget:SetActive(true)
	Manager.Widget.Enabled = true
end

function Manager:Deactivate()
	if not Manager.Active then
		return
	end

	Manager.Active = false
	Manager.ButtonWidget:SetActive(false)
	Manager.Widget.Enabled = false
end

function Manager:OnThemeChange(currentTheme: StudioTheme)
	local isDark = currentTheme.Name == "Dark"

	Manager.ButtonRefresh.Icon = if isDark
		then Assets.Images.RefreshButtonDark
		else Assets.Images.RefreshButtonLight

	Theme:SetTheme(currentTheme)
end

function Manager:OnClose()
	Manager:Deactivate()

	PluginShared.Scope:doCleanup()
end

return Manager
