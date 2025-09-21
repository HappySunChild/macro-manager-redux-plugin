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

local function callMacroMethod(macro: Types.Macro, method: string, ...: any)
	local func = macro[method]

	if not func then
		return
	end

	local function errHandler(err: string)
		Logging.warn("macroMethodError", Logging.parse(err), method, macro.Name)
	end

	xpcall(func, errHandler, macro, ...)
end

local function LoadingPlaceholder(
	scope: ConFusion.Scope,
	props: {
		reference: Types.MacroReference,
		shouldShow: (macro: Types.Macro, use: ConFusion.Use) -> boolean,
	}
)
	local inner = scope:innerScope { RoundBorder = RoundBorder }
	local reference = props.reference
	local name = reference.Module.Name

	return inner:New "Frame" {
		Visible = inner:Computed(function(use: ConFusion.Use)
			return props.shouldShow({ Name = name }, use)
		end),

		Size = UDim2.new(1, 0, 0, 24),
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundColor3 = Theme.Color.Macro.Background,

		[Children] = {
			border = inner:RoundBorder { thickness = 0 },

			label = inner:New "TextLabel" {
				Position = UDim2.fromOffset(26, 0),
				Size = UDim2.new(1, -26, 1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,

				BackgroundTransparency = 1,

				Text = `Loading {name}...`,
				TextSize = 18,
				TextColor3 = Theme.Color.Text,
				TextTruncate = Enum.TextTruncate.AtEnd,
			},
			throbber = inner:New "ImageLabel" {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 2, 0.5, 0),
				Size = UDim2.fromOffset(20, 20),

				BackgroundTransparency = 1,

				Image = Assets.Images.MacroLoadingThrobber,
				ImageColor3 = Theme.Color.BrightText,
				-- ResampleMode = Enum.ResamplerMode.Pixelated,

				Rotation = inner
					:Pipe(inner:Timer())
					:map(function(now)
						return now * 360
					end)
					:resolve(),
			},
		},
	}
end

local function ErrorPlaceholder(
	scope: ConFusion.Scope,
	props: { errorText: string }
)
	local inner = scope:innerScope { RoundBorder = RoundBorder }

	return inner:New "TextLabel" {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundColor3 = Theme.Color.Macro.Background,

		Text = props.errorText,
		TextColor3 = Theme.Color.ErrorText,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,

		[Children] = {
			border = inner:RoundBorder { thickness = 0 },
			padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
			},
		},
	}
end

local function MacroTitle(
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
		BackgroundColor3 = Color3.new(0, 0, 0),

		[OnEvent "MouseEnter"] = function()
			transparency:set(0.7)
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
		MacroTitle = MacroTitle,
		ItemsContainer = ItemsContainer,
		RoundBorder = RoundBorder,
		TextButton = TextButton,
	}

	local _placeholderScope = inner:innerScope {
		LoadingPlaceholder = LoadingPlaceholder,
		ErrorPlaceholder = ErrorPlaceholder,
	}

	return inner:Eventual(function(_, _, become)
		local name = props.reference.Module.Name
		local displayName = name:gsub("(%l)([%u%d])", "%1 %2")

		local macro: Types.Macro?
		local reqOk, reqErr = pcall(function()
			macro = require(props.reference.Module) :: any
		end)

		if not reqOk then
			Logging.warn("macroRequireError", reqErr, name)

			doCleanup(_placeholderScope)
			become(_placeholderScope:ErrorPlaceholder {
				errorText = `There was an error loading {name}!`,
			})

			return
		end

		if t.table(macro) == false then
			Logging.warn("macroInvalidType", nil, name, type(macro))

			-- i feel like the eventual is missing some pretty important features,
			-- like you should be able to add a :finally or something.
			doCleanup(_placeholderScope)
			become(nil)

			return
		end

		if macro.Items == nil then
			Logging.warn("macroMissingItems", nil, name)
		end

		macro.Name = name

		callMacroMethod(macro, "Setup", PluginShared.Plugin)

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

		task.spawn(callMacroMethod, macro, "Init", PluginShared.Plugin)

		if macro.Cleanup ~= nil then
			table.insert(inner, function()
				task.spawn(
					callMacroMethod,
					macro,
					"Cleanup",
					PluginShared.Plugin
				)
			end)
		end

		local container = inner:New "Frame" {
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
				border = inner:RoundBorder { thickness = 0 },
				padding = inner:New "UIPadding" {
					PaddingLeft = UDim.new(0, 2),
					PaddingRight = UDim.new(0, 2),
					PaddingTop = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 2),
				},

				title = inner:MacroTitle {
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
		}

		become(container)
		doCleanup(_placeholderScope)
	end, _placeholderScope:LoadingPlaceholder(props))
end

return Macro
