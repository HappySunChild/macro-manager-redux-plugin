local PluginFolder = script.Parent.Parent

local Fusion = require(PluginFolder.Packages.Fusion)
local Children = Fusion.Children

local Theme = require(PluginFolder.Components.Theme)

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

	return scope:Hydrate(widget) {
		[Children] = {
			Background = scope:New "Frame" {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Theme.colors.Background,
			},
		},
	}
end

return Widget
