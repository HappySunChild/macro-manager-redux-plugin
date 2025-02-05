local ScriptEditorService = game:GetService("ScriptEditorService")
local StudioService = game:GetService("StudioService")

local pluginFolder = script.Parent.Parent

local Components = pluginFolder.Components
local Libraries = pluginFolder.Libraries

local Roact = require(Libraries.Roact)
local ScriptEditor = require(Libraries.ScriptEditor)
local MacroManager = require(Libraries.MacroManager)
local PluginShared = require(Libraries.Shared)
local PluginSettings = require(Libraries.Settings)

local Studio = settings():GetService('Studio')
local App = require(Components.App)

local manager = {}
manager.VERSION = '1.6.26'
manager.Initiated = false
manager.Active = false

function manager:Init(currentPlugin: Plugin)
	if self.Initiated then
		return
	end
	
	currentPlugin.Name = 'MacroManager' .. self.VERSION
	
	self.Initiated = true
	self.Plugin = currentPlugin
	
	PluginShared.Plugin = currentPlugin
	PluginShared.CurrentUserId = StudioService:GetUserId()
	
	self:CreateWidget(currentPlugin)
	
	local toolbar = currentPlugin:CreateToolbar(`Macro Manager {self.VERSION}`)
	
	local widgetButton = toolbar:CreateButton('MacrosWidget', 'Show or hide the macros widget', 'rbxassetid://95866080', 'Macros Widget')
	widgetButton:SetActive(false)
	widgetButton.ClickableWhenViewportHidden = true
	widgetButton.Click:Connect(function()
		if not MacroManager.SearchFolder then
			MacroManager:SetupMacroFolder()
		end
		
		MacroManager:AddMacros(MacroManager.SearchFolder)
		
		if not self.Active then
			self:Activate()
		else
			self:Deactivate()
		end
	end)
	
	local refreshButton = toolbar:CreateButton('RefreshMacros', `Refresh macros in {MacroManager.FolderName} folder`, 'rbxassetid://17210895174', 'Refresh Macros')
	refreshButton:SetActive(false)
	refreshButton.Enabled = false
	refreshButton.ClickableWhenViewportHidden = true
	refreshButton.Click:Connect(function()
		refreshButton:SetActive(true)
		refreshButton:SetActive(false)
		
		if not self.Active then
			return
		end
		
		MacroManager:RefereshMacros()
	end)
	
	self.RefreshButton = refreshButton
	self.WidgetButton = widgetButton
	
	currentPlugin.Unloading:Connect(function()
		self:OnClose()
	end)
	
	self:LoadSettings()
	self:UpdateToolbar()
	
	Studio.ThemeChanged:Connect(function()
		self:UpdateToolbar()
	end)
	
	pcall(function()
		ScriptEditorService:DeregisterAutocompleteCallback('MacroAutocomplete')
	end)
	
	ScriptEditorService:RegisterAutocompleteCallback('MacroAutocomplete', ScriptEditor.REGISTER_PRIORITY, ScriptEditor.AutocompleteCallback)
end

function manager:CreateWidget(plugin: Plugin)
	if self.Widget then
		self.Widget:Destroy()
	end
	
	if self.Tree then
		Roact.unmount(self.Tree)
	end
	
	local widgetInfo = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Left,
		true
	)
	
	local widget = plugin:CreateDockWidgetPluginGui('MacrosWidget', widgetInfo)
	widget.Name = `Macros {self.VERSION}`
	widget.Title = `Macros {self.VERSION}`
	widget.Enabled = false
	widget.ZIndexBehavior = Enum.ZIndexBehavior.Global
	
	widget:BindToClose(function()
		self:Deactivate()
	end)
	
	PluginShared.Widget = widget
	
	self.Tree = Roact.mount(Roact.createElement(App), widget, 'Background')
	self.Widget = widget
end


function manager:LoadSettings()
	local pluginSettings = self.Plugin:GetSetting('MacroManager') or {}
	
	PluginSettings.Settings = pluginSettings
end

function manager:SaveSettings()
	self.Plugin:SetSetting('MacroManager', PluginSettings.Settings)
end


function manager:UpdateToolbar()
	local currentTheme = Studio.Theme
	local isDark = currentTheme.Name == 'Dark'
	
	self.RefreshButton.Icon = isDark and 'rbxassetid://17210895174' or 'rbxassetid://17210880996'
end

function manager:Activate()
	if not self.Initiated then
		return
	end
	
	if self.Active then
		return
	end
	
	local hasSeenRock = PluginSettings:Get('HasSeenRock')
	
	if math.random() <= (hasSeenRock and 0.01 or 0.05) then
		local rockSecret = require(script.Parent.therocksecret)
		rockSecret:Run(self.Plugin, self.Widget)
	end
	
	self.Active = true
	self.Widget.Enabled = true
	self.RefreshButton.Enabled = true
	self.WidgetButton:SetActive(true)
end

function manager:Deactivate()
	if not self.Initiated then
		return
	end
	
	if not self.Active then
		return
	end
	
	self.Active = false
	self.Widget.Enabled = false
	self.RefreshButton.Enabled = false
	self.WidgetButton:SetActive(false)
end

function manager:OnClose()
	self:Deactivate()
	
	ScriptEditorService:DeregisterAutocompleteCallback('MacroAutocomplete')
	
	if self.Tree then
		Roact.unmount(self.Tree)
	end
	
	self:SaveSettings()
end

return manager