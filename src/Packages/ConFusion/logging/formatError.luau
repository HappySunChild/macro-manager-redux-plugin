local logging = require "./types"

local messages = require "./messages"

export type MessageId = string | keyof<typeof(messages)>

local function formatError(
	messageId: MessageId,
	errorOrTrace: logging.Error | string | nil,
	...: unknown
)
	local err = if typeof(errorOrTrace) == "table" then errorOrTrace else nil
	local trace = if typeof(errorOrTrace) == "table"
		then errorOrTrace.trace
		else errorOrTrace

	local message = (messages :: any)[messageId] or messageId
	message = message:format(...)

	if err ~= nil then
		message = message:gsub("ERROR_MESSAGE", err.message)
	else
		message = message:gsub("ERROR_MESSAGE", messageId)
	end

	local errorText = `[ConFusion] {message}\nId: {messageId}`

	if trace ~= nil then
		errorText ..= `\n---- Stack trace ----\n{trace}`
	end

	return errorText:gsub("\n", "\n\t")
end

return formatError
