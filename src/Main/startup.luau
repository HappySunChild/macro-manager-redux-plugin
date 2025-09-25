local Studio = settings():GetService "Studio"

local Assets = require "@plugin/Assets"
local PLUGIN_VERSION = require "@plugin/Version"
local PluginShared = require "@plugin/Shared"

local ConFusion = require "@packages/ConFusion"

local ColorPicker = require "@utility/ColorPicker"
local ContainerManager = require "@utility/ContainerManager"
local MacroManager = require "@utility/MacroManager"
local Theme = require "@utility/Theme"

local App = require "./App"
local ToolbarButton = require "./ToolbarButton"

local first_activation = true
local is_active = false

local toolbar_button_widget = nil :: PluginToolbarButton
local widget = nil :: DockWidgetPluginGui

local function activate()
	if is_active or toolbar_button_widget == nil or widget == nil then
		return
	end

	is_active = true
	toolbar_button_widget:SetActive(true)

	widget.Enabled = true

	if first_activation then
		first_activation = false

		MacroManager.refreshMacros()
	end
end

local function deactivate()
	if not is_active then
		return
	end

	if toolbar_button_widget == nil or widget == nil then
		return
	end

	is_active = false
	toolbar_button_widget:SetActive(false)

	widget.Enabled = false
end

local function setupToolbar(plugin: Plugin)
	local scope =
		PluginShared.Scope:innerScope { ToolbarButton = ToolbarButton }
	local toolbar = plugin:CreateToolbar(`Macro Manager {PLUGIN_VERSION}`)

	local is_dark = scope:Computed(function(use: ConFusion.Use)
		local currentTheme = use(Theme.getThemeValue()) :: StudioTheme

		return currentTheme.Name == "Dark"
	end)

	toolbar_button_widget = scope:ToolbarButton {
		toolbar = toolbar,
		id = "MacroWidget",
		name = "Macros",
		description = "Show/hide the macros widget",
		icon = scope:Computed(function(use: ConFusion.Use)
			return if use(is_dark)
				then Assets.Images.WidgetButtonDark
				else Assets.Images.WidgetButtonLight
		end),

		clickableWhenViewportHidden = true,
		clickCallback = function()
			if is_active then
				deactivate()
			else
				activate()
			end
		end,
	}

	scope:ToolbarButton {
		toolbar = toolbar,
		id = "RefreshMacros",
		name = "Refresh",
		description = `Refresh macros in '{ContainerManager.ContainerName}.Macros' folder`,
		icon = scope:Computed(function(use: ConFusion.Use)
			return if use(is_dark)
				then Assets.Images.RefreshButtonDark
				else Assets.Images.RefreshButtonLight
		end),

		clickableWhenViewportHidden = true,
		noToggle = true,
		clickCallback = MacroManager.refreshMacros,
	}
end

local function setupWidget(plugin: Plugin)
	local scope = PluginShared.Scope:innerScope { PluginWidget = App }
	local newWidget = scope:PluginWidget {
		plugin = plugin,
		title = `Macros {PLUGIN_VERSION}`,
	}

	newWidget:BindToClose(deactivate)

	widget = newWidget
end

local function onClose()
	deactivate()

	PluginShared.Scope:doCleanup()
end

return function(plugin: Plugin)
	PluginShared.Plugin = plugin

	ColorPicker.initialize(plugin)

	setupWidget(plugin)
	setupToolbar(plugin)

	plugin.Unloading:Connect(onClose)

	Studio.ThemeChanged:Connect(function()
		Theme.setTheme(Studio.Theme)
	end)

	Theme.setTheme(Studio.Theme)
end
