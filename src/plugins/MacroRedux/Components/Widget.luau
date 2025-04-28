local pluginContainer = script.Parent.Parent

local MacroManager = require(pluginContainer.Utility.MacroManager)

local Fusion = require(pluginContainer.Packages.Fusion)
local Children = Fusion.Children

local MacroContainer = require(pluginContainer.Components.MacroContainer)
-- local Theme = require(PluginFolder.Components.Theme)

local function Widget(
	scope: Fusion.Scope,
	props: {
		Plugin: Plugin,
		Title: string,
	}
): DockWidgetPluginGui
	assert(props.Plugin, "Missing 'Plugin' property!")

	local widget = props.Plugin:CreateDockWidgetPluginGui(
		"MacrosWidget",
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, true)
	)
	widget.Name = props.Title
	widget.Title = props.Title
	widget.Enabled = false
	widget.ZIndexBehavior = Enum.ZIndexBehavior.Global

	local inner = scope:innerScope { MacroContainer = MacroContainer }

	return inner:Hydrate(widget) {
		[Children] = {
			Container = inner:MacroContainer {
				Macros = MacroManager.ActiveMacros,
			},
		},
	}
end

return Widget
