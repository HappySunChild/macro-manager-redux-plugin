local MacroManager = require "@utility/MacroManager"
local merge = require "@utility/merge"

local ConFusion = require "@packages/ConFusion"

local Page = require "@components/Page"

local Pages = require "./Pages"

local Children = ConFusion.Children

type PageIndex = keyof<typeof(Pages)>

local function App(
	scope: ConFusion.Scope,
	props: {
		plugin: Plugin,
		title: string,
	}
): DockWidgetPluginGui
	assert(props.plugin, "Missing 'plugin' property!")

	local widget = props.plugin:CreateDockWidgetPluginGui(
		"MacrosWidget",
		DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, true)
	)
	widget.Name = props.title
	widget.Title = props.title
	widget.Enabled = false
	widget.ZIndexBehavior = Enum.ZIndexBehavior.Global

	local inner = scope:innerScope { Page = Page }
	local currentPage = inner:Value "Macros"

	local function createPage(name: PageIndex, pageProps: { [string]: unknown })
		local component = Pages[name]

		if not component then
			error(`Unknown page '{name}'`, 2)
		end

		local active = inner:Computed(function(use: ConFusion.Use)
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
			}),
			TheRockWithPancakesPage = createPage(
				"TheRockWithPancakes",
				{ navigate = navigate }
			),
		},
	}
end

return App
