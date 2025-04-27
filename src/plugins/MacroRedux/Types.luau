export type Macro = {
	Order: number?,
	Icon: string?,
	Items: { MacroItem }?,
}

export type MacroItem = {
	Order: number?,
	Type: string,

	[string]: any,
}

return nil
