local ScriptEditorService = game:GetService "ScriptEditorService"
local Selection = game:GetService "Selection"

local pluginContainer = script.Parent.Parent

local Icons = require(pluginContainer.Plugin.Icons)

local Fusion = require(pluginContainer.Packages.Fusion)
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

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
	local transparency = scope:Value(1)

	local lastClick = 0

	return scope:New "Frame" {
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
			Padding = scope:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},
			Icon = scope:New "ImageLabel" {
				Size = UDim2.fromOffset(16, 16),

				BackgroundTransparency = 1,

				Image = props.Icon or Icons.DefaultMacroIcon,
			},
			Label = scope:New "TextLabel" {
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

	local macro = {}
	local success, err = pcall(function()
		macro = require(props.Module) :: unknown
	end)

	if not success then
		warn(`Error occured while requiring Macro '{name}'\n{err}`)
	end

	local inner =
		scope:innerScope { Title = Title, ItemsContainer = ItemsContainer }

	return inner:New "Frame" {
		Name = `Macro_{name}`,
		Size = UDim2.new(1, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.Y,

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
				Document = props.Reference,
			},
			Items = inner:ItemsContainer { Items = macro.Items },
		},
	}
end

return Macro
