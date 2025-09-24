local Studio = settings():GetService "Studio"

local ColorPicker = require "@utility/ColorPicker"
local ContainerManager = require "@utility/ContainerManager"
local MacroManager = require "@utility/MacroManager"
local Theme = require "@utility/Theme"

local ConFusion = require "@packages/ConFusion"

local Assets = require "@plugin/Assets"
local PluginShared = require "@plugin/Shared"

local App = require "./App"
local ToolbarButton = require "./ToolbarButton"

local PLUGIN_VERSION = require "@plugin/Version"

local _firstActivation = true
local isActive = false

local buttonWidget = nil :: PluginToolbarButton
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

	if _firstActivation then
		_firstActivation = false

		MacroManager.refreshMacros()
	end
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
	local scope =
		PluginShared.Scope:innerScope { ToolbarButton = ToolbarButton }
	local toolbar = plugin:CreateToolbar(`Macro Manager {PLUGIN_VERSION}`)

	local isDark = scope:Computed(function(use: ConFusion.Use)
		local currentTheme = use(Theme.getThemeValue()) :: StudioTheme

		return currentTheme.Name == "Dark"
	end)

	buttonWidget = scope:ToolbarButton {
		toolbar = toolbar,
		id = "MacroWidget",
		name = "Macros",
		description = "Show/hide the macros widget",
		icon = scope:Computed(function(use: ConFusion.Use)
			return if use(isDark)
				then Assets.Images.WidgetButtonDark
				else Assets.Images.WidgetButtonLight
		end),

		clickableWhenViewportHidden = true,
		clickCallback = function()
			if isActive then
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
			return if use(isDark)
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

local function onThemeChange(newTheme: StudioTheme)
	Theme.setTheme(newTheme)
end

return function(plugin: Plugin)
	PluginShared.Plugin = plugin

	setupWidget(plugin)
	setupToolbar(plugin)

	plugin.Unloading:Connect(onClose)

	Studio.ThemeChanged:Connect(function()
		onThemeChange(Studio.Theme)
	end)

	onThemeChange(Studio.Theme)

	ColorPicker.initialize(plugin)
end
