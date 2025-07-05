--!strict
local Types = require "./Types"

local formatError = require "./Logging/formatError"

local External = {}

local boundCallbacks = {}
local activeProvider: Types.ExternalProvider? = nil

function External.setProvider(newProvider: Types.ExternalProvider?)
	local oldProvider = activeProvider

	if oldProvider ~= nil then
		oldProvider.stopScheduler()
	end

	activeProvider = newProvider

	if newProvider then
		newProvider.startScheduler()
	end

	return oldProvider
end

function External.unbindAll()
	table.clear(boundCallbacks)
end

function External.bindToUpdate(callback: (now: number) -> ())
	local uniqueIdentifier = {}
	boundCallbacks[uniqueIdentifier] = callback

	return function()
		boundCallbacks[uniqueIdentifier] = nil
	end
end

local lastUpdateStep = os.clock()
local deltaTime = 0

function External.performUpdate()
	local now = os.clock()

	deltaTime = now - lastUpdateStep
	lastUpdateStep = now

	for _, callback in boundCallbacks do
		callback(now)
	end
end

function External.deltaTime(): number
	return deltaTime
end

function External.lastUpdateStep(): number
	return lastUpdateStep
end

function External.doTaskImmediate(resume: (...unknown?) -> (), ...: unknown?): thread?
	if not activeProvider then
		return nil
	end

	return activeProvider.doTaskImmediate(resume, ...)
end

function External.doTaskDeferred(resume: (...unknown?) -> (), ...: unknown?): thread?
	if not activeProvider then
		return nil
	end

	return activeProvider.doTaskDeferred(resume, ...)
end

function External.cancelTask(thread: thread): boolean
	if not activeProvider then
		return false
	end

	return activeProvider.cancelTask(thread)
end

function External.logError(
	messageId: formatError.MessageId,
	err: Types.Error?,
	...: unknown
): never
	error(formatError(messageId, err, ...), 0)
end

function External.logErrorNonFatal(
	messageId: formatError.MessageId,
	err: Types.Error?,
	...: unknown
)
	local message = formatError(messageId, err, ...)

	if activeProvider then
		activeProvider.logErrorNonFatal(message)
	else
		print(message)
	end
end

function External.logWarn(messageId: formatError.MessageId, ...: unknown)
	local message = formatError(messageId, debug.traceback(nil, 2), ...)

	if activeProvider then
		activeProvider.logWarn(message)
	else
		print(message)
	end
end

return External
