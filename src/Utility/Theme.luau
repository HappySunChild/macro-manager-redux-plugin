--!nocheck
local Studio = settings():GetService "Studio"

local ConFusion = require "@packages/ConFusion"
local PluginShared = require "@plugin/Shared"

local scope = PluginShared.Scope
local currentTheme = scope:Value(Studio.Theme)

local MISSING_COLOR = Color3.new(1, 0, 1)

local _studioColorCache = {}

local function StudioColor(
	styleGuideColor: Enum.StudioStyleGuideColor,
	modifier: Enum.StudioStyleGuideModifier?
): ConFusion.Computed<Color3>
	modifier = modifier or Enum.StudioStyleGuideModifier.Default

	if _studioColorCache[styleGuideColor.Name] == nil then
		_studioColorCache[styleGuideColor.Name] = {}
	else
		local cached = _studioColorCache[styleGuideColor.Name][modifier.Name]

		if cached then
			return cached
		end
	end

	local dynamicColor = scope:Computed(function(use: ConFusion.Use)
		local theme = use(currentTheme)

		if not theme then
			return MISSING_COLOR
		end

		return theme:GetColor(styleGuideColor, modifier)
	end)

	_studioColorCache[styleGuideColor.Name][modifier.Name] = dynamicColor

	return dynamicColor
end

local function ColorSet(set: { [string]: Color3 }): ConFusion.Computed<Color3>
	return scope:Computed(function(use: ConFusion.Use)
		local theme = use(currentTheme)

		if not theme then
			return MISSING_COLOR
		end

		return set[theme.Name] or MISSING_COLOR
	end)
end

export type ButtonStyle = {
	Text: ConFusion.UsedAs<Color3>,

	Background: ConFusion.UsedAs<Color3>,
	HoverBackground: ConFusion.UsedAs<Color3>,
	PressedBackground: ConFusion.UsedAs<Color3>,

	HasBorder: boolean?,
	Border: ConFusion.UsedAs<Color3>?,
	HoverBorder: ConFusion.UsedAs<Color3>?,
}

local BORDER_COLOR = StudioColor(Enum.StudioStyleGuideColor.Border)
local DEFAULT_BUTTON_STYLE: ButtonStyle = {
	Text = StudioColor(Enum.StudioStyleGuideColor.ButtonText),
	Background = StudioColor(Enum.StudioStyleGuideColor.Button),
	HoverBackground = StudioColor(
		Enum.StudioStyleGuideColor.Button,
		Enum.StudioStyleGuideModifier.Hover
	),
	PressedBackground = StudioColor(
		Enum.StudioStyleGuideColor.Button,
		Enum.StudioStyleGuideModifier.Pressed
	),
	Border = BORDER_COLOR,
}

return table.freeze {
	setTheme = function(newTheme: StudioTheme)
		currentTheme:set(newTheme)
	end,
	getThemeValue = function(): ConFusion.Value<StudioTheme>
		return currentTheme
	end,

	Font = {
		Regular = Font.fromName "SourceSansPro",
		Bold = Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
	},

	Color = {
		Text = StudioColor(Enum.StudioStyleGuideColor.MainText),
		BrightText = StudioColor(Enum.StudioStyleGuideColor.BrightText),
		SubText = StudioColor(Enum.StudioStyleGuideColor.SubText),
		DimmedText = StudioColor(Enum.StudioStyleGuideColor.DimmedText),
		ErrorText = StudioColor(Enum.StudioStyleGuideColor.ErrorText),

		MainBackground = StudioColor(Enum.StudioStyleGuideColor.MainBackground),

		ScrollBar = {
			Idle = StudioColor(Enum.StudioStyleGuideColor.ScrollBar),
			Hover = StudioColor(
				Enum.StudioStyleGuideColor.ScrollBar,
				Enum.StudioStyleGuideModifier.Hover
			),
		},

		Border = BORDER_COLOR,
		AccentBorder = ColorSet {
			Light = Color3.fromRGB(108, 130, 255),
			Dark = Color3.fromRGB(247, 152, 58),
		},

		Macro = {
			Title = {
				Text = StudioColor(Enum.StudioStyleGuideColor.InfoText),
			},
			Background = StudioColor(
				Enum.StudioStyleGuideColor.Dark,
				Enum.StudioStyleGuideModifier.Selected
			),
		},
		Item = {
			Background = StudioColor(Enum.StudioStyleGuideColor.TabBar),
		},
		Section = {
			Background = StudioColor(Enum.StudioStyleGuideColor.Dark),
			BackgroundAlt = StudioColor(Enum.StudioStyleGuideColor.Light),
			-- Background = ColorSet {
			-- 	Light = Color3.fromRGB(239, 239, 239),
			-- 	Dark = Color3.fromRGB(55, 55, 55),
			-- },
			-- BackgroundAlt = ColorSet {
			-- 	Light = Color3.fromRGB(255, 255, 255),
			-- 	Dark = Color3.fromRGB(50, 50, 50),
			-- },
			Border = BORDER_COLOR,
		},

		InputField = {
			Background = StudioColor(
				Enum.StudioStyleGuideColor.InputFieldBackground
			),
		},

		Slider = {
			Background = ColorSet {
				Light = Color3.fromRGB(208, 208, 208),
				Dark = Color3.fromRGB(74, 74, 74),
			},
			Handle = ColorSet {
				Light = Color3.fromRGB(232, 232, 232),
				Dark = Color3.fromRGB(200, 200, 200),
			},
			Border = StudioColor(
				Enum.StudioStyleGuideColor.Dark,
				Enum.StudioStyleGuideModifier.Selected
			),
		},

		DropdownItem = {
			Background = StudioColor(Enum.StudioStyleGuideColor.HeaderSection),
			BackgroundAlt = StudioColor(
				Enum.StudioStyleGuideColor.HeaderSection,
				Enum.StudioStyleGuideModifier.Pressed
			),
		},
	},

	TweenInfo = {
		Highlight = TweenInfo.new(0.1),
		Page = TweenInfo.new(
			0.2,
			Enum.EasingStyle.Cubic,
			Enum.EasingDirection.Out
		),
		DropdownRotation = TweenInfo.new(0.2),
	},

	ButtonStyles = {
		Default = DEFAULT_BUTTON_STYLE,
		Input = {
			Background = StudioColor(
				Enum.StudioStyleGuideColor.InputFieldBackground
			),
		},
		Red = {
			Text = Color3.new(1, 1, 1),
			Background = Color3.fromRGB(225, 77, 77),
			HoverBackground = Color3.fromRGB(228, 110, 108),
			PressedBackground = Color3.fromRGB(188, 82, 80),
			HasBorder = false,
		},
		Blue = {
			Text = Color3.new(1, 1, 1),
			Background = Color3.fromRGB(74, 104, 236),
			HoverBackground = Color3.fromRGB(97, 124, 245),
			PressedBackground = Color3.fromRGB(77, 98, 196),
			HasBorder = false,
		},
		Green = {
			Text = Color3.new(1, 1, 1),
			Background = Color3.fromRGB(67, 166, 58),
			HoverBackground = Color3.fromRGB(89, 187, 80),
			PressedBackground = Color3.fromRGB(61, 154, 52),
			HasBorder = false,
		},
	},

	Roundness = UDim.new(0, 4),
}
