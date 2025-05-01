local ScriptEditorService = game:GetService "ScriptEditorService"
local Selection = game:GetService "Selection"

local pluginContainer = script.Parent.Parent

local Icons = require(pluginContainer.Plugin.Icons)
local PluginShared = require(pluginContainer.Plugin.Shared)
local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local Corners = require(pluginContainer.Components.Corners)
local ItemsContainer = require(pluginContainer.Components.ItemsContainer)
local Theme = require(pluginContainer.Components.Theme)

local function Title(
	scope: Fusion.Scope,
	props: {
		Text: string,
		Icon: string?,
		Document: LuaSourceContainer?,
	}
)
	local inner = scope:innerScope { Corners = Corners }
	local transparency = inner:Value(1)

	local lastClick = 0

	return inner:New "Frame" {
		Size = UDim2.fromOffset(0, 16),
		AutomaticSize = Enum.AutomaticSize.X,

		BackgroundTransparency = transparency,
		BackgroundColor3 = Theme.Colors.MacroTitleBackground,

		[OnEvent "MouseEnter"] = function()
			transparency:set(0)
		end,
		[OnEvent "MouseLeave"] = function()
			transparency:set(1)
		end,
		[OnEvent "InputBegan"] = if props.Document
			then function(input: InputObject)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
					return
				end

				if os.clock() - lastClick < 0.2 then
					ScriptEditorService:OpenScriptDocumentAsync(props.Document)
				else
					Selection:Set { props.Document }
				end

				lastClick = os.clock()
			end
			else nil,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},
			Corners = inner:Corners {
				Thickness = 0,
			},

			Icon = inner:New "ImageLabel" {
				Size = UDim2.fromOffset(16, 16),

				BackgroundTransparency = 1,

				Image = props.Icon or Icons.DefaultMacroIcon,
			},
			Label = inner:New "TextLabel" {
				Position = UDim2.fromOffset(18, 0),
				Size = UDim2.fromOffset(0, 16),
				AutomaticSize = Enum.AutomaticSize.X,

				Text = props.Text,
				TextSize = 16,
				TextColor3 = Theme.Colors.TitleText,
				TextTruncate = Enum.TextTruncate.AtEnd,
				FontFace = Theme.Font,

				BackgroundTransparency = 1,
			},
		},
	}
end

local function Macro(
	scope: Fusion.Scope,
	props: {
		Module: ModuleScript,
		Reference: Instance?,
	}
)
	local name = props.Module.Name
	local displayName = name:gsub("(%l)([%u%d])", "%1 %2")

	local macro: Types.Macro = {}
	local reqSuccess, reqErr = pcall(function()
		macro = require(props.Module) :: unknown
	end)

	if not reqSuccess then
		warn(`Error occured while requiring Macro '{name}'\n{reqErr}`)
	end

	local inner = scope:innerScope {
		Title = Title,
		ItemsContainer = ItemsContainer,
		Corners = Corners,
	}

	if macro.Setup then
		local success, err = pcall(macro.Setup, macro, PluginShared.Plugin)

		if not success then
			warn(`Error occured while running :Setup for Macro '{name}'\n{err}`)
		end
	end

	local visible = inner:Value(true)
	local minimized = inner:Value(false)

	function macro:SetVisible(isVisible: boolean)
		visible:set(isVisible)
	end

	function macro:SetMinimized(isMinimized: boolean)
		minimized:set(isMinimized)
	end

	-- have to do this so items are loaded before :Init is called.
	local itemContainer = inner:ItemsContainer { Items = macro.Items }

	if macro.Init then
		local success, err = pcall(macro.Init, macro, PluginShared.Plugin)

		if not success then
			warn(`Error occured while running :Init for Macro '{name}'\n{err}`)
		end
	end

	if macro.Cleanup then
		table.insert(inner, function()
			local success, err =
				pcall(macro.Cleanup, macro, PluginShared.Plugin)

			if not success then
				warn(
					`Error occured while running :Cleanup for Macro '{name}'\n{err}`
				)
			end
		end)
	end

	return inner:New "Frame" {
		Name = `Macro_{name}`,
		Size = UDim2.new(1, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.Y,

		Visible = visible,

		LayoutOrder = macro.Order,
		BackgroundColor3 = Theme.Colors.MacroBackground,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
			},

			Title = inner:Title {
				Text = displayName,
				Icon = macro.Icon,
				Document = props.Reference,
			},

			Corners = inner:Corners { Thickness = 0 },

			Items = inner:Computed(function(use)
				return if use(minimized) then nil else itemContainer
			end),
		},
	}
end

return Macro
