local Studio = settings():GetService "Studio"

local PluginContainer = script.Parent.Parent

local ContainerManager = require(PluginContainer.Plugin.ContainerManager)
local Icons = require(PluginContainer.Plugin.Icons)
local MacroManager = require(PluginContainer.Plugin.MacroManager)
local PluginScope = require(PluginContainer.Plugin.Scope)

local Theme = require(PluginContainer.Components.Theme)
local Widget = require(PluginContainer.Components.Widget)

local PLUGIN_VERSION = PluginContainer.Version.Value

local Manager = {}
Manager.Active = false
Manager.Plugin = nil :: Plugin?
Manager.Widget = nil :: DockWidgetPluginGui?

Manager.ButtonWidget = nil :: PluginToolbarButton?
Manager.ButtonRefresh = nil :: PluginToolbarButton?

function Manager:Initialize(plugin: Plugin)
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
	MacroManager:LoadMacrosFromContainer()
end

function Manager:SetupWidget(plugin: Plugin)
	local scope = PluginScope:deriveScope { Widget = Widget }
	local widget = scope:Widget {
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
		Icons.WidgetButton,
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
		`Refresh macros in \`{MacroManager.ContainerName}.Macros\` folder.`,
		Icons.RefreshButtonDark,
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
		then Icons.RefreshButtonDark
		else Icons.RefreshButtonLight

	Theme:SetTheme(currentTheme)
end

function Manager:OnClose()
	Manager:Deactivate()

	PluginScope:doCleanup()
end

return Manager
