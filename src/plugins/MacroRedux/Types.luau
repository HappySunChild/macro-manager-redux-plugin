export type Macro = {
	Order: number?,
	Icon: string?,
	Items: { MacroItem }?,

	Setup: (Macro, Plugin) -> (),
	Init: (Macro, Plugin) -> (),
	Cleanup: (Macro, Plugin) -> (),
}

export type MacroItem = {
	Order: number?,
	Type: string,

	[string]: any,
}

export type ValueMacroItem<V> = MacroItem & {
	Value: V?,

	SetValue: (ValueMacroItem<V>, V) -> (),
	Changed: (ValueMacroItem<V>, V, V) -> (),
}

return nil
