local function castToGraph(target: unknown)
	if
		typeof(target) == "table"
		and target.createdAt ~= nil
		and target._users ~= nil
		and target._using ~= nil
	then
		return target
	end

	return nil
end

return castToGraph
