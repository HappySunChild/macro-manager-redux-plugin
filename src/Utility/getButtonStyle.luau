local Theme = require "./Theme"

local DEFAULT_STYLE = Theme.ButtonStyles.Default

local function getButtonStyle(
	style: Theme.ButtonStyle | string,
	key: string
): any?
	if type(style) == "string" then
		style = Theme.ButtonStyles[style]
	end

	style = style or DEFAULT_STYLE

	local styleValue = style[key]

	if styleValue ~= nil then
		return styleValue
	end

	return DEFAULT_STYLE[key]
end

return getButtonStyle
