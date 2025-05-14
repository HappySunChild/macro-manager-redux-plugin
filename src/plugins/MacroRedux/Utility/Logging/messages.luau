local messages = {
	macroRequireError = "An error occured while requiring Macro '%s'\nERROR_MESSAGE",
	macroMethodError = "An error occured while running :%s for Macro '%s'\nERROR_MESSAGE",
	macroInvalidType = "Expected Macro '%s' to return value of type table, got %s.",

	itemConstructorError = "An error occured while adding MacroItem '%s'\nERROR_MESSAGE",
	itemAlreadyRendered = "MacroItem '%s' has already been rendered.",
	itemInvalidContainer = "Invalid return value for MacroItem class '%s';\n%s",
	itemChangedInfiniteLoop = "Changed recursive callback depth limit exceeded! (8) Consider restructuring your code to prevent this from happening.",

	classRequireError = "An error occured while loading MacroItem class '%s'\nERROR_MESSAGE",
	classInvalidType = "Expected MacroItem class '%s' to return value of type function, got %s.\nYou may have to remove/modify existing classes!",
	classCannotFind = "Unable to find MacroItem class '%s'.",
}

return messages
