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

export type ValueMacroItem<V> = MacroItem & {
	Value: V?
}

return nil
