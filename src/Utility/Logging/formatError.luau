local messages = require(script.Parent.messages)

export type MessageId = string | keyof<typeof(messages)>
export type Error = {
	type: "Error",
	raw: string,
	message: string,
	trace: string,
}

local function formatError(
	messageId: MessageId,
	errorOrTrace: (string | Error)?,
	...: string?
)
	local err = if typeof(errorOrTrace) == "table" then errorOrTrace else nil
	local trace = if type(errorOrTrace) == "table"
		then errorOrTrace.trace
		else errorOrTrace

	local message: string = messages[messageId] or messageId
	message = message:format(...)

	if err then
		message = message:gsub("ERROR_MESSAGE", err.message)
	else
		message = message:gsub("ERROR_MESSAGE", messageId)
	end

	local errorText = `[MacroManager] {message}\nId: {messageId}`

	if trace ~= nil then
		errorText ..= `\n---- Stack trace ----\n{trace}`
	end

	return errorText:gsub("\n", "\n\t")
end

return formatError
