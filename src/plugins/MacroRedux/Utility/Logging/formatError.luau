local messages = require(script.Parent.messages)

export type MessageId = string | keyof<typeof(messages)>

local function formatError(
	messageId: MessageId,
	errorOrTrace: string?,
	...: string?
)
	local message: string = messages[messageId] or messageId
	message = message:format(...)

	local errorText = `[MacroManager] {message}\nId: {messageId}`

	if errorOrTrace then
		errorText ..= `\n---- Stack trace ----\n{errorOrTrace}`
	end

	return errorText:gsub("\n", "\n\t")
end

return formatError
