--!strict

local package = script.Parent.Parent

local Types = require(package.Types)

local active = {}

local function doCleanup(task: Types.Task)
	if active[task] then
		error(`doCleanup has already been called on '{task}'`)
	end

	active[task] = true

	local taskType = typeof(task)

	if taskType == 'Instance' then
		(task :: Instance):Destroy()
	elseif taskType == 'RBXScriptConnection' then
		(task :: RBXScriptConnection):Disconnect()
	elseif taskType == 'function' then
		(task :: () -> ())()
	elseif taskType == 'table' then
		if (task :: { destroy: () -> () }).destroy then
			task.destroy()
		elseif (task :: { Destroy: () -> () }).Destroy then
			task.Destroy()
		elseif task[1] ~= nil then
			for i = #task, 1, -1 do
				doCleanup(task[i])
				task[i] = nil
			end
		end
	end

	active[task] = nil
end

return doCleanup
