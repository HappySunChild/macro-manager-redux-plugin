local ScriptEditorService = game:GetService "ScriptEditorService"
local Selection = game:GetService "Selection"

local Assets = require "@plugin/Assets"
local PluginShared = require "@plugin/Shared"
local types = require "@plugin/types"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local Logging = require "@utility/Logging"
local Theme = require "@utility/Theme"

local ItemsContainer = require "@components/ItemsContainer"
local RoundBorder = require "@components/RoundBorder"
local TextButton = require "@components/TextButton"

local Children, OnEvent = ConFusion.Children, ConFusion.OnEvent
local peek = ConFusion.peek

local function callMacroMethod(macro: types.Macro, method: string, ...: any)
	local func = macro[method]

	if not func then
		return
	end

	local function errHandler(err: string)
		Logging.warn("macroMethodError", Logging.parse(err), method, macro.Name)
	end

	xpcall(func, errHandler, macro, ...)
end

local function getMacroSettings(name: string): types.MacroSettingsObject
	local settings_object = PluginShared.settings.macro_settings[name]

	if settings_object == nil then
		settings_object = {}
		PluginShared.settings.macro_settings[name] = settings_object
	end

	return settings_object
end

local function LoadingPlaceholder(
	scope: ConFusion.Scope,
	props: {
		reference: types.MacroReference,
		shouldShow: (macro: types.Macro, use: ConFusion.Use) -> boolean,
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
		reference: types.MacroReference,
		shouldShow: (macro: types.Macro, use: ConFusion.Use) -> boolean,
	}
)
	local inner = scope:innerScope {
		MacroTitle = MacroTitle,
		ItemsContainer = ItemsContainer,
		RoundBorder = RoundBorder,
		TextButton = TextButton,

		LoadingPlaceholder = LoadingPlaceholder,
		ErrorPlaceholder = ErrorPlaceholder,
	}

	return inner:Eventual(function(_, scope: typeof(inner), become)
		local name = props.reference.Module.Name
		local display_name = name:gsub("(%l)([%u%d])", "%1 %2")

		become(scope:LoadingPlaceholder(props))

		local ok, macro_object: types.Macro = pcall(function()
			return require(props.reference.Module) :: any
		end)

		-- macro checks
		if not ok then
			Logging.warn("macroRequireError", macro_object, name)

			return become(scope:ErrorPlaceholder {
				errorText = `There was an error loading {name}!`,
			})
		end

		if t.table(macro_object) == false then
			Logging.warn("macroInvalidType", nil, name, type(macro_object))

			return become(nil)
		end

		if macro_object.Items == nil then
			Logging.warn("macroMissingItems", nil, name)
		end

		macro_object.Name = name

		local macro_settings_objects = getMacroSettings(name)

		local visible = scope:Value(macro_object.Visible or true)
		local minimized = scope:Value(
			macro_settings_objects.minimized or macro_object.Minimized or false
		)

		-- connecting macro_object properties and settings object to visible and minimized
		scope:observe(minimized, function()
			local is_minimized = peek(minimized)

			macro_object.Minimized = is_minimized
			macro_settings_objects.minimized = is_minimized
		end, true)
		scope:observe(visible, function()
			local is_visible = peek(visible)

			macro_object.Visible = is_visible
		end)

		callMacroMethod(
			macro_object,
			"Setup",
			PluginShared.plugin,
			macro_settings_objects
		)

		function macro_object:SetVisible(is_visible: boolean)
			visible:set(is_visible)
		end

		function macro_object:SetMinimized(is_minimized: boolean)
			minimized:set(is_minimized)
		end

		-- have to do this so items are loaded before :Init is called.
		local items_container = scope:ItemsContainer {
			items = macro_object.Items,

			position = UDim2.fromOffset(0, 18),
			visible = scope:Computed(function(use)
				return not use(minimized)
			end),
		}

		task.spawn(
			callMacroMethod,
			macro_object,
			"Init",
			PluginShared.plugin,
			macro_settings_objects
		)

		if macro_object.Cleanup ~= nil then
			table.insert(scope, function()
				task.spawn(
					callMacroMethod,
					macro_object,
					"Cleanup",
					PluginShared.plugin,
					macro_settings_objects
				)
			end)
		end

		return become(scope:New "Frame" {
			Name = `Macro_{name}`,
			Size = UDim2.new(1, 0, 0, 20),
			AutomaticSize = Enum.AutomaticSize.Y,

			Visible = scope:Computed(
				function(use: ConFusion.Use) -- horrible coupling here, DO NOT REPLICATE!!!
					return props.shouldShow(macro_object, use) and use(visible)
				end
			),

			LayoutOrder = macro_object.Order,
			BackgroundColor3 = Theme.Color.Macro.Background,

			[Children] = {
				border = scope:RoundBorder { thickness = 0 },
				padding = scope:New "UIPadding" {
					PaddingLeft = UDim.new(0, 2),
					PaddingRight = UDim.new(0, 2),
					PaddingTop = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 2),
				},

				title = scope:MacroTitle {
					text = display_name,
					icon = macro_object.Icon,
					document = props.reference.Document,
				},
				minimize = scope:TextButton {
					anchorPoint = Vector2.new(1, 0),
					position = UDim2.fromScale(1, 0),
					size = UDim2.fromOffset(16, 16),

					text = scope:Computed(function(use: ConFusion.Use)
						return if use(minimized) then "+" else "-"
					end),
					textSize = 20,

					callback = function()
						minimized:set(not peek(minimized))
					end,
				},

				items = items_container,
			},
		})
	end)
end

return Macro
