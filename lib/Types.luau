export type State = {
	key: string,

	onEntry: (() -> ())?,
	onLeave: (() -> ())?,
	onStep: (() -> ())?,

	transitions: { [Transition]: true },

	[string]: nil,
}

export type Transition = {
	key: string,

	-- TODO: add type to value
	guard: ((value: any) -> boolean)?,
	onTransition: ((value: any) -> ())?,

	[string]: nil,
}

export type Value<T> = {
	initialValue: T,

	serialize: (value: T) -> string,
	deserialize: (serializedValue: string) -> T,

	[string]: nil,
}

return nil
