--!strict

local function xkindof(value: any): string
	local vType = typeof(value)

	if vType == 'table' then
		if value.kind then
			return value.kind
		end
	end

	return vType
end

return xkindof
