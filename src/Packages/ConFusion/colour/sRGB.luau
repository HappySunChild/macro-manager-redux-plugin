local function transform(channel: number): number
	if channel >= 0.04045 then
		return ((channel + 0.055) / (1 + 0.055)) ^ 2.4
	else
		return channel / 12.92
	end
end

local function inverse(channel: number): number
	if channel >= 0.0031308 then
		return 1.055 * channel ^ (1.0 / 2.4) - 0.055
	else
		return 12.92 * channel
	end
end

return table.freeze {
	fromLinear = function(rgb: Color3): Color3
		return Color3.new(transform(rgb.R), transform(rgb.G), transform(rgb.B))
	end,
	toLinear = function(srgb: Color3): Color3
		return Color3.new(inverse(srgb.R), inverse(srgb.G), inverse(srgb.B))
	end,
}
