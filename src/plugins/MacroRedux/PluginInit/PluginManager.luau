local Studio = settings():GetService("Studio")

local pluginFolder = script.Parent.Parent
local Icons = require(pluginFolder.Icons)

local PLUGIN_VERSION = "1.7.0e"

local Manager = {}
Manager.Active = false
Manager.Plugin = nil :: Plugin?
Manager.Widget = nil :: DockWidgetPluginGui?

Manager.ButtonWidget = nil :: PluginToolbarButton?
Manager.ButtonRefresh = nil :: PluginToolbarButton?

function Manager:Startup(plugin: Plugin)
	Manager:SetupWidget(plugin)
	Manager:SetupToolbar(plugin)

	plugin.Unloading:Connect(function()
		Manager:OnClose()
	end)

	Studio.ThemeChanged:Connect(function()
		Manager:OnThemeChange(Studio.Theme)
	end)

	Manager:OnThemeChange(Studio.Theme)
end

function Manager:SetupWidget(plugin: Plugin)
	local widget = plugin:CreateDockWidgetPluginGui(
		"MacrosWidget",
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, true)
	)
	widget.Name = `Macros {PLUGIN_VERSION}`
	widget.Title = `Macros {PLUGIN_VERSION}`
	widget.Enabled = false
	widget.ZIndexBehavior = Enum.ZIndexBehavior.Global

	widget:BindToClose(function()
		Manager:Deactivate()
	end)

	-- TODO: Populate widget with gui stufffffff!
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
		"Refreshes macros in MACROS_STORAGE folder",
		Icons.RefreshButtonDark,
		"Refresh Macros"
	)
	buttonRefresh:SetActive(false)
	buttonRefresh.Enabled = false
	buttonRefresh.ClickableWhenViewportHidden = true
	buttonRefresh.Click:Connect(function()
		buttonRefresh:SetActive(true)
		buttonRefresh:SetActive(false)
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
end

function Manager:Deactivate()
	if not Manager.Active then
		return
	end

	Manager.Active = false
	Manager.ButtonWidget:SetActive(false)
end

function Manager:OnThemeChange(currentTheme: StudioTheme)
	local isDark = currentTheme.Name == "Dark"

	Manager.ButtonRefresh.Icon = if isDark
		then Icons.RefreshButtonDark
		else Icons.RefreshButtonLight
end

function Manager:OnClose()
	Manager:Deactivate()
end

return Manager
