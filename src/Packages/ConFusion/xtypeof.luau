local function xtypeof(value: any): string
	local vType = typeof(value)

	if vType == "table" then
		if value.type ~= nil then
			return value.type
		end
	end

	return vType
end

return xtypeof
