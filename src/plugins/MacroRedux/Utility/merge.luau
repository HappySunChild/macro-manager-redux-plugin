local function merge(base: { [any]: any }, other: { [any]: any })
	for k, v in other do
		base[k] = v
	end

	return base
end

return merge
