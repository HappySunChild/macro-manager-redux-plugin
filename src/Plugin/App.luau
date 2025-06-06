local MacroManager = require "@utility/MacroManager"
local merge = require "@utility/merge"

local Fusion = require "@packages/Fusion"

local Page = require "@components/Page"

local Pages = require "./Pages"

local Children = Fusion.Children

type PageIndex = keyof<typeof(Pages)>

local function App(
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

	local inner = scope:innerScope { Page = Page }
	local currentPage = inner:Value "Macros"

	local function createPage(name: PageIndex, pageProps: { [string]: unknown })
		local component = Pages[name]

		if not component then
			error(`Unknown page '{name}'`, 2)
		end

		local active = inner:Computed(function(use: Fusion.Use)
			return use(currentPage) == name
		end)

		return inner:Page {
			active = active,
			content = component(inner, merge({ active = active }, pageProps)),
		}
	end

	local function navigate(page: PageIndex)
		currentPage:set(page)
	end

	return inner:Hydrate(widget) {
		[Children] = {
			MacrosPage = createPage("Macros", {
				macros = MacroManager.ActiveMacros,
				navigate = navigate,
			}),
			SettingsPage = createPage("Settings", {
				navigate = navigate,
			}),
			TheRockWithPancakesPage = createPage(
				"TheRockWithPancakes",
				{ navigate = navigate }
			),
		},
	}
end

return App
