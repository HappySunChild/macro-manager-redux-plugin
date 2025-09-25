-- TODO: if we truly wanted to make this platform agnostic we'd implement our own Color3 object constructor.
-- maybe we could do something with ExternalProviders for that? again that's if we really REALLY wanted to go that route, sounds like a headache.

local sRGB = require "./sRGB"

local function fromLinear(rgb: Color3): vector
	local l = rgb.R * 0.4122214708 + rgb.G * 0.5363325363 + rgb.B * 0.0514459929
	local m = rgb.R * 0.2119034982 + rgb.G * 0.6806995451 + rgb.B * 0.1073969566
	local s = rgb.R * 0.0883024619 + rgb.G * 0.2817188376 + rgb.B * 0.6299787005

	local lRoot = l ^ (1 / 3)
	local mRoot = m ^ (1 / 3)
	local sRoot = s ^ (1 / 3)

	return vector.create(
		lRoot * 0.2104542553 + mRoot * 0.7936177850 - sRoot * 0.0040720468,
		lRoot * 1.9779984951 - mRoot * 2.4285922050 + sRoot * 0.4505937099,
		lRoot * 0.0259040371 + mRoot * 0.7827717662 - sRoot * 0.8086757660
	)
end

local function toLinear(lab: vector, unclamped: boolean?): Color3
	local lRoot = lab.x + lab.y * 0.3963377774 + lab.z * 0.2158037573
	local mRoot = lab.x - lab.y * 0.1055613458 - lab.z * 0.0638541728
	local sRoot = lab.x - lab.y * 0.0894841775 - lab.z * 1.2914855480

	local l = lRoot ^ 3
	local m = mRoot ^ 3
	local s = sRoot ^ 3

	local red = l * 4.0767416621 - m * 3.3077115913 + s * 0.2309699292
	local green = l * -1.2684380046 + m * 2.6097574011 - s * 0.3413193965
	local blue = l * -0.0041960863 - m * 0.7034186147 + s * 1.7076147010

	if not unclamped then
		red = math.clamp(red, 0, 1)
		green = math.clamp(green, 0, 1)
		blue = math.clamp(blue, 0, 1)
	end

	return Color3.new(red, green, blue)
end

return table.freeze {
	fromLinear = fromLinear,
	toLinear = toLinear,

	fromSRGB = function(srgb: Color3): vector
		return fromLinear(sRGB.toLinear(srgb))
	end,
	toSRGB = function(lab: vector, unclamped: boolean?): Color3
		return sRGB.fromLinear(toLinear(lab, unclamped))
	end,
}
