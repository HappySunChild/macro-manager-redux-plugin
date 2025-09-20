local logging = require "./logging/types"

export type ExternalProvider = {
	startScheduler: () -> (),
	stopScheduler: () -> (),

	logErrorNonFatal: (message: string) -> (),
	logWarn: (message: string) -> (),

	doTaskImmediate: <A...>(resume: (A...) -> () | thread, A...) -> thread?,
	doTaskDeferred: <A...>(resume: (A...) -> () | thread, A...) -> thread?,
	doTaskDelayed: <A...>(sec: number, resume: (A...) -> () | thread, A...) -> thread?,
	cancelTask: (task: thread) -> boolean,
}

local formatError = require "./logging/formatError"

local boundCallbacks = {}
local activeProvider: ExternalProvider? = nil

local lastUpdate = os.clock()
local deltaTime = 0

local External = table.freeze {
	setProvider = function(newProvider: ExternalProvider?)
		local oldProvider = activeProvider

		if oldProvider ~= nil then
			oldProvider.stopScheduler()
		end

		activeProvider = newProvider

		if newProvider then
			newProvider.startScheduler()
		end

		return oldProvider
	end,
	bindToUpdateStep = function(callback: (now: number) -> ()): () -> ()
		local uniqueIdentifier = {}
		boundCallbacks[uniqueIdentifier] = callback

		return function()
			boundCallbacks[uniqueIdentifier] = nil
		end
	end,
	performUpdateStep = function(): ()
		local now = os.clock()

		deltaTime = now - lastUpdate
		lastUpdate = now

		for _, callback in boundCallbacks do
			callback(now)
		end
	end,

	getDeltaTime = function(): number
		return deltaTime
	end,
	getLastUpdate = function(): number
		return lastUpdate
	end,

	doTaskImmediate = function<A...>(resume: (A...) -> () | thread, ...: A...): thread?
		if not activeProvider then
			return nil
		end

		return activeProvider.doTaskImmediate(resume, ...)
	end,
	doTaskDeferred = function<A...>(resume: (A...) -> () | thread, ...: A...): thread?
		if not activeProvider then
			return nil
		end

		return activeProvider.doTaskDeferred(resume, ...)
	end,
	doTaskDelayed = function<A...>(
		sec: number,
		resume: (A...) -> () | thread,
		...: A...
	): thread?
		if not activeProvider then
			return nil
		end

		return activeProvider.doTaskDelayed(sec, resume, ...)
	end,
	cancelTask = function(task: thread): boolean
		if not activeProvider then
			return false
		end

		return activeProvider.cancelTask(task)
	end,

	logError = function(
		messageId: formatError.MessageId,
		err: logging.Error?,
		...: any?
	): never
		error(formatError(messageId, err, ...), 0)
	end,
	logErrorNonFatal = function(
		messageId: formatError.MessageId,
		err: logging.Error?,
		...: any?
	)
		local message = formatError(messageId, err, ...)

		if activeProvider then
			activeProvider.logErrorNonFatal(message)
		else
			print(message)
		end
	end,
	logWarn = function(messageId: formatError.MessageId, ...: any?)
		local message = formatError(messageId, debug.traceback(nil, 2), ...)

		if activeProvider then
			activeProvider.logWarn(message)
		else
			print(message)
		end
	end,
}

return External
