local package = script.Parent.Parent

local Oklab = require(package.Colors.Oklab)

local unpackMethods = {
	number = function(value: number)
		return { value }
	end,
	Vector2 = function(value: Vector2)
		return { value.X, value.Y }
	end,
	Vector3 = function(value: Vector3)
		return { value.X, value.Y, value.Z }
	end,
	UDim = function(value: UDim)
		return { value.Scale, value.Offset }
	end,
	UDim2 = function(value: UDim2)
		return { value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset }
	end,
	CFrame = function(value: CFrame)
		local axis, angle = value:ToAxisAngle()
		return { value.X, value.Y, value.Z, axis.X, axis.Y, axis.Z, angle }
	end,
	Color3 = function(value: Color3)
		local lab = Oklab.fromSRGB(value)

		return { lab.X, lab.Y, lab.Z }
	end,
}

local function unpackType(value: any)
	local typeString = typeof(value)
	local unpackMethod = unpackMethods[typeString]

	if unpackMethod then
		return unpackMethod(value)
	end

	return {}
end

return unpackType
