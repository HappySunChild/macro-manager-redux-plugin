local ScriptEditorService = game:GetService "ScriptEditorService"
local Selection = game:GetService "Selection"

local Assets = require "@plugin/Assets"
local PluginShared = require "@plugin/Shared"

local Logging = require "@utility/Logging"
local Theme = require "@utility/Theme"

local Types = require "@plugin/Types"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local ItemsContainer = require "@components/ItemsContainer"
local RoundBorder = require "@components/RoundBorder"
local TextButton = require "@components/TextButton"

local Children, OnEvent = ConFusion.Children, ConFusion.OnEvent
local peek, doCleanup = ConFusion.peek, ConFusion.doCleanup

local function _callMacroMethod(macro: Types.Macro, method: string, ...: any)
	local func = macro[method]

	if not func then
		return
	end

	local function errHandler(err: string)
		Logging.warn("macroMethodError", Logging.parse(err), method, macro.Name)
	end

	xpcall(func, errHandler, macro, ...)
end

local function Placeholder(
	scope: ConFusion.Scope,
	props: {
		reference: Types.MacroReference,
		shouldShow: (macro: Types.Macro, use: ConFusion.Use) -> boolean,
	}
)
	local reference = props.reference
	local name = reference.Module.Name

	return scope:New "TextLabel" {
		Visible = scope:Computed(function(use: ConFusion.Use)
			return props.shouldShow({ Name = name }, use)
		end),

		Size = UDim2.new(1, 0, 0, 24),

		BackgroundColor3 = Theme.Color.Macro.Background,

		Text = `Loading {name}...`,
		TextSize = 18,
		TextColor3 = Theme.Color.Text,
	}
end

local function Title(
	scope: ConFusion.Scope,
	props: {
		text: string,
		icon: string?,
		document: LuaSourceContainer?,
	}
)
	local inner = scope:innerScope { RoundBorder = RoundBorder }
	local transparency = inner:Value(1)

	local lastClick = 0

	return inner:New "Frame" {
		Size = UDim2.fromOffset(0, 16),
		AutomaticSize = Enum.AutomaticSize.X,

		BackgroundTransparency = transparency,
		BackgroundColor3 = Theme.Color.Macro.Title.Background,

		[OnEvent "MouseEnter"] = function()
			transparency:set(0)
		end,
		[OnEvent "MouseLeave"] = function()
			transparency:set(1)
		end,
		[OnEvent "InputBegan"] = if props.document
			then function(input: InputObject)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
					return
				end

				if os.clock() - lastClick < 0.2 then
					ScriptEditorService:OpenScriptDocumentAsync(props.document)
				else
					Selection:Set { props.document }
				end

				lastClick = os.clock()
			end
			else nil,

		[Children] = {
			padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},
			border = inner:RoundBorder {
				thickness = 0,
			},

			icon = inner:New "ImageLabel" {
				Size = UDim2.fromOffset(16, 16),

				BackgroundTransparency = 1,

				Image = props.icon or Assets.Images.DefaultMacroIcon,
			},
			label = inner:New "TextLabel" {
				Position = UDim2.fromOffset(18, 0),
				Size = UDim2.fromOffset(0, 16),
				AutomaticSize = Enum.AutomaticSize.X,

				Text = props.text,
				TextSize = 16,
				TextColor3 = Theme.Color.Macro.Title.Text,
				TextTruncate = Enum.TextTruncate.AtEnd,
				FontFace = Theme.Font.Regular,

				BackgroundTransparency = 1,
			},
		},
	}
end

local function Macro(
	scope: ConFusion.Scope,
	props: {
		reference: Types.MacroReference,
		shouldShow: (macro: Types.Macro, use: ConFusion.Use) -> boolean,
	}
)
	local inner = scope:innerScope {
		Title = Title,
		ItemsContainer = ItemsContainer,
		RoundBorder = RoundBorder,
		TextButton = TextButton,
	}

	local _placeholderScope = inner:innerScope {
		Placeholder = Placeholder,
	}

	return inner:Eventual(function(_, become)
		local name = props.reference.Module.Name
		local displayName = name:gsub("(%l)([%u%d])", "%1 %2")

		local macro: Types.Macro = {} :: any
		local reqOk, reqErr = pcall(function()
			macro = require(props.reference.Module) :: any
		end)

		if not reqOk then
			Logging.warn("macroRequireError", reqErr, name)
		end

		if t.table(macro) == false then
			Logging.warn("macroInvalidType", nil, name, type(macro))

			return
		end

		if macro.Items == nil then
			Logging.warn("macroMissingItems", nil, name)
		end

		macro.Name = name

		_callMacroMethod(macro, "Setup", PluginShared.Plugin)

		local visible = inner:Value(true)
		local minimized = inner:Value(false)

		function macro:SetVisible(isVisible: boolean)
			visible:set(isVisible)
		end

		function macro:SetMinimized(isMinimized: boolean)
			minimized:set(isMinimized)
		end

		-- have to do this so items are loaded before :Init is called.
		local itemContainer = inner:ItemsContainer {
			items = macro.Items,

			position = UDim2.fromOffset(0, 18),
			visible = inner:Computed(function(use)
				return not use(minimized)
			end),
		}

		task.spawn(_callMacroMethod, macro, "Init", PluginShared.Plugin)

		if macro.Cleanup ~= nil then
			table.insert(inner, function()
				task.spawn(
					_callMacroMethod,
					macro,
					"Cleanup",
					PluginShared.Plugin
				)
			end)
		end

		become(inner:New "Frame" {
			Name = `Macro_{name}`,
			Size = UDim2.new(1, 0, 0, 20),
			AutomaticSize = Enum.AutomaticSize.Y,

			Visible = inner:Computed(
				function(use: ConFusion.Use) -- horrible coupling here, DO NOT REPLICATE!!!
					return props.shouldShow(macro, use) and use(visible)
				end
			),

			LayoutOrder = macro.Order,
			BackgroundColor3 = Theme.Color.Macro.Background,

			[Children] = {
				padding = inner:New "UIPadding" {
					PaddingLeft = UDim.new(0, 2),
					PaddingRight = UDim.new(0, 2),
					PaddingTop = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 2),
				},

				title = inner:Title {
					text = displayName,
					icon = macro.Icon,
					document = props.reference.Document,
				},
				minimize = inner:TextButton {
					anchorPoint = Vector2.new(1, 0),
					position = UDim2.fromScale(1, 0),
					size = UDim2.fromOffset(16, 16),

					text = inner:Computed(function(use: ConFusion.Use)
						return if use(minimized) then "+" else "-"
					end),
					textSize = 20,

					callback = function()
						minimized:set(not peek(minimized))
					end,
				},

				items = itemContainer,
			},
		})

		doCleanup(_placeholderScope)
	end, _placeholderScope:Placeholder(props))
end

return Macro
