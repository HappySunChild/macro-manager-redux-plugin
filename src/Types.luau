export type Macro = {
	Order: number?,
	Icon: string?,
	Items: { MacroItem }?,

	Setup: (Macro, Plugin) -> (),
	Init: (Macro, Plugin) -> (),
	Cleanup: (Macro, Plugin) -> (),

	SetVisible: (Macro, visible: boolean) -> (),
}

export type MacroItem = {
	Order: number?,
	Type: string,
	Text: string?,

	InSection: boolean?,
	SectionDepth: number?,

	SetVisible: (MacroItem, visible: boolean) -> (),

	[string]: unknown,
}

export type ValueMacroItem<V> = MacroItem & {
	Value: V?,

	SetValue: (ValueMacroItem<V>, new: V) -> (),
	Changed: (ValueMacroItem<V>, new: V, old: V) -> (),
}

return nil
