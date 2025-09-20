local memory = require "./types"

local External = require "../External"

local active = {}

local function doCleanup(action: memory.CleanupTask)
	if active[action] then
		External.logError "destroyedTwice"
	end

	active[action] = true

	local taskType = typeof(action)

	if taskType == "Instance" then
		(action :: Instance):Destroy()
	elseif taskType == "RBXScriptConnection" then
		(action :: RBXScriptConnection):Disconnect()
	elseif taskType == "function" then
		(action :: () -> ())()
	elseif taskType == "table" then
		action = action :: { memory.CleanupTask }

		if action[1] ~= nil then
			for i = #action, 1, -1 do
				doCleanup(action[i])

				action[i] = nil
			end
		end
	end

	active[action] = nil
end

return doCleanup
