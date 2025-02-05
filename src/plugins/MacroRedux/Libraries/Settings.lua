local pluginSettings = {}
pluginSettings.Settings = {}

function pluginSettings.path(...)
	local t = {...}
	
	for ind, value in t do
		t[ind] = tostring(value)
	end
	
	return table.concat(t, '/')
end

function pluginSettings:Set(path: string, value: any)
	if not path then
		return
	end
	
	local directories = string.split(path, '/')
	local target = table.remove(directories, #directories)
	
	local current = self.Settings
	
	for _, directory in directories do
		if not current[directory] then
			current[directory] = {}
		end
		
		current = current[directory]
	end
	
	current[target] = value
end

function pluginSettings:Get(path: string)
	if not path then
		return
	end
	
	local directories = string.split(path, '/')
	local target = table.remove(directories, #directories)
	
	local current = self.Settings
	
	for _, directory in directories do
		if not current[directory] then
			return nil
		end
		
		current = current[directory]
	end
	
	return current[target]
end

return pluginSettings