local Libraries = script.Parent
local Roact = require(Libraries.Roact)

local utility = {}

function utility.combine(...: string)
	local combinedRefs = {}
	combinedRefs.Raw = {...}
	combinedRefs.Refs = {}
	
	for _, name in ipairs(combinedRefs.Raw) do
		combinedRefs.Refs[name] = Roact.createRef()
	end
	
	function combinedRefs:toInfo()
		local info = {}
		
		for index, name in ipairs(self.Raw) do
			info[index] = {Name = name, Ref = self.Refs[name]}
		end
		
		return info
	end
	
	function combinedRefs:get(...: string)
		local values = {}
		
		for _, name in ipairs({...}) do
			local ref = self.Refs[name]
			
			table.insert(values, ref:getValue())
		end
		
		return table.unpack(values)
	end
	
	return combinedRefs
end

return utility