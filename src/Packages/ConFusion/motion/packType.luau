local Oklab = require "../colour/Oklab"

local PACK_METHODS = table.freeze {
	number = function(numbers: { number })
		return numbers[1]
	end,
	vector = function(numbers: { number })
		return vector.create(numbers[1], numbers[2], numbers[3])
	end,
	Vector2 = function(numbers: { number })
		return Vector2.new(numbers[1], numbers[2])
	end,
	Vector3 = function(numbers: { number })
		return Vector3.new(numbers[1], numbers[2], numbers[3])
	end,
	UDim = function(numbers: { number })
		return UDim.new(numbers[1], math.round(numbers[2]))
	end,
	UDim2 = function(numbers: { number })
		return UDim2.new(
			numbers[1],
			math.round(numbers[2]),
			numbers[3],
			math.round(numbers[4])
		)
	end,
	CFrame = function(numbers: { number })
		return CFrame.new(numbers[1], numbers[2], numbers[3])
			* CFrame.fromAxisAngle(
				Vector3.new(numbers[4], numbers[5], numbers[6]),
				numbers[7]
			)
	end,
	Color3 = function(numbers: { number })
		return Oklab.toSRGB(vector.create(numbers[1], numbers[2], numbers[3]), false)
	end,
} :: { [string]: (numbers: { number }) -> any }

local function packType(dataType: string, packed: { number })
	local packer = PACK_METHODS[dataType]

	if type(packer) == "function" then
		return packer(packed)
	end

	return nil
end

return packType
