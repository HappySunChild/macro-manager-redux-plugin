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
local peek = ConFusion.peek

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

local function Title(
	scope: ConFusion.Scope,
	props: {
		Text: string,
		Icon: string?,
		Document: LuaSourceContainer?,
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
			RoundBorder = inner:RoundBorder {
				Thickness = 0,
			},

			Icon = inner:New "ImageLabel" {
				Size = UDim2.fromOffset(16, 16),

				BackgroundTransparency = 1,

				Image = props.Icon or Assets.Images.DefaultMacroIcon,
			},
			Label = inner:New "TextLabel" {
				Position = UDim2.fromOffset(18, 0),
				Size = UDim2.fromOffset(0, 16),
				AutomaticSize = Enum.AutomaticSize.X,

				Text = props.Text,
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

	local inner = scope:innerScope {
		Title = Title,
		ItemsContainer = ItemsContainer,
		RoundBorder = RoundBorder,
		TextButton = TextButton,
	}

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
		Items = macro.Items,

		Position = UDim2.fromOffset(0, 18),
		Visible = inner:Computed(function(use)
			return not use(minimized)
		end),
	}

	_callMacroMethod(macro, "Init", PluginShared.Plugin)

	if macro.Cleanup ~= nil then
		table.insert(inner, function()
			_callMacroMethod(macro, "Cleanup", PluginShared.Plugin)
		end)
	end

	return inner:New "Frame" {
		Name = `Macro_{name}`,
		Size = UDim2.new(1, 0, 0, 20),
		AutomaticSize = Enum.AutomaticSize.Y,

		Visible = inner:Computed(function(use: ConFusion.Use)
			return props.shouldShow(macro, use) and use(visible)
		end),

		LayoutOrder = macro.Order,
		BackgroundColor3 = Theme.Color.Macro.Background,

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
				Document = props.reference.Reference,
			},

			MinimizeButton = inner:TextButton {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromOffset(16, 16),

				Text = inner:Computed(function(use: ConFusion.Use)
					return if use(minimized) then "+" else "-"
				end),
				TextSize = 20,

				Callback = function()
					minimized:set(not peek(minimized))
				end,
			},

			-- RoundBorder = inner:RoundBorder { Thickness = 0 },

			Items = itemContainer,
		},
	}
end

return Macro
