local graph = require "../graph/types"

local External = require "../External"

local castToGraph = require "../graph/castToGraph"
local observe = require "../graph/observe"

-- Pauses the current thread until the subject receives an eager update
local function await(subject: graph.GraphObject)
	if not castToGraph(subject) then
		-- i believe this should error, because if we didn't it would infitely yield a thread
		-- or cause loops that depend on it to spiral out of control
		External.logError "awaitNonGraph"
	end

	local current = coroutine.running()

	local disconnect
	disconnect = observe(subject.scope, subject, function()
		coroutine.resume(current)

		disconnect()
	end)

	coroutine.yield()
end

return await
