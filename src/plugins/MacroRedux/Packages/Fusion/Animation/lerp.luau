local package = script.Parent.Parent

local Oklab = require(package.Colors.Oklab)

local lerpFunctions = {
	number = function(a: number, b: number, alpha: number)
		return alpha * (b - a) + a
	end,
	Color3 = function(a: Color3, b: Color3, alpha: number)
		local okFrom = Oklab.fromSRGB(a)
		local okTarget = Oklab.fromSRGB(b)

		return Oklab.toSRGB(okFrom:Lerp(okTarget, alpha))
	end,
	Vector3 = function(a: Vector3, b: Vector3, alpha: number)
		return a:Lerp(b, alpha)
	end,
	Vector2 = function(a: Vector2, b: Vector2, alpha: number)
		return a:Lerp(b, alpha)
	end,
	CFrame = function(a: CFrame, b: CFrame, alpha: number)
		return a:Lerp(b, alpha)
	end,
	UDim = function(a: UDim, b: UDim, alpha: number)
		return UDim.new(alpha * (b.Scale - a.Scale) + a.Scale, alpha * (b.Offset - a.Offset) + a.Offset)
	end,
	UDim2 = function(a: UDim2, b: UDim2, alpha: number)
		return a:Lerp(b, alpha)
	end,
}

local function lerp<V>(from: V, target: V, alpha: number): V
	local dataType = typeof(from)

	if typeof(target) == dataType then
		local lerpFunc = lerpFunctions[dataType]

		if lerpFunc then
			return lerpFunc(from, target, alpha)
		end
	end

	if alpha < 0.5 then
		return from
	else
		return target
	end
end

return lerp
